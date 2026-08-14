"""Download and normalize the Kaggle Cassava Leaf Disease dataset package."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path
import kagglehub

DEFAULT_DATASET = "nirmalsankalana/cassava-leaf-disease-classification"
DEFAULT_DOWNLOAD_DIR = Path(".tmp") / "kaggle-cassava"
METADATA_FILES = ("labels.csv", "class_distribution.csv", "dataset_manifest.csv", "train.csv")


def dataset_ready(project_root: Path) -> bool:
    """Treat the dataset as ready only when both raw classes and all splits exist."""
    raw_dir = project_root / "datasets" / "raw"
    split_dir = project_root / "datasets" / "split"

    return (
        raw_dir.is_dir()
        and any(path.is_dir() for path in raw_dir.iterdir())
        and (split_dir / "train").is_dir()
        and (split_dir / "val").is_dir()
        and (split_dir / "test").is_dir()
    )


def find_raw_folder(download_path: Path) -> Path:
    """Find the folder containing the 5 disease class subdirectories."""
    # Check for explicit nested raw subfolders
    candidates = [
        download_path / "raw",
        download_path / "cassava-leaf-disease-classification",
    ]
    for candidate in candidates:
        if candidate.is_dir():
            return candidate

    # Check if a single top-level wrapper directory exists
    subdirs = [p for p in download_path.iterdir() if p.is_dir() and not p.name.startswith(".")]
    if len(subdirs) == 1 and subdirs[0].name.lower().startswith("cassava"):
        return subdirs[0]

    # Default to download root if classes are located directly at top-level
    return download_path


def copy_tree(source: Path, destination: Path) -> None:
    """Replace stale dataset folders atomically from the caller's perspective."""
    if destination.exists():
        shutil.rmtree(destination)
    shutil.copytree(source, destination)


def copy_metadata_files(download_path: Path, datasets_dir: Path) -> None:
    """Preserve Kaggle metadata files when available."""
    for file_name in METADATA_FILES:
        for root in [download_path, download_path.parent]:
            candidate = root / file_name
            if candidate.is_file():
                shutil.copy2(candidate, datasets_dir / file_name)
                break


def normalize_dataset(download_path: Path, project_root: Path) -> None:
    """Move downloaded folders into datasets/raw and generate split sets."""
    raw_source = find_raw_folder(download_path)
    datasets_dir = project_root / "datasets"
    raw_destination = datasets_dir / "raw"
    split_destination = datasets_dir / "split"

    datasets_dir.mkdir(parents=True, exist_ok=True)

    print(f"[INFO] Copying class directories from {raw_source} to {raw_destination}...")
    if raw_destination.exists():
        shutil.rmtree(raw_destination)
    raw_destination.mkdir(parents=True, exist_ok=True)

    # Copy class folders into datasets/raw
    for item in raw_source.iterdir():
        if item.is_dir() and not item.name.startswith((".", "split")):
            shutil.copytree(item, raw_destination / item.name)

    # Split dataset using prepare_data.py if split folder does not exist
    split_source = download_path / "split"
    if split_source.is_dir():
        print("[INFO] Found pre-existing split, copying...")
        copy_tree(split_source, split_destination)
    else:
        print("[INFO] No prepared split found in Kaggle bundle.")
        print("[INFO] Generating 80/10/10 train/val/test splits via scripts/prepare_data.py...")
        subprocess.run([sys.executable, "scripts/prepare_data.py"], check=True)

    copy_metadata_files(download_path, datasets_dir)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download the Kaggle Cassava Leaf Disease dataset package."
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
    args = parse_args()
    project_root = Path.cwd().resolve()

    if dataset_ready(project_root) and not args.force:
        print(
            "[INFO] Cassava dataset is already available under datasets/raw and datasets/split."
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
