"""Evaluate a trained Keras model and generate diagnostic reports."""

import argparse
import csv
import logging
import sys
from collections.abc import Sequence
from pathlib import Path

import keras

from src.analysis.evaluator import Evaluator
from src.analysis.visualizer import Visualizer
from src.core.config import ConfigLoader
from src.data.loader import PlantDataLoader

LOGGER = logging.getLogger(__name__)


def load_labels(path: str | Path) -> list[str]:
    # Reconstruct labels by explicit index instead of trusting file row order.
    class_names: dict[int, str] = {}
    with Path(path).open() as f:
        reader = csv.DictReader(f)
        for row in reader:
            class_names[int(row["index"])] = row["class_name"]

    missing = [idx for idx in range(len(class_names)) if idx not in class_names]
    if missing:
        raise ValueError(f"Label indices must be contiguous, missing: {missing}")

    return [class_names[i] for i in range(len(class_names))]


def _resolve_model_path(model_path: str | None, config: dict) -> str:
    # Prefer the CLI model path while keeping config defaults useful for automation.
    if model_path is not None:
        return model_path

    configured_model = config.get("defaults", {}).get("model_path")
    if not isinstance(configured_model, str) or not configured_model:
        raise ValueError("Model path not provided in CLI args or config.yaml")
    return configured_model


def _resolve_artifact_dir(model_path: str | Path, output_dir: str | None = None) -> Path:
    if output_dir:
        return Path(output_dir).expanduser().resolve()

    current = Path(model_path).expanduser().resolve().parent
    for candidate in [current, *current.parents]:
        if (candidate / "labels.csv").exists():
            return candidate
        if (candidate / "checkpoints").is_dir() and (candidate / "tables").is_dir():
            return candidate

    return current


def _resolve_class_names(
    version_dir: Path, config: dict, labels_path: str | Path | None = None
) -> list[str]:
    if labels_path is not None:
        return load_labels(labels_path)

    labels_path = version_dir / "labels.csv"
    if labels_path.exists():
        return load_labels(labels_path)

    # Fallback keeps old training artifacts usable when labels.csv is missing.
    train_dir = Path(config["data"]["split_path"]) / "train"
    if not train_dir.exists():
        raise FileNotFoundError(f"Labels file and training directory not found: {train_dir}")

    class_names = sorted(path.name for path in train_dir.iterdir() if path.is_dir())
    if not class_names:
        raise ValueError(f"No class directories found in: {train_dir}")
    return class_names


def evaluate(
    model_path: str | None,
    config_path: str,
    output_dir: str | None = None,
    labels_path: str | None = None,
) -> None:
    # Load model and labels from the same versioned artifact directory.
    config = ConfigLoader.load(config_path)
    resolved_model_path = _resolve_model_path(model_path, config)

    print(f"Loading model from: {resolved_model_path}")
    model = keras.saving.load_model(resolved_model_path)

    version_dir = _resolve_artifact_dir(resolved_model_path, output_dir)
    class_names = _resolve_class_names(version_dir, config, labels_path)

    loader = PlantDataLoader(config)
    test_ds = loader.get_dataset("test", shuffle=False)

    evaluator = Evaluator(model, test_ds, class_names, str(version_dir))
    results = evaluator.run()

    print("Generating Plots...")
    viz = Visualizer(str(version_dir), config)

    viz.plot_confusion_matrix(results["y_true"], results["y_pred"], class_names)
    viz.plot_pr_curve(results["y_true_onehot"], results["y_prob"], class_names)
    viz.plot_roc_curve(results["y_true_onehot"], results["y_prob"], class_names)
    viz.plot_top_k_accuracy(results["y_true"], results["y_prob"])
    viz.plot_latency_histogram(results["latencies"])
    viz.plot_confidence_calibration(results["y_true"], results["y_pred"], results["y_prob_max"])
    viz.plot_tsne(results["features"], results["y_true"], class_names)
    viz.plot_class_f1_scores(str(version_dir / "tables" / "classification_report.csv"))

    train_dir = Path(config["data"]["split_path"]) / "train"
    if train_dir.exists():
        # Recompute train-set balance from disk so the exported report is auditable.
        counts = [
            len([path for path in (train_dir / c).iterdir() if path.is_file()]) for c in class_names
        ]
        total = sum(counts)
        weights = [total / (len(class_names) * count) if count else 0 for count in counts]
        viz.plot_data_balance(counts, weights, class_names)

    print(f"Evaluation Complete. Results saved to {version_dir}")


def _parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Evaluate Plant Disease Model")
    parser.add_argument("--model", default=None, help="Path to trained model")
    parser.add_argument("--config", default="configs/config.yaml", help="Path to config")
    parser.add_argument("--output-dir", default=None, help="Directory for evaluation artifacts")
    parser.add_argument("--labels", default=None, help="Path to labels.csv")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
    args = _parse_args(argv)
    try:
        evaluate(args.model, args.config, args.output_dir, args.labels)
    except Exception:
        LOGGER.exception("Evaluation failed")
        sys.exit(1)


if __name__ == "__main__":
    main()
