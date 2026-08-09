"""Prepare a deterministic PlantVillage train/validation/test directory layout."""

import os
import random
import shutil
from pathlib import Path

from tqdm import tqdm

from src.core.config import ConfigLoader


class DataPreparer:
    VALID_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp"}

    def __init__(self, config_path: str):
        # Resolve paths once so cleanup and copy operations use the same contract.
        config = ConfigLoader.load(config_path)
        self.project_root = Path.cwd().resolve()

        self.raw_path = self._resolve_project_path(config["data"]["raw_path"])
        self.split_path = self._resolve_project_path(config["data"]["split_path"])
        self.ratios = config["data"]["split_ratio"]
        self.seed = config["data"]["seed"]
        self.excluded = config["data"].get("excluded_classes", [])

    def clean_target(self) -> None:
        # Reset only a validated project-local split directory.
        self._validate_clean_target()
        if self.split_path.exists():
            shutil.rmtree(self.split_path)
        self.split_path.mkdir(parents=True)

    def split_data(self) -> None:
        # Keep file assignment reproducible across machines and reruns.
        rng = random.Random(self.seed)
        if not self.raw_path.exists():
            raise FileNotFoundError(f"Path not found: {self.raw_path}")

        # Exclude classes before sorting so label order stays deterministic.
        classes = [d.name for d in self.raw_path.iterdir() if d.is_dir()]
        classes = [c for c in classes if c not in self.excluded]
        classes.sort()

        print(f"Classes: {len(classes)}")

        for class_name in tqdm(classes, desc="Processing"):
            src_dir = self.raw_path / class_name
            images = [f for f in src_dir.iterdir() if f.suffix.lower() in self.VALID_EXTENSIONS]

            images.sort()
            rng.shuffle(images)
            splits = self._split_images(images)

            # Prefer symlinks to avoid duplicating datasets; copy on platforms that disallow them.
            for split_name, split_imgs in splits.items():
                dest_dir = self.split_path / split_name / class_name
                dest_dir.mkdir(parents=True, exist_ok=True)

                for img_path in split_imgs:
                    dest_file = dest_dir / img_path.name
                    try:
                        os.symlink(img_path.resolve(), dest_file)
                    except OSError:
                        shutil.copy(img_path, dest_file)

    def _split_images(self, images: list[Path]) -> dict[str, list[Path]]:
        n_images = len(images)
        split_names = ["train", "val", "test"]
        raw_counts = {name: n_images * float(self.ratios[name]) for name in split_names}
        counts = {name: int(raw_counts[name]) for name in split_names}

        remaining = n_images - sum(counts.values())
        by_fraction = sorted(
            split_names,
            key=lambda name: (raw_counts[name] - counts[name], self.ratios[name]),
            reverse=True,
        )
        for name in by_fraction[:remaining]:
            counts[name] += 1

        if n_images >= len(split_names):
            for name in split_names:
                if counts[name] == 0:
                    donor = max(split_names, key=lambda candidate: counts[candidate])
                    if counts[donor] > 1:
                        counts[donor] -= 1
                        counts[name] = 1

        train_end = counts["train"]
        val_end = train_end + counts["val"]
        return {
            "train": images[:train_end],
            "val": images[train_end:val_end],
            "test": images[val_end:],
        }

    def _resolve_project_path(self, value: str) -> Path:
        # Resolve config paths relative to the project root used for this run.
        path = Path(value).expanduser()
        if not path.is_absolute():
            path = self.project_root / path
        return path.resolve()

    def _validate_clean_target(self) -> None:
        # Guard destructive cleanup against project root and outside-project paths.
        target = self.split_path.resolve()

        if target == self.project_root:
            raise ValueError("Refusing to clean the project root")

        if not target.is_relative_to(self.project_root):
            raise ValueError(f"Refusing to clean a path outside the project: {target}")

        if target.anchor == str(target):
            raise ValueError(f"Refusing to clean a filesystem root: {target}")

        if target.exists() and not target.is_dir():
            raise ValueError(f"Split path exists but is not a directory: {target}")


if __name__ == "__main__":
    # Execute the full preparation workflow for direct script usage.
    preparer = DataPreparer("configs/config.yaml")
    preparer.clean_target()
    preparer.split_data()
