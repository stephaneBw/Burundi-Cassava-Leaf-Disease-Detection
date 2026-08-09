"""Unit tests for model construction and training helpers."""

from pathlib import Path

import numpy as np
import pytest


def test_plant_model_passes_mobilenet_preprocessing_flag(monkeypatch) -> None:
    import keras

    from src.modeling.net import PlantModel

    calls: list[dict[str, object]] = []

    def fake_mobilenet(**kwargs):
        calls.append(kwargs)
        inputs = keras.Input(shape=kwargs["input_shape"])
        outputs = keras.layers.Conv2D(2, kernel_size=1)(inputs)
        return keras.Model(inputs, outputs)

    monkeypatch.setattr(keras.applications, "MobileNetV3Large", fake_mobilenet)

    config = {
        "data": {"img_size": [8, 8]},
        "model": {"base_model": "MobileNetV3Large"},
    }
    model, base_model = PlantModel(config, num_classes=3).build()

    assert calls[0]["include_preprocessing"] is True
    assert calls[0]["weights"] == "imagenet"
    assert model.output_shape == (None, 3)
    assert base_model.trainable is False


def test_plant_model_rejects_unsupported_backbone() -> None:
    from src.modeling.net import PlantModel

    config = {
        "data": {"img_size": [8, 8]},
        "model": {"base_model": "ResNet50"},
    }

    with pytest.raises(ValueError, match="Unsupported base_model"):
        PlantModel(config, num_classes=3).build()


def test_trainer_compute_class_weights_uses_sorted_class_directories(tmp_path: Path) -> None:
    from src.modeling.trainer import Trainer

    train_dir = tmp_path / "split" / "train"
    for class_name, count in {"B": 1, "A": 3}.items():
        class_dir = train_dir / class_name
        class_dir.mkdir(parents=True)
        for index in range(count):
            (class_dir / f"{index}.jpg").write_text("x", encoding="utf-8")

    trainer = Trainer.__new__(Trainer)
    trainer.config = {
        "data": {"split_path": str(tmp_path / "split")},
        "model": {"patience": 2},
    }

    weights = trainer._compute_class_weights()

    assert set(weights) == {0, 1}
    assert np.isclose(weights[0], 4 / (2 * 3))
    assert np.isclose(weights[1], 4 / (2 * 1))


def test_trainer_callbacks_start_with_clean_metrics_log(tmp_path: Path) -> None:
    from src.modeling.trainer import Trainer

    tables_dir = tmp_path / "tables"
    tables_dir.mkdir()
    metrics_path = tables_dir / "training_metrics.csv"
    metrics_path.write_text("old metrics", encoding="utf-8")
    (tmp_path / "checkpoints").mkdir()

    trainer = Trainer.__new__(Trainer)
    trainer.output_dir = str(tmp_path)
    trainer.config = {"model": {"patience": 2}}

    callbacks = trainer._get_callbacks()

    assert callbacks
    assert not metrics_path.exists()


def test_trainer_merge_histories_appends_matching_metrics() -> None:
    import keras

    from src.modeling.trainer import Trainer

    first = keras.callbacks.History()
    first.history = {"loss": [1.0], "accuracy": [0.5]}
    first.epoch = [0]

    second = keras.callbacks.History()
    second.history = {"loss": [0.8], "val_loss": [0.9]}
    second.epoch = [1]

    trainer = Trainer.__new__(Trainer)
    merged = trainer._merge_histories(first, second)

    assert merged.history == {"loss": [1.0, 0.8], "accuracy": [0.5]}
    assert merged.epoch == [0, 1]
