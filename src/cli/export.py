"""Export trained Keras models to TensorFlow Lite and mobile assets."""

import argparse
import csv
import shutil
from collections.abc import Callable, Iterator, Sequence
from pathlib import Path

import tensorflow as tf

from src.core.config import ConfigLoader
from src.data.loader import PlantDataLoader


def convert_to_tflite(
    model_path: str, output_dir: str, config: dict, labels_path: str | None = None
) -> None:
    # Export both a baseline FP32 artifact and the mobile-oriented quantized model.
    print(f"Converting model: {model_path}")
    model = tf.keras.models.load_model(model_path)
    model_name = Path(model_path).stem

    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    tflite_model = converter.convert()
    fp32_path = Path(output_dir) / f"{model_name}.tflite"

    with fp32_path.open("wb") as f:
        f.write(tflite_model)
    print(f"Standard model saved: {fp32_path}")

    # Calibrate integer quantization with samples from the training distribution.
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = _build_representative_dataset(config)
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    # Keep the public inference contract aligned with Keras and Flutter:
    # float32 NHWC RGB pixels in the 0..255 range, with MobileNetV3 preprocessing
    # owned by the model graph. Internal tensors are still calibrated for int8.
    converter.inference_input_type = tf.float32
    converter.inference_output_type = tf.float32

    tflite_quant_model = converter.convert()
    quant_path = Path(output_dir) / f"{model_name}_quantized.tflite"

    with quant_path.open("wb") as f:
        f.write(tflite_quant_model)
    print(f"Optimized model saved: {quant_path}")
    _validate_tflite_contract(quant_path, config)

    _copy_assets_to_mobile(
        quant_path, labels_path=_resolve_labels_path(Path(model_path), labels_path)
    )

    print("-" * 30)
    print(f"Original Size: {fp32_path.stat().st_size / 1024 / 1024:.2f} MB")
    print(f"Optimized Size: {quant_path.stat().st_size / 1024 / 1024:.2f} MB")


def _build_representative_dataset(config: dict) -> Callable[[], Iterator[list[tf.Tensor]]]:
    # Feed raw training samples into calibration because preprocessing lives in graph.
    loader = PlantDataLoader(config)
    train_ds = loader.get_dataset("train", shuffle=True)

    def representative_gen() -> Iterator[list[tf.Tensor]]:
        # Limit calibration cost while covering multiple batches and classes.
        for images, _ in train_ds.take(100):
            for i in range(images.shape[0]):
                sample = tf.expand_dims(images[i], axis=0)
                yield [sample]

    return representative_gen


def _validate_tflite_contract(model_path: Path, config: dict) -> None:
    # Print tensor types and shapes to catch accidental mobile contract drift.
    interpreter = tf.lite.Interpreter(model_path=str(model_path))
    interpreter.allocate_tensors()
    input_info = interpreter.get_input_details()[0]
    output_info = interpreter.get_output_details()[0]
    print(
        "TFLite contract: "
        f"input={input_info['dtype'].__name__}{tuple(input_info['shape'])}, "
        f"output={output_info['dtype'].__name__}{tuple(output_info['shape'])}"
    )
    expected_shape = tuple(config["data"]["img_size"]) + (3,)
    if input_info["dtype"] != tf.float32.as_numpy_dtype:
        raise ValueError("Quantized TFLite model must expose float32 input tensors")
    if output_info["dtype"] != tf.float32.as_numpy_dtype:
        raise ValueError("Quantized TFLite model must expose float32 output tensors")
    if tuple(input_info["shape"][1:]) != expected_shape:
        raise ValueError(
            f"TFLite input shape {tuple(input_info['shape'][1:])} does not match {expected_shape}"
        )


def _project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _resolve_labels_path(model_path: Path, explicit_labels_path: str | None = None) -> Path:
    if explicit_labels_path is not None:
        labels_path = Path(explicit_labels_path).expanduser().resolve()
        if not labels_path.exists():
            raise FileNotFoundError(f"Labels file not found: {labels_path}")
        return labels_path

    candidates = [
        model_path.parent / "labels.csv",
        model_path.parent.parent / "labels.csv",
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate.resolve()

    raise FileNotFoundError(f"labels.csv not found near model: {model_path}")


def _copy_assets_to_mobile(model_source_path: Path, labels_path: Path | None = None) -> None:
    # Publish the deployable model under the Flutter asset layout.
    source_labels = labels_path or _resolve_labels_path(model_source_path)
    mobile_assets = _project_root() / "mobile" / "assets"
    mobile_models = mobile_assets / "models"

    if not mobile_assets.exists():
        print("Warning: Mobile directory structure not found. Skipping copy.")
        return

    mobile_models.mkdir(parents=True, exist_ok=True)

    model_dest = mobile_models / "best_model_quantized.tflite"
    shutil.copy2(model_source_path, model_dest)
    print(f"Copied model to mobile: {model_dest}")

    if source_labels.exists():
        labels_dest = mobile_assets / "labels.txt"

        # Keep mobile label order identical to the training class-index contract.
        rows: dict[int, str] = {}
        with source_labels.open() as f_csv, labels_dest.open("w") as f_txt:
            reader = csv.DictReader(f_csv)
            for row in reader:
                rows[int(row["index"])] = row["class_name"]
            missing = [index for index in range(len(rows)) if index not in rows]
            if missing:
                raise ValueError(f"Label indices must be contiguous, missing: {missing}")
            for index in range(len(rows)):
                f_txt.write(f"{rows[index]}\n")

        print(f"Generated labels.txt: {labels_dest}")
    else:
        print("Warning: labels.csv not found.")


def _resolve_model_path(model_path: str | None, config: dict) -> str:
    if model_path is not None:
        return model_path

    configured_model = config.get("defaults", {}).get("model_path")
    if not isinstance(configured_model, str) or not configured_model:
        raise ValueError("Model path required via CLI or config defaults")
    return configured_model


def _parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Export TFLite Model")
    parser.add_argument("--model", default=None, help="Path to Keras model")
    parser.add_argument("--config", default="configs/config.yaml", help="Path to config")
    parser.add_argument("--labels", default=None, help="Path to labels.csv")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> None:
    args = _parse_args(argv)
    config = ConfigLoader.load(args.config)
    model_path = _resolve_model_path(args.model, config)
    convert_to_tflite(model_path, str(Path(model_path).parent), config, args.labels)


if __name__ == "__main__":
    main()
