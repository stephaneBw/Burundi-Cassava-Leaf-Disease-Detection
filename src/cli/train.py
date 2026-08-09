"""Train the PlantVillage classifier and persist versioned model artifacts."""

import argparse
import csv
import logging
import os
import sys
from collections.abc import Sequence
from pathlib import Path

from src.analysis.visualizer import Visualizer
from src.core.config import ConfigLoader
from src.core.paths import PathManager
from src.data.loader import PlantDataLoader
from src.modeling.net import PlantModel
from src.modeling.trainer import Trainer

LOGGER = logging.getLogger(__name__)


def _parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train PlantVillage Model")
    parser.add_argument("--config", type=str, default="configs/config.yaml", help="Path to config")
    return parser.parse_args(argv)


def _resolve_class_names(train_dir: Path) -> list[str]:
    if not train_dir.exists():
        raise FileNotFoundError(f"Train directory not found: {train_dir}")

    class_names = sorted(path.name for path in train_dir.iterdir() if path.is_dir())
    if not class_names:
        raise ValueError(f"No class directories found in: {train_dir}")
    return class_names


def _write_labels(labels_path: Path, class_names: list[str]) -> None:
    labels_path.parent.mkdir(parents=True, exist_ok=True)

    # Persist the class-index contract used by evaluation, export, and mobile assets.
    with labels_path.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["index", "class_name"])
        for idx, name in enumerate(class_names):
            writer.writerow([idx, name])


def main(argv: Sequence[str] | None = None) -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
    os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
    args = _parse_args(argv)

    try:
        config = ConfigLoader.load(args.config)
        path_manager = PathManager(config)

        # Build data and label contracts before constructing the model.
        loader = PlantDataLoader(config)
        train_ds = loader.get_dataset("train", shuffle=True)
        val_ds = loader.get_dataset("val")

        train_dir = Path(config["data"]["split_path"]) / "train"
        class_names = _resolve_class_names(train_dir)
        labels_path = Path(path_manager.version_dir) / "labels.csv"
        _write_labels(labels_path, class_names)

        LOGGER.info("Training %s classes. Labels: %s", len(class_names), labels_path)

        model_wrapper = PlantModel(config, len(class_names))
        model, base_model = model_wrapper.build()

        trainer = Trainer(model, base_model, train_ds, val_ds, config, path_manager.version_dir)
        history, transition_epoch = trainer.train()

        viz = Visualizer(path_manager.version_dir, config)
        viz.save_training_history(history, transition_epoch)

    except Exception:
        LOGGER.exception("Training failed")
        sys.exit(1)


if __name__ == "__main__":
    main()
