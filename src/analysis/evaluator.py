"""Evaluate classifier predictions and persist tabular performance reports."""

import os
import time

import keras
import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.metrics import classification_report


class Evaluator:
    def __init__(
        self, model: keras.Model, dataset: tf.data.Dataset, class_names: list[str], output_dir: str
    ):
        # Keep evaluation inputs together so reports, plots, and latency metrics agree.
        self.model = model
        self.dataset = dataset
        self.class_names = class_names
        self.output_dir = output_dir

        # Build reports directories before any evaluation artifact is written.
        os.makedirs(os.path.join(self.output_dir, "tables"), exist_ok=True)
        self.feature_model = self._build_feature_extractor()

    def _build_feature_extractor(self) -> keras.Model:
        # Prefer semantic layer type over generated Keras layer names.
        target_layer = next(
            (
                layer
                for layer in reversed(self.model.layers)
                if isinstance(layer, keras.layers.GlobalAveragePooling2D)
            ),
            None,
        )
        if target_layer is None:
            if len(self.model.layers) < 2:
                raise ValueError("Model must contain at least two layers for feature extraction")
            target_layer = self.model.layers[-2]

        return keras.Model(inputs=self.model.input, outputs=target_layer.output)

    def run(self) -> dict:
        # Accumulate batch outputs so downstream plots use one consistent result set.
        y_true_accumulated = []
        y_prob_accumulated = []
        features_accumulated = []
        latencies = []

        print("Running Inference...")

        # Measure model latency on the same batches used for metric aggregation.
        for images, labels in self.dataset:
            start = time.perf_counter()
            preds = self.model.predict(images, verbose=0)
            elapsed_ms = (time.perf_counter() - start) * 1000

            feats = self.feature_model.predict(images, verbose=0)

            # Convert batch latency into a comparable per-sample estimate.
            batch_size = len(images)
            per_sample = elapsed_ms / batch_size
            latencies.extend([per_sample] * batch_size)

            y_prob_accumulated.extend(preds)
            y_true_accumulated.extend(labels.numpy())
            features_accumulated.extend(feats)

        # Normalize collected tensors into arrays for sklearn and visualization helpers.
        y_true_onehot = np.array(y_true_accumulated)
        y_prob = np.array(y_prob_accumulated)
        features = np.array(features_accumulated)

        y_true_indices = np.argmax(y_true_onehot, axis=1)
        y_pred_indices = np.argmax(y_prob, axis=1)
        y_prob_max = np.max(y_prob, axis=1)

        avg_latency = float(np.mean(latencies))

        self._save_reports(y_true_indices, y_pred_indices, avg_latency)

        return {
            "y_true": y_true_indices,
            "y_pred": y_pred_indices,
            "y_prob": y_prob,
            "y_prob_max": y_prob_max,
            "y_true_onehot": y_true_onehot,
            "latencies": latencies,
            "features": features,
        }

    def _save_reports(self, y_true: np.ndarray, y_pred: np.ndarray, latency: float) -> None:
        # Persist reports in the same table contract used by visualization and release metrics.
        report_dict = classification_report(
            y_true, y_pred, target_names=self.class_names, output_dict=True, zero_division=0
        )
        report = pd.DataFrame(report_dict).transpose()
        report.to_csv(os.path.join(self.output_dir, "tables/classification_report.csv"))

        specs = {
            "Single_Inference_Latency_ms": [latency],
            "Throughput_Samples_Per_Sec": [1000 / latency if latency > 0 else 0],
            "Total_Test_Samples": [len(y_true)],
            "Model_Params": [self.model.count_params()],
        }
        pd.DataFrame(specs).to_csv(
            os.path.join(self.output_dir, "tables/inference_specs.csv"), index=False
        )
