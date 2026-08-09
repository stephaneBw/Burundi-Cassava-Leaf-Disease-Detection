"""Unit tests for Kaggle dataset normalization helpers."""

from pathlib import Path
from types import SimpleNamespace

import pytest

from scripts import download_dataset


def _write_file(path: Path, content: str = "sample") -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def _create_ready_dataset(project_root: Path) -> None:
    _write_file(project_root / "datasets" / "raw" / "Apple___healthy" / "leaf.jpg")
    for split_name in ("train", "val", "test"):
        (project_root / "datasets" / "split" / split_name).mkdir(parents=True, exist_ok=True)


def test_dataset_ready_requires_raw_classes_and_all_splits(tmp_path: Path) -> None:
    assert not download_dataset.dataset_ready(tmp_path)

    raw_dir = tmp_path / "datasets" / "raw"
    raw_dir.mkdir(parents=True)
    for split_name in ("train", "val"):
        (tmp_path / "datasets" / "split" / split_name).mkdir(parents=True)

    assert not download_dataset.dataset_ready(tmp_path)

    _create_ready_dataset(tmp_path)

    assert download_dataset.dataset_ready(tmp_path)


def test_find_dataset_root_supports_nested_kaggle_layout(tmp_path: Path) -> None:
    nested_root = tmp_path / "PlantVillage" / "PlantVillage"
    (nested_root / "raw").mkdir(parents=True)

    assert download_dataset.find_dataset_root(tmp_path) == nested_root


def test_find_dataset_root_rejects_unknown_layout(tmp_path: Path) -> None:
    with pytest.raises(FileNotFoundError, match="PlantVillage raw directory"):
        download_dataset.find_dataset_root(tmp_path)


def test_copy_metadata_files_preserves_available_metadata(tmp_path: Path) -> None:
    download_path = tmp_path / "download"
    dataset_root = download_path / "PlantVillage"
    datasets_dir = tmp_path / "datasets"
    datasets_dir.mkdir()

    _write_file(download_path / "labels.csv", "index,class_name\n0,A\n")
    _write_file(dataset_root / "class_distribution.csv", "class,count\nA,1\n")

    download_dataset.copy_metadata_files(download_path, dataset_root, datasets_dir)

    assert (datasets_dir / "labels.csv").read_text(encoding="utf-8").startswith("index")
    assert (datasets_dir / "class_distribution.csv").read_text(encoding="utf-8").startswith("class")


def test_normalize_dataset_copies_raw_split_and_metadata(tmp_path: Path) -> None:
    download_path = tmp_path / "download"
    dataset_root = download_path / "PlantVillage"
    project_root = tmp_path / "project"

    _write_file(dataset_root / "raw" / "Apple___healthy" / "leaf.jpg")
    _write_file(dataset_root / "split" / "train" / "Apple___healthy" / "leaf.jpg")
    _write_file(download_path / "labels.csv", "index,class_name\n0,Apple___healthy\n")

    download_dataset.normalize_dataset(download_path, project_root)

    assert (project_root / "datasets" / "raw" / "Apple___healthy" / "leaf.jpg").is_file()
    assert (
        project_root / "datasets" / "split" / "train" / "Apple___healthy" / "leaf.jpg"
    ).is_file()
    assert (project_root / "datasets" / "labels.csv").is_file()


def test_normalize_dataset_rebuilds_split_when_missing(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    download_path = tmp_path / "download"
    project_root = tmp_path / "project"
    _write_file(download_path / "raw" / "Apple___healthy" / "leaf.jpg")

    calls: list[tuple[list[str], bool]] = []

    def fake_run(args: list[str], check: bool) -> None:
        calls.append((args, check))

    monkeypatch.setattr(download_dataset.subprocess, "run", fake_run)

    download_dataset.normalize_dataset(download_path, project_root)

    assert calls == [([download_dataset.sys.executable, "scripts/prepare_data.py"], True)]


def test_main_skips_download_when_dataset_is_ready(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    _create_ready_dataset(tmp_path)
    monkeypatch.chdir(tmp_path)
    monkeypatch.setattr(
        download_dataset,
        "parse_args",
        lambda: SimpleNamespace(
            dataset="owner/dataset",
            download_dir=str(tmp_path / "downloads"),
            force=False,
        ),
    )

    def fail_download(*_args: object, **_kwargs: object) -> str:
        raise AssertionError("dataset_download should not be called")

    monkeypatch.setattr(download_dataset.kagglehub, "dataset_download", fail_download)

    download_dataset.main()
