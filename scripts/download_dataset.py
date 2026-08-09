"""Download and normalize the Kaggle PlantVillage dataset package."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

import kagglehub

DEFAULT_DATASET = "mustafaberatyavas/plantvillage-dataset"
DEFAULT_DOWNLOAD_DIR = Path(".tmp") / "kaggle-plantvillage"
METADATA_FILES = ("labels.csv", "class_distribution.csv", "dataset_manifest.csv")


def dataset_ready(project_root: Path) -> bool:
    # Treat the dataset as ready only when both raw classes and all splits exist.
    raw_dir = project_root / "datasets" / "raw"
    split_dir = project_root / "datasets" / "split"

    return (
        raw_dir.is_dir()
        and any(path.is_dir() for path in raw_dir.iterdir())
        and (split_dir / "train").is_dir()
        and (split_dir / "val").is_dir()
        and (split_dir / "test").is_dir()
    )


def find_dataset_root(download_path: Path) -> Path:
    # Support the known Kaggle package layouts without hard-coding one nesting depth.
    candidates = [
        download_path / "PlantVillage" / "PlantVillage",
        download_path / "PlantVillage",
        download_path,
    ]

    for candidate in candidates:
        if (candidate / "raw").is_dir():
            return candidate

    raise FileNotFoundError(
        "Could not find a PlantVillage raw directory in the downloaded dataset package."
    )


def copy_tree(source: Path, destination: Path) -> None:
    # Replace stale dataset folders atomically from the caller's perspective.
    if destination.exists():
        shutil.rmtree(destination)
    shutil.copytree(source, destination)


def copy_metadata_files(download_path: Path, dataset_root: Path, datasets_dir: Path) -> None:
    # Preserve Kaggle metadata when available so downstream audits can trace the data.
    search_roots = [
        download_path,
        download_path / "PlantVillage",
        dataset_root,
        dataset_root.parent,
    ]

    for file_name in METADATA_FILES:
        for root in search_roots:
            candidate = root / file_name
            if candidate.is_file():
                shutil.copy2(candidate, datasets_dir / file_name)
                break


def normalize_dataset(download_path: Path, project_root: Path) -> None:
    # Move the Kaggle bundle into the repository contract consumed by the pipeline.
    dataset_root = find_dataset_root(download_path)
    datasets_dir = project_root / "datasets"
    raw_destination = datasets_dir / "raw"
    split_destination = datasets_dir / "split"

    datasets_dir.mkdir(parents=True, exist_ok=True)

    print("[INFO] Normalizing dataset into datasets/raw and datasets/split...")
    copy_tree(dataset_root / "raw", raw_destination)

    if (dataset_root / "split").is_dir():
        copy_tree(dataset_root / "split", split_destination)
    else:
        print("[WARN] Downloaded package does not include a prepared split.")
        print("[INFO] Rebuilding split from raw images...")
        subprocess.run([sys.executable, "scripts/prepare_data.py"], check=True)

    copy_metadata_files(download_path, dataset_root, datasets_dir)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download the Kaggle PlantVillage dataset package."
    )
    parser.add_argument("--dataset", default=DEFAULT_DATASET, help="Kaggle dataset handle.")
    parser.add_argument(
        "--download-dir",
        default=str(DEFAULT_DOWNLOAD_DIR),
        help="Local staging directory for kagglehub downloads.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Download and normalize even when datasets/raw and datasets/split already exist.",
    )
    return parser.parse_args()


def main() -> None:
    # Keep setup idempotent unless the user explicitly requests a refresh.
    args = parse_args()
    project_root = Path.cwd().resolve()

    if dataset_ready(project_root) and not args.force:
        print(
            "[INFO] PlantVillage dataset is already available under datasets/raw and datasets/split."
        )
        return

    print(f"[INFO] Downloading Kaggle dataset with kagglehub: {args.dataset}")
    print("[INFO] Kaggle credentials may be required for private or restricted datasets.")
    download_path = Path(
        kagglehub.dataset_download(args.dataset, output_dir=args.download_dir)
    ).resolve()

    normalize_dataset(download_path, project_root)
    print("[OK] Dataset is ready.")


if __name__ == "__main__":
    main()
