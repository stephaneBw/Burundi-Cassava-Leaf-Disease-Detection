"""Unit tests for training CLI helper functions."""

from pathlib import Path

import pytest

from src.cli import train


def test_resolve_class_names_sorts_directory_names(tmp_path: Path) -> None:
    train_dir = tmp_path / "train"
    (train_dir / "Tomato___healthy").mkdir(parents=True)
    (train_dir / "Apple___healthy").mkdir()
    (train_dir / "notes.txt").write_text("ignored", encoding="utf-8")

    assert train._resolve_class_names(train_dir) == ["Apple___healthy", "Tomato___healthy"]


def test_resolve_class_names_rejects_missing_train_dir(tmp_path: Path) -> None:
    with pytest.raises(FileNotFoundError, match="Train directory not found"):
        train._resolve_class_names(tmp_path / "missing")


def test_resolve_class_names_rejects_empty_train_dir(tmp_path: Path) -> None:
    train_dir = tmp_path / "train"
    train_dir.mkdir()

    with pytest.raises(ValueError, match="No class directories"):
        train._resolve_class_names(train_dir)


def test_write_labels_persists_index_contract(tmp_path: Path) -> None:
    labels_path = tmp_path / "model_v1" / "labels.csv"

    train._write_labels(labels_path, ["Apple___healthy", "Tomato___healthy"])

    assert labels_path.read_text(encoding="utf-8").splitlines() == [
        "index,class_name",
        "0,Apple___healthy",
        "1,Tomato___healthy",
    ]


def test_main_orchestrates_training_pipeline(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    class FakeLoader:
        def __init__(self, config: dict) -> None:
            self.config = config

        def get_dataset(self, split: str, shuffle: bool = False) -> str:
            return f"{split}:{shuffle}"

    class FakePathManager:
        def __init__(self, _config: dict) -> None:
            self.version_dir = str(tmp_path / "outputs" / "model_v1")
            Path(self.version_dir).mkdir(parents=True)

    class FakePlantModel:
        def __init__(self, config: dict, num_classes: int) -> None:
            assert config["data"]["split_path"] == str(tmp_path / "split")
            assert num_classes == 2

        def build(self) -> tuple[str, str]:
            return "model", "base-model"

    class FakeTrainer:
        def __init__(
            self,
            model: str,
            base_model: str,
            train_ds: str,
            val_ds: str,
            _config: dict,
            output_dir: str,
        ) -> None:
            assert (model, base_model, train_ds, val_ds) == (
                "model",
                "base-model",
                "train:True",
                "val:False",
            )
            assert output_dir == str(tmp_path / "outputs" / "model_v1")

        def train(self) -> tuple[object, int]:
            return object(), 4

    class FakeVisualizer:
        calls: list[int] = []

        def __init__(self, output_dir: str, _config: dict) -> None:
            assert output_dir == str(tmp_path / "outputs" / "model_v1")

        def save_training_history(self, _history: object, transition_epoch: int) -> None:
            self.calls.append(transition_epoch)

    train_dir = tmp_path / "split" / "train"
    (train_dir / "Apple___healthy").mkdir(parents=True)
    (train_dir / "Tomato___healthy").mkdir()
    config = {"data": {"split_path": str(tmp_path / "split")}}

    monkeypatch.setattr(train.ConfigLoader, "load", lambda _path: config)
    monkeypatch.setattr(train, "PathManager", FakePathManager)
    monkeypatch.setattr(train, "PlantDataLoader", FakeLoader)
    monkeypatch.setattr(train, "PlantModel", FakePlantModel)
    monkeypatch.setattr(train, "Trainer", FakeTrainer)
    monkeypatch.setattr(train, "Visualizer", FakeVisualizer)

    train.main(["--config", "config.yaml"])

    labels_path = tmp_path / "outputs" / "model_v1" / "labels.csv"
    assert labels_path.read_text(encoding="utf-8").splitlines() == [
        "index,class_name",
        "0,Apple___healthy",
        "1,Tomato___healthy",
    ]
    assert FakeVisualizer.calls == [4]


def test_main_exits_with_error_when_pipeline_fails(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(train.ConfigLoader, "load", lambda _path: (_ for _ in ()).throw(ValueError))

    with pytest.raises(SystemExit) as exc_info:
        train.main(["--config", "missing.yaml"])

    assert exc_info.value.code == 1
