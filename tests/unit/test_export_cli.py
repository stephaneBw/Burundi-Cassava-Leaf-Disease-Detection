"""Unit tests for TFLite export helper behavior."""

from pathlib import Path
from unittest.mock import MagicMock

import numpy as np
import pytest

from src.cli import export


def test_resolve_model_path_prefers_cli_value() -> None:
    assert export._resolve_model_path(
        "cli.keras", {"defaults": {"model_path": "config.keras"}}
    ) == ("cli.keras")


def test_resolve_model_path_uses_config_default() -> None:
    assert export._resolve_model_path(None, {"defaults": {"model_path": "config.keras"}}) == (
        "config.keras"
    )


def test_resolve_model_path_requires_value() -> None:
    with pytest.raises(ValueError, match="Model path required"):
        export._resolve_model_path(None, {"defaults": {}})


def test_copy_assets_to_mobile_writes_model_and_ordered_labels(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    project_root = tmp_path / "project"
    mobile_assets = project_root / "mobile" / "assets"
    mobile_assets.mkdir(parents=True)

    model_source = tmp_path / "outputs" / "model_v1" / "checkpoints" / "best_quantized.tflite"
    model_source.parent.mkdir(parents=True)
    model_source.write_bytes(b"model")
    (model_source.parent.parent / "labels.csv").write_text(
        "index,class_name\n1,Tomato___healthy\n0,Apple___healthy\n",
        encoding="utf-8",
    )

    monkeypatch.setattr(export, "_project_root", lambda: project_root)

    export._copy_assets_to_mobile(model_source)

    assert (mobile_assets / "models" / "best_model_quantized.tflite").read_bytes() == b"model"
    assert (mobile_assets / "labels.txt").read_text(encoding="utf-8").splitlines() == [
        "Apple___healthy",
        "Tomato___healthy",
    ]


def test_build_representative_dataset_yields_single_sample_batches(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    import tensorflow as tf

    sample_images = tf.ones((2, 4, 4, 3), dtype=tf.float32)
    fake_dataset = tf.data.Dataset.from_tensor_slices((sample_images, tf.constant([0, 1]))).batch(2)
    fake_loader = MagicMock()
    fake_loader.get_dataset.return_value = fake_dataset
    fake_loader_class = MagicMock(return_value=fake_loader)
    monkeypatch.setattr(export, "PlantDataLoader", fake_loader_class)

    representative_dataset = export._build_representative_dataset({"data": {}})
    first_sample = next(representative_dataset())

    fake_loader.get_dataset.assert_called_once_with("train", shuffle=True)
    assert len(first_sample) == 1
    assert tuple(first_sample[0].shape) == (1, 4, 4, 3)


def test_validate_tflite_contract_accepts_expected_float_contract(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    class FakeInterpreter:
        def __init__(self, model_path: str) -> None:
            assert model_path == str(tmp_path / "model.tflite")

        def allocate_tensors(self) -> None:
            pass

        def get_input_details(self) -> list[dict[str, object]]:
            return [{"dtype": np.float32, "shape": np.array([1, 224, 224, 3])}]

        def get_output_details(self) -> list[dict[str, object]]:
            return [{"dtype": np.float32, "shape": np.array([1, 2])}]

    monkeypatch.setattr(export.tf.lite, "Interpreter", FakeInterpreter)

    export._validate_tflite_contract(
        tmp_path / "model.tflite",
        {"data": {"img_size": [224, 224]}},
    )


def test_validate_tflite_contract_rejects_wrong_input_dtype(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    class FakeInterpreter:
        def __init__(self, model_path: str) -> None:
            assert model_path
            pass

        def allocate_tensors(self) -> None:
            pass

        def get_input_details(self) -> list[dict[str, object]]:
            return [{"dtype": np.uint8, "shape": np.array([1, 224, 224, 3])}]

        def get_output_details(self) -> list[dict[str, object]]:
            return [{"dtype": np.float32, "shape": np.array([1, 2])}]

    monkeypatch.setattr(export.tf.lite, "Interpreter", FakeInterpreter)

    with pytest.raises(ValueError, match="float32 input"):
        export._validate_tflite_contract(
            tmp_path / "model.tflite",
            {"data": {"img_size": [224, 224]}},
        )


def test_validate_tflite_contract_rejects_wrong_input_shape(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    class FakeInterpreter:
        def __init__(self, model_path: str) -> None:
            assert model_path
            pass

        def allocate_tensors(self) -> None:
            pass

        def get_input_details(self) -> list[dict[str, object]]:
            return [{"dtype": np.float32, "shape": np.array([1, 128, 128, 3])}]

        def get_output_details(self) -> list[dict[str, object]]:
            return [{"dtype": np.float32, "shape": np.array([1, 2])}]

    monkeypatch.setattr(export.tf.lite, "Interpreter", FakeInterpreter)

    with pytest.raises(ValueError, match="does not match"):
        export._validate_tflite_contract(
            tmp_path / "model.tflite",
            {"data": {"img_size": [224, 224]}},
        )


def test_resolve_labels_path_accepts_explicit_file(tmp_path: Path) -> None:
    labels_path = tmp_path / "labels.csv"
    labels_path.write_text("index,class_name\n0,A\n", encoding="utf-8")

    assert export._resolve_labels_path(tmp_path / "model.keras", str(labels_path)) == labels_path


def test_resolve_labels_path_rejects_missing_file(tmp_path: Path) -> None:
    with pytest.raises(FileNotFoundError, match="Labels file not found"):
        export._resolve_labels_path(tmp_path / "model.keras", str(tmp_path / "missing.csv"))


def test_copy_assets_to_mobile_rejects_non_contiguous_labels(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    project_root = tmp_path / "project"
    mobile_assets = project_root / "mobile" / "assets"
    mobile_assets.mkdir(parents=True)

    model_source = tmp_path / "model_quantized.tflite"
    model_source.write_bytes(b"model")
    labels_path = tmp_path / "labels.csv"
    labels_path.write_text("index,class_name\n0,A\n2,C\n", encoding="utf-8")

    monkeypatch.setattr(export, "_project_root", lambda: project_root)

    with pytest.raises(ValueError, match="contiguous"):
        export._copy_assets_to_mobile(model_source, labels_path)


def test_main_loads_config_and_exports_model(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    calls: list[tuple[str, str, dict, str | None]] = []
    model_path = tmp_path / "model.keras"

    monkeypatch.setattr(
        export.ConfigLoader,
        "load",
        lambda _path: {"defaults": {"model_path": str(model_path)}},
    )
    monkeypatch.setattr(
        export,
        "convert_to_tflite",
        lambda model, output_dir, config, labels: calls.append((model, output_dir, config, labels)),
    )

    export.main(["--config", "config.yaml", "--labels", "labels.csv"])

    assert calls == [
        (
            str(model_path),
            str(model_path.parent),
            {"defaults": {"model_path": str(model_path)}},
            "labels.csv",
        )
    ]
