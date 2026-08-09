"""Test configuration edge cases and versioned output path management."""

from pathlib import Path

import pytest

from src.core.config import ConfigLoader
from src.core.paths import PathManager


def test_load_rejects_empty_yaml(tmp_path: Path) -> None:
    config_path = tmp_path / "empty.yaml"
    config_path.write_text("", encoding="utf-8")

    with pytest.raises(ValueError, match="YAML mapping"):
        ConfigLoader.load(str(config_path))


def test_load_rejects_incomplete_split_ratio(tmp_path: Path) -> None:
    config_path = tmp_path / "bad_split_keys.yaml"
    config_path.write_text(
        """
data:
  raw_path: datasets/raw
  split_path: datasets/split
  img_size: [224, 224]
  batch_size: 16
  seed: 42
  split_ratio:
    train: 0.8
    val: 0.2
model:
  base_model: MobileNetV3Large
  learning_rate_stage1: 0.001
  learning_rate_stage2: 0.0001
  epochs_stage1: 15
  epochs_stage2: 30
""",
        encoding="utf-8",
    )

    with pytest.raises(ValueError, match="train, val, and test"):
        ConfigLoader.load(str(config_path))


def test_path_manager_allocates_next_version_and_required_subdirs(tmp_path: Path) -> None:
    # Malformed version folders should not block the next valid model artifact path.
    (tmp_path / "model_v1").mkdir()
    (tmp_path / "model_vbad").mkdir()

    manager = PathManager(config={}, base_root=str(tmp_path))

    assert Path(manager.version_dir).name == "model_v2"
    assert (Path(manager.version_dir) / "checkpoints").is_dir()
    assert (Path(manager.version_dir) / "figures").is_dir()
    assert (Path(manager.version_dir) / "tables").is_dir()


def test_path_manager_uses_configured_output_dir(tmp_path: Path) -> None:
    output_dir = tmp_path / "custom_outputs"

    manager = PathManager(config={"output_dir": str(output_dir)})

    assert Path(manager.version_dir).parent == output_dir
    assert Path(manager.version_dir).name == "model_v1"


def test_load_rejects_unsupported_base_model(tmp_path: Path) -> None:
    config_path = tmp_path / "bad_model.yaml"
    config_path.write_text(
        """
data:
  raw_path: datasets/raw
  split_path: datasets/split
  img_size: [224, 224]
  batch_size: 16
  seed: 42
model:
  base_model: ResNet50
  learning_rate_stage1: 0.001
  learning_rate_stage2: 0.0001
  epochs_stage1: 15
  epochs_stage2: 30
""",
        encoding="utf-8",
    )

    with pytest.raises(ValueError, match="Unsupported base_model"):
        ConfigLoader.load(str(config_path))
