"""Run single-image predictions with Keras or exported TFLite models."""

import argparse
import csv
import logging
import os
import sys
import time
from collections.abc import Sequence
from pathlib import Path

import cv2
import numpy as np

from src.core.config import ConfigLoader

LOGGER = logging.getLogger(__name__)


class Predictor:
    def __init__(
        self,
        model_path: str | None,
        config_path: str,
        labels_path: str | None = None,
    ):
        # Resolve the model and labels together so prediction indices stay meaningful.
        self.config = ConfigLoader.load(config_path)

        if not model_path:
            model_path = self.config.get("defaults", {}).get("model_path")

        if not model_path or not os.path.exists(model_path):
            raise ValueError(f"Invalid model path: {model_path}")

        self.model_path = model_path
        self.image_size = tuple(self.config["data"]["img_size"])
        self.resize_size = (self.image_size[1], self.image_size[0])
        self.is_tflite = model_path.endswith(".tflite")

        if self.is_tflite:
            self._load_tflite_model()
        else:
            self._load_keras_model()

        if not labels_path:
            labels_path = self._find_labels(model_path)

        self.class_names = self._load_labels(labels_path)
        self._validate_label_contract()

    def _load_keras_model(self) -> None:
        # Defer keras import so TFLite-only workflows stay lightweight.
        import keras

        self.model = keras.saving.load_model(self.model_path)

    def _load_tflite_model(self) -> None:
        # Cache tensor metadata once to keep preprocessing aligned with the model.
        import tensorflow as tf

        self.interpreter = tf.lite.Interpreter(model_path=self.model_path)
        self.interpreter.allocate_tensors()
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

    def _find_labels(self, model_path: str) -> str:
        # Search both checkpoint and version roots to support Keras and TFLite artifacts.
        model_dir = os.path.dirname(model_path)
        parent_dir = os.path.dirname(model_dir)
        candidates = [
            os.path.join(model_dir, "labels.csv"),
            os.path.join(parent_dir, "labels.csv"),
            os.path.join(model_dir, "labels.txt"),
            os.path.join(parent_dir, "labels.txt"),
        ]
        for path in candidates:
            if os.path.exists(path):
                return path
        raise FileNotFoundError("labels.csv or labels.txt not found")

    def _load_labels(self, path: str) -> list[str]:
        # Accept CSV mappings from training and plain text labels from mobile assets.
        if path.endswith(".txt"):
            with open(path) as f:
                return [line.strip() for line in f if line.strip()]

        class_names: dict[int, str] = {}
        with open(path) as f:
            reader = csv.DictReader(f)
            for row in reader:
                class_names[int(row["index"])] = row["class_name"]

        missing = [i for i in range(len(class_names)) if i not in class_names]
        if missing:
            raise ValueError(f"Label indices must be contiguous, missing: {missing}")

        return [class_names[i] for i in range(len(class_names))]

    def preprocess(self, image_path: str) -> np.ndarray:
        # Mirror the training/mobile preprocessing contract for the active model type.
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Read error: {image_path}")

        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image = cv2.resize(image, self.resize_size, interpolation=cv2.INTER_LINEAR)

        if self.is_tflite:
            input_dtype = self.input_details[0]["dtype"]
            if input_dtype == np.uint8:
                return np.expand_dims(image.astype(np.uint8), axis=0)

            # Project models keep MobileNetV3 preprocessing inside the graph.
            image = image.astype("float32")
            return np.expand_dims(image, axis=0)

        # Project Keras models keep MobileNetV3 preprocessing inside the graph.
        image = image.astype("float32")
        return np.expand_dims(image, axis=0)

    def predict(self, image_path: str) -> tuple[str, float]:
        # Convert the model output vector into the validated human-readable label.
        input_tensor = self.preprocess(image_path)

        if self.is_tflite:
            predictions = self._predict_tflite(input_tensor)
        else:
            predictions = self.model.predict(input_tensor, verbose=0)[0]

        predicted_index = int(np.argmax(predictions))
        confidence = float(np.max(predictions))

        if predicted_index >= len(self.class_names):
            raise ValueError(
                f"Model predicted index {predicted_index}, "
                f"but only {len(self.class_names)} labels are loaded"
            )

        return self.class_names[predicted_index], confidence

    def _predict_tflite(self, input_tensor: np.ndarray) -> np.ndarray:
        # Execute the interpreter with the dtype expected by the exported model.
        self.interpreter.set_tensor(self.input_details[0]["index"], input_tensor)
        self.interpreter.invoke()
        output = self.interpreter.get_tensor(self.output_details[0]["index"])
        return np.asarray(output[0])

    def _validate_label_contract(self) -> None:
        # Fail before inference when labels cannot describe the model output space.
        if not self.class_names:
            raise ValueError("No labels loaded")

        if self.is_tflite:
            output_shape = self.output_details[0].get("shape")
            if output_shape is not None and len(output_shape) >= 2:
                output_count = int(output_shape[-1])
                if output_count != len(self.class_names):
                    raise ValueError(
                        f"Label count ({len(self.class_names)}) does not match "
                        f"model output count ({output_count})"
                    )


def _parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Plant Disease Inference")
    parser.add_argument("--image", type=str, required=True, help="Path to image")
    parser.add_argument("--model", type=str, default=None, help="Path to model")
    parser.add_argument("--config", type=str, default="configs/config.yaml", help="Path to config")
    parser.add_argument("--labels", type=str, default=None, help="Path to labels.csv or labels.txt")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> None:
    Path("logs").mkdir(exist_ok=True)
    logging.basicConfig(
        filename=Path("logs") / "inference.log",
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    args = _parse_args(argv)

    try:
        predictor = Predictor(args.model, args.config, args.labels)

        start = time.perf_counter()
        label, score = predictor.predict(args.image)
        elapsed = (time.perf_counter() - start) * 1000

        print(f"Result: {label} ({score:.4f})")
        print(f"Latency: {elapsed:.2f} ms")
    except Exception:
        LOGGER.exception("Inference failed")
        print("Error: inference failed. Check logs/inference.log for details.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
