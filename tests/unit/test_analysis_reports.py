"""Unit tests for evaluator aggregation and visualization report outputs."""

from pathlib import Path
from unittest.mock import MagicMock

import numpy as np


def test_evaluator_run_aggregates_predictions_and_writes_reports(tmp_path: Path) -> None:
    import tensorflow as tf

    from src.analysis.evaluator import Evaluator

    images = tf.ones((2, 4, 4, 3), dtype=tf.float32)
    labels = tf.constant([[1, 0], [0, 1]], dtype=tf.float32)

    evaluator = Evaluator.__new__(Evaluator)
    evaluator.dataset = [(images, labels)]
    evaluator.class_names = ["A", "B"]
    evaluator.output_dir = str(tmp_path)
    (tmp_path / "tables").mkdir()
    evaluator.model = MagicMock()
    evaluator.model.predict.return_value = np.array([[0.8, 0.2], [0.3, 0.7]])
    evaluator.model.count_params.return_value = 123
    evaluator.feature_model = MagicMock()
    evaluator.feature_model.predict.return_value = np.array([[1.0, 0.0], [0.0, 1.0]])

    results = evaluator.run()

    assert results["y_true"].tolist() == [0, 1]
    assert results["y_pred"].tolist() == [0, 1]
    assert len(results["latencies"]) == 2
    assert (tmp_path / "tables" / "classification_report.csv").is_file()
    assert (tmp_path / "tables" / "inference_specs.csv").is_file()


def test_visualizer_writes_core_report_artifacts(tmp_path: Path) -> None:
    import keras
    import matplotlib

    matplotlib.use("Agg", force=True)

    from src.analysis.visualizer import Visualizer

    history = keras.callbacks.History()
    history.history = {
        "accuracy": [0.5, 0.7],
        "val_accuracy": [0.4, 0.6],
        "loss": [1.0, 0.8],
        "val_loss": [1.1, 0.9],
    }

    visualizer = Visualizer(str(tmp_path), config={})
    y_true = np.array([0, 1, 1])
    y_pred = np.array([0, 0, 1])
    y_prob = np.array([[0.8, 0.2], [0.6, 0.4], [0.1, 0.9]])
    y_true_onehot = np.eye(2)[y_true]

    visualizer.save_training_history(history, transition_epoch=1)
    visualizer.plot_confusion_matrix(y_true, y_pred, ["A", "B"])
    visualizer.plot_pr_curve(y_true_onehot, y_prob, ["A", "B"])
    visualizer.plot_roc_curve(y_true_onehot, y_prob, ["A", "B"])
    visualizer.plot_top_k_accuracy(y_true, y_prob, k_values=[1, 2])
    visualizer.plot_latency_histogram([1.0, 2.0, 3.0])
    visualizer.plot_confidence_calibration(y_true, y_pred, np.max(y_prob, axis=1))
    visualizer.plot_data_balance([2, 1], [0.75, 1.5], ["A", "B"])

    expected_files = [
        tmp_path / "tables" / "training_metrics.csv",
        tmp_path / "tables" / "top_confusions.csv",
        tmp_path / "tables" / "class_metadata.csv",
        tmp_path / "figures" / "training_history.png",
        tmp_path / "figures" / "confusion_matrix.png",
        tmp_path / "figures" / "pr_curve.png",
        tmp_path / "figures" / "roc_curve.png",
        tmp_path / "figures" / "top_k_accuracy.png",
        tmp_path / "figures" / "latency_histogram.png",
        tmp_path / "figures" / "confidence_calibration.png",
        tmp_path / "figures" / "data_balance_analysis.png",
    ]
    assert all(path.is_file() for path in expected_files)


def test_evaluator_builds_feature_extractor_from_pooling_layer() -> None:
    import keras

    from src.analysis.evaluator import Evaluator

    inputs = keras.Input(shape=(4, 4, 3))
    x = keras.layers.Conv2D(2, kernel_size=1)(inputs)
    x = keras.layers.GlobalAveragePooling2D()(x)
    outputs = keras.layers.Dense(2)(x)
    model = keras.Model(inputs, outputs)

    evaluator = Evaluator(
        model=model,
        dataset=[],
        class_names=["A", "B"],
        output_dir=".",
    )

    assert evaluator.feature_model.output_shape == (None, 2)


def test_evaluator_rejects_model_without_feature_layer() -> None:
    import pytest

    from src.analysis.evaluator import Evaluator

    evaluator = Evaluator.__new__(Evaluator)
    evaluator.model = MagicMock(layers=[object()])

    with pytest.raises(ValueError, match="at least two layers"):
        evaluator._build_feature_extractor()


def test_visualizer_writes_optional_f1_and_tsne_reports(tmp_path: Path) -> None:
    import matplotlib

    matplotlib.use("Agg", force=True)

    from src.analysis.visualizer import Visualizer

    visualizer = Visualizer(str(tmp_path), config={"data": {"seed": 7}})
    report_path = tmp_path / "tables" / "classification_report.csv"
    report_path.write_text(
        ",precision,recall,f1-score,support\n"
        "A,1.0,0.5,0.667,2\n"
        "B,0.5,1.0,0.667,2\n"
        "accuracy,0.75,0.75,0.75,4\n"
        "macro avg,0.75,0.75,0.667,4\n"
        "weighted avg,0.75,0.75,0.667,4\n",
        encoding="utf-8",
    )

    visualizer.plot_class_f1_scores(str(report_path))
    visualizer.plot_tsne(
        features=np.array([[0.0, 0.0], [1.0, 1.0], [0.9, 1.1]], dtype=np.float32),
        y_true=np.array([0, 1, 1]),
        classes=["A", "B"],
    )

    assert (tmp_path / "figures" / "class_f1_scores.png").is_file()
    assert (tmp_path / "figures" / "tsne_clusters.png").is_file()
