"""Run the two-stage transfer learning and fine-tuning workflow."""

import os

import keras
import numpy as np
import tensorflow as tf
from sklearn.utils import class_weight


class Trainer:
    def __init__(
        self,
        model: keras.Model,
        base_model: keras.Model,
        train_ds: tf.data.Dataset,
        val_ds: tf.data.Dataset,
        config: dict,
        output_dir: str,
    ):
        # Keep orchestration dependencies explicit for easier testability.
        self.model = model
        self.base_model = base_model
        self.train_ds = train_ds
        self.val_ds = val_ds
        self.config = config
        self.output_dir = output_dir

        # Prepare callbacks and class weights once per training session.
        self.callbacks = self._get_callbacks()
        self.class_weights = self._compute_class_weights()

    def _get_callbacks(self) -> list[keras.callbacks.Callback]:
        # Store checkpoints and logs under the selected model version.
        checkpoint_dir = os.path.join(self.output_dir, "checkpoints")
        log_dir = os.path.join(self.output_dir, "tables")
        metrics_path = os.path.join(log_dir, "training_metrics.csv")
        if os.path.exists(metrics_path):
            os.remove(metrics_path)

        return [
            keras.callbacks.ModelCheckpoint(
                filepath=os.path.join(checkpoint_dir, "best_model.keras"),
                save_best_only=True,
                monitor="val_loss",
                mode="min",
                verbose=1,
            ),
            keras.callbacks.EarlyStopping(
                monitor="val_loss",
                patience=self.config["model"]["patience"],
                restore_best_weights=True,
                verbose=1,
            ),
            keras.callbacks.CSVLogger(metrics_path, append=True),
            keras.callbacks.ReduceLROnPlateau(
                monitor="val_loss",
                factor=0.2,
                patience=max(1, self.config["model"]["patience"] // 2),
                min_lr=1e-7,
                verbose=1,
            ),
        ]

    def _compute_class_weights(self) -> dict[int, float]:
        # Compute class weights from the same directory order used for labels.csv.
        train_dir = os.path.join(self.config["data"]["split_path"], "train")

        class_names = sorted(
            [d for d in os.listdir(train_dir) if os.path.isdir(os.path.join(train_dir, d))]
        )

        y_train = []
        for idx, class_name in enumerate(class_names):
            class_path = os.path.join(train_dir, class_name)
            with os.scandir(class_path) as it:
                num_files = sum(1 for entry in it if entry.is_file())
            y_train.extend([idx] * num_files)

        weights = class_weight.compute_class_weight(
            class_weight="balanced", classes=np.unique(y_train), y=y_train
        )
        return dict(enumerate(weights))

    def train(self) -> tuple[keras.callbacks.History, int]:
        # Stage 1 warms the custom head while the pretrained backbone is frozen.
        optimizer_stage1 = keras.optimizers.Adam(
            learning_rate=self.config["model"]["learning_rate_stage1"]
        )

        self.model.compile(
            optimizer=optimizer_stage1, loss="categorical_crossentropy", metrics=["accuracy"]
        )

        history_stage1 = self.model.fit(
            self.train_ds,
            validation_data=self.val_ds,
            epochs=self.config["model"]["epochs_stage1"],
            callbacks=self.callbacks,
            class_weight=self.class_weights,
        )

        # Stage 2 fine-tunes convolutional layers with a lower learning rate.
        self.base_model.trainable = True
        fine_tune_fraction = self.config["model"].get("fine_tune_fraction", 0.3)
        fine_tune_count = max(1, int(len(self.base_model.layers) * fine_tune_fraction))
        fine_tune_from = len(self.base_model.layers) - fine_tune_count

        # Keep ImageNet batch-normalization statistics stable during fine-tuning.
        for index, layer in enumerate(self.base_model.layers):
            if index < fine_tune_from or isinstance(layer, keras.layers.BatchNormalization):
                layer.trainable = False

        optimizer_stage2 = keras.optimizers.Adam(
            learning_rate=self.config["model"]["learning_rate_stage2"]
        )

        self.model.compile(
            optimizer=optimizer_stage2, loss="categorical_crossentropy", metrics=["accuracy"]
        )

        # Continue epoch numbering so callbacks and plots show one continuous run.
        total_epochs = self.config["model"]["epochs_stage1"] + self.config["model"]["epochs_stage2"]
        initial_epoch = len(history_stage1.history["loss"])

        history_stage2 = self.model.fit(
            self.train_ds,
            validation_data=self.val_ds,
            epochs=total_epochs,
            initial_epoch=initial_epoch,
            callbacks=self.callbacks,
            class_weight=self.class_weights,
        )

        merged_history = self._merge_histories(history_stage1, history_stage2)
        return merged_history, initial_epoch

    def _merge_histories(
        self, h1: keras.callbacks.History, h2: keras.callbacks.History
    ) -> keras.callbacks.History:
        # Preserve Keras History shape while appending stage-2 metrics.
        for key in h1.history:
            if key in h2.history:
                h1.history[key].extend(h2.history[key])

        if hasattr(h1, "epoch") and hasattr(h2, "epoch"):
            h1.epoch.extend(h2.epoch)

        return h1
