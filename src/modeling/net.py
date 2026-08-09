"""Build the MobileNetV3-based PlantVillage classification model."""

import keras

from src.core.config import ConfigLoader


class PlantModel:
    def __init__(self, config: dict, num_classes: int):
        # Keep model shape and label count tied to the loaded runtime config.
        self.input_shape = (*config["data"]["img_size"], 3)
        self.num_classes = num_classes
        self.model_name = config["model"]["base_model"]

        # Apply lightweight image augmentation inside the model graph for training only.
        self.data_augmentation = keras.Sequential(
            [
                keras.layers.RandomFlip("horizontal_and_vertical"),
                keras.layers.RandomRotation(0.2),
                keras.layers.RandomZoom(0.2),
                keras.layers.RandomContrast(0.2),
            ]
        )

    def build(self) -> tuple[keras.Model, keras.Model]:
        # Resolve the configured Keras application backbone by name.
        if self.model_name not in ConfigLoader.SUPPORTED_BASE_MODELS:
            supported = ", ".join(sorted(ConfigLoader.SUPPORTED_BASE_MODELS))
            raise ValueError(f"Unsupported base_model '{self.model_name}'. Supported: {supported}")

        base_model_class = getattr(keras.applications, self.model_name)
        if not callable(base_model_class):
            raise TypeError(f"Configured base_model '{self.model_name}' is not callable")

        base_model_kwargs = {
            "input_shape": self.input_shape,
            "include_top": False,
            "weights": "imagenet",
        }
        if self.model_name in {"MobileNetV3Large", "MobileNetV3Small"}:
            # Keep the model artifact self-contained: Python, TFLite, and mobile
            # inference all feed raw RGB pixels and rely on this layer to rescale.
            base_model_kwargs["include_preprocessing"] = True

        base_model = base_model_class(**base_model_kwargs)

        # Stage 1 trains only the custom classifier head.
        base_model.trainable = False

        # Build the trainable head expected by the two-stage trainer.
        inputs = keras.Input(shape=self.input_shape)
        x = self.data_augmentation(inputs)
        x = base_model(x, training=False)
        x = keras.layers.GlobalAveragePooling2D()(x)
        x = keras.layers.Dropout(0.2)(x)
        outputs = keras.layers.Dense(self.num_classes, activation="softmax")(x)

        model = keras.Model(inputs, outputs)
        return model, base_model
