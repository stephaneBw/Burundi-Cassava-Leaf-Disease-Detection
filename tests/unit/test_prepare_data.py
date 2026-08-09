"""Test dataset preparation safeguards before filesystem mutations happen."""

from pathlib import Path

import pytest

from scripts.prepare_data import DataPreparer


def _write_config(path: Path, raw_path: str, split_path: str) -> None:
    # Generate a minimal config fixture that still passes production validation.
    path.write_text(
        f"""
data:
  raw_path: {raw_path}
  split_path: {split_path}
  img_size: [224, 224]
  batch_size: 16
  seed: 42
  split_ratio:
    train: 0.8
    val: 0.1
    test: 0.1
model:
  base_model: MobileNetV3Large
  learning_rate_stage1: 0.001
  learning_rate_stage2: 0.0001
  epochs_stage1: 15
  epochs_stage2: 30
""",
        encoding="utf-8",
    )


def test_clean_target_rejects_project_root(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    monkeypatch.chdir(tmp_path)
    config_path = tmp_path / "config.yaml"
    _write_config(config_path, "datasets/raw", ".")

    preparer = DataPreparer(str(config_path))

    with pytest.raises(ValueError, match="project root"):
        preparer.clean_target()


def test_clean_target_rejects_path_outside_project(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    monkeypatch.chdir(tmp_path)
    config_path = tmp_path / "config.yaml"
    outside_split = tmp_path.parent / "outside-split"
    _write_config(config_path, "datasets/raw", str(outside_split))

    preparer = DataPreparer(str(config_path))

    with pytest.raises(ValueError, match="outside the project"):
        preparer.clean_target()


def test_split_data_filters_excludes_and_copies_when_symlink_fails(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    monkeypatch.chdir(tmp_path)
    raw_class = tmp_path / "datasets" / "raw" / "Apple___healthy"
    excluded_class = tmp_path / "datasets" / "raw" / "Tomato___healthy"
    raw_class.mkdir(parents=True)
    excluded_class.mkdir(parents=True)

    for index in range(10):
        (raw_class / f"leaf_{index}.jpg").write_text("image", encoding="utf-8")
    (raw_class / "notes.txt").write_text("ignored", encoding="utf-8")
    (excluded_class / "leaf.jpg").write_text("image", encoding="utf-8")

    config_path = tmp_path / "config.yaml"
    _write_config(config_path, "datasets/raw", "datasets/split")
    config_text = config_path.read_text(encoding="utf-8")
    config_path.write_text(
        config_text.replace(
            "  seed: 42\n",
            "  seed: 42\n  excluded_classes: [Tomato___healthy]\n",
        ),
        encoding="utf-8",
    )

    def fail_symlink(*_args: object, **_kwargs: object) -> None:
        raise OSError("symlink unavailable")

    monkeypatch.setattr("scripts.prepare_data.os.symlink", fail_symlink)

    preparer = DataPreparer(str(config_path))
    preparer.clean_target()
    preparer.split_data()

    split_path = tmp_path / "datasets" / "split"
    assert len(list((split_path / "train" / "Apple___healthy").iterdir())) == 8
    assert len(list((split_path / "val" / "Apple___healthy").iterdir())) == 1
    assert len(list((split_path / "test" / "Apple___healthy").iterdir())) == 1
    assert not (split_path / "train" / "Tomato___healthy").exists()


def test_split_data_keeps_validation_and_test_samples_for_small_classes(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    monkeypatch.chdir(tmp_path)
    raw_class = tmp_path / "datasets" / "raw" / "Apple___healthy"
    raw_class.mkdir(parents=True)

    for index in range(9):
        (raw_class / f"leaf_{index}.jpg").write_text("image", encoding="utf-8")

    config_path = tmp_path / "config.yaml"
    _write_config(config_path, "datasets/raw", "datasets/split")

    preparer = DataPreparer(str(config_path))
    preparer.clean_target()
    preparer.split_data()

    split_path = tmp_path / "datasets" / "split"
    assert len(list((split_path / "train" / "Apple___healthy").iterdir())) == 7
    assert len(list((split_path / "val" / "Apple___healthy").iterdir())) == 1
    assert len(list((split_path / "test" / "Apple___healthy").iterdir())) == 1
