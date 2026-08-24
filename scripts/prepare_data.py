"""Prepare train, validation, and test splits from raw dataset."""

from __future__ import annotations

import argparse
import os
import random
import shutil
import stat
from pathlib import Path
import pandas as pd
from src.core.config import ConfigLoader


def remove_readonly(func, path, excinfo):
    """Force remove read-only attribute on Windows if deletion fails."""
    try:
        os.chmod(path, stat.S_IWRITE)
        func(path)
    except Exception:
        pass


def safe_rmtree(path: Path) -> None:
    """Safely remove a directory tree on Windows."""
    if path.exists():
        shutil.rmtree(path, onerror=remove_readonly)


def get_config_value(cfg, section: str, key: str, default):
    """Safely retrieve configuration values from either dict or object schemas."""
    if isinstance(cfg, dict):
        if section in cfg and isinstance(cfg[section], dict):
            return cfg[section].get(key, default)
        return cfg.get(key, default)

    section_obj = getattr(cfg, section, None)
    if section_obj is not None:
        return getattr(section_obj, key, default)
    return getattr(cfg, key, default)


class DataPreparer:
    def __init__(self, config_path: str = "configs/config.yaml") -> None:
        self.config = ConfigLoader.load(config_path)

        raw_dir = get_config_value(self.config, "data", "raw_data_dir", "datasets/raw")
        split_dir = get_config_value(self.config, "data", "split_data_dir", "datasets/split")
        
        self.raw_path = Path(raw_dir)
        self.split_path = Path(split_dir)
        self.train_ratio = float(get_config_value(self.config, "data", "train_split_ratio", 0.8))
        self.val_ratio = float(get_config_value(self.config, "data", "val_split_ratio", 0.1))
        self.test_ratio = float(get_config_value(self.config, "data", "test_split_ratio", 0.1))
        self.seed = int(get_config_value(self.config, "data", "random_seed", 42))

    def clean_target(self) -> None:
        """Safely clean split directories."""
        print(f"[INFO] Cleaning split target directory: {self.split_path}")
        safe_rmtree(self.split_path)
        self.split_path.mkdir(parents=True, exist_ok=True)

    def run(self) -> None:
        random.seed(self.seed)
        self.clean_target()

        for split in ["train", "val", "test"]:
            (self.split_path / split).mkdir(parents=True, exist_ok=True)

        class_dirs = [
            d for d in self.raw_path.iterdir()
            if d.is_dir() and not d.name.startswith((".", "split"))
        ]

        if not class_dirs:
            raise RuntimeError(f"No class folders found in {self.raw_path}")

        manifest_rows = []
        distribution_rows = []

        print(f"[INFO] Found {len(class_dirs)} classes. Creating splits...")

        for class_dir in sorted(class_dirs):
            class_name = class_dir.name
            images = [
                f for f in class_dir.iterdir()
                if f.is_file() and f.suffix.lower() in [".jpg", ".jpeg", ".png"]
            ]
            random.shuffle(images)

            total = len(images)
            train_end = int(total * self.train_ratio)
            val_end = train_end + int(total * self.val_ratio)

            train_imgs = images[:train_end]
            val_imgs = images[train_end:val_end]
            test_imgs = images[val_end:]

            distribution_rows.append({
                "class": class_name,
                "train": len(train_imgs),
                "val": len(val_imgs),
                "test": len(test_imgs),
                "total": total,
            })

            splits = {
                "train": train_imgs,
                "val": val_imgs,
                "test": test_imgs,
            }

            for split_name, split_files in splits.items():
                dest_dir = self.split_path / split_name / class_name
                dest_dir.mkdir(parents=True, exist_ok=True)
                for img_path in split_files:
                    dest_file = dest_dir / img_path.name
                    shutil.copy2(img_path, dest_file)
                    manifest_rows.append({
                        "filename": img_path.name,
                        "class": class_name,
                        "split": split_name,
                        "path": str(dest_file),
                    })

        # Save metadata reports
        datasets_dir = Path("datasets")
        datasets_dir.mkdir(exist_ok=True)

        pd.DataFrame(manifest_rows).to_csv(datasets_dir / "dataset_manifest.csv", index=False)
        pd.DataFrame(distribution_rows).to_csv(datasets_dir / "class_distribution.csv", index=False)
        
        labels = sorted([d.name for d in class_dirs])
        pd.DataFrame({"label": labels}).to_csv(datasets_dir / "labels.csv", index=False)
        (datasets_dir / "labels.txt").write_text("\n".join(labels), encoding="utf-8")

        print("[OK] Split complete. Manifest and distribution tables created.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Prepare dataset splits.")
    parser.add_argument("--config", default="configs/config.yaml", help="Path to configuration file.")
    args = parser.parse_args()

    preparer = DataPreparer(config_path=args.config)
    preparer.run()


if __name__ == "__main__":
    main()
