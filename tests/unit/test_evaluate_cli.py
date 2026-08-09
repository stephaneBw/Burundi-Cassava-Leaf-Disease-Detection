"""Unit tests for evaluation CLI path and label helpers."""

from pathlib import Path

import pytest

from src.cli import evaluate


def test_load_labels_sorts_by_explicit_index(tmp_path: Path) -> None:
    labels_path = tmp_path / "labels.csv"
    labels_path.write_text("index,class_name\n1,B\n0,A\n", encoding="utf-8")

    assert evaluate.load_labels(labels_path) == ["A", "B"]


def test_load_labels_rejects_non_contiguous_indices(tmp_path: Path) -> None:
    labels_path = tmp_path / "labels.csv"
    labels_path.write_text("index,class_name\n0,A\n2,C\n", encoding="utf-8")

    with pytest.raises(ValueError, match="contiguous"):
        evaluate.load_labels(labels_path)


def test_resolve_model_path_prefers_cli_value() -> None:
    assert evaluate._resolve_model_path(
        "cli.keras", {"defaults": {"model_path": "config.keras"}}
    ) == ("cli.keras")


def test_resolve_model_path_uses_config_default() -> None:
    assert evaluate._resolve_model_path(None, {"defaults": {"model_path": "config.keras"}}) == (
        "config.keras"
    )


def test_resolve_model_path_requires_value() -> None:
    with pytest.raises(ValueError, match="Model path not provided"):
        evaluate._resolve_model_path(None, {"defaults": {"model_path": None}})


def test_resolve_artifact_dir_prefers_nearby_labels(tmp_path: Path) -> None:
    model_path = tmp_path / "outputs" / "model_v1" / "checkpoints" / "best_model.keras"
    model_path.parent.mkdir(parents=True)
    model_path.touch()
    (model_path.parent.parent / "labels.csv").write_text("index,class_name\n0,A\n")

    assert evaluate._resolve_artifact_dir(model_path) == model_path.parent.parent


def test_resolve_artifact_dir_accepts_explicit_output_dir(tmp_path: Path) -> None:
    model_path = tmp_path / "flat" / "model.keras"
    output_dir = tmp_path / "reports"

    assert evaluate._resolve_artifact_dir(model_path, str(output_dir)) == output_dir


def test_resolve_class_names_uses_labels_file(tmp_path: Path) -> None:
    version_dir = tmp_path / "outputs" / "model_v1"
    labels_path = version_dir / "labels.csv"
    labels_path.parent.mkdir(parents=True)
    labels_path.write_text("index,class_name\n0,A\n1,B\n", encoding="utf-8")

    assert evaluate._resolve_class_names(version_dir, {"data": {"split_path": "unused"}}) == [
        "A",
        "B",
    ]


def test_resolve_class_names_falls_back_to_training_directory(tmp_path: Path) -> None:
    train_dir = tmp_path / "datasets" / "split" / "train"
    (train_dir / "Tomato___healthy").mkdir(parents=True)
    (train_dir / "Apple___healthy").mkdir()

    assert evaluate._resolve_class_names(
        tmp_path / "outputs" / "model_v1",
        {"data": {"split_path": str(tmp_path / "datasets" / "split")}},
    ) == ["Apple___healthy", "Tomato___healthy"]


def test_resolve_class_names_rejects_missing_sources(tmp_path: Path) -> None:
    with pytest.raises(FileNotFoundError, match="Labels file and training directory"):
        evaluate._resolve_class_names(
            tmp_path / "outputs" / "model_v1",
            {"data": {"split_path": str(tmp_path / "datasets" / "split")}},
        )


def test_evaluate_orchestrates_reports_and_balance_plot(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    model_path = tmp_path / "outputs" / "model_v1" / "checkpoints" / "best_model.keras"
    model_path.parent.mkdir(parents=True)
    model_path.touch()
    (model_path.parent.parent / "labels.csv").write_text(
        "index,class_name\n0,A\n1,B\n",
        encoding="utf-8",
    )

    train_dir = tmp_path / "split" / "train"
    for class_name, count in {"A": 2, "B": 1}.items():
        class_dir = train_dir / class_name
        class_dir.mkdir(parents=True)
        for index in range(count):
            (class_dir / f"{index}.jpg").write_text("image", encoding="utf-8")

    class FakeLoader:
        def __init__(self, _config: dict) -> None:
            pass

        def get_dataset(self, split: str, shuffle: bool = False) -> str:
            assert (split, shuffle) == ("test", False)
            return "test-dataset"

    class FakeEvaluator:
        def __init__(
            self,
            model: str,
            dataset: str,
            class_names: list[str],
            output_dir: str,
        ) -> None:
            assert (model, dataset, class_names, output_dir) == (
                "loaded-model",
                "test-dataset",
                ["A", "B"],
                str(model_path.parent.parent),
            )

        def run(self) -> dict[str, object]:
            return {
                "y_true": [0, 1],
                "y_pred": [0, 1],
                "y_true_onehot": [[1, 0], [0, 1]],
                "y_prob": [[0.8, 0.2], [0.1, 0.9]],
                "latencies": [1.0, 2.0],
                "y_prob_max": [0.8, 0.9],
                "features": [[0.0], [1.0]],
            }

    class FakeVisualizer:
        calls: list[str] = []

        def __init__(self, output_dir: str, _config: dict) -> None:
            assert output_dir == str(model_path.parent.parent)

        def plot_confusion_matrix(self, *_args: object) -> None:
            self.calls.append("confusion")

        def plot_pr_curve(self, *_args: object) -> None:
            self.calls.append("pr")

        def plot_roc_curve(self, *_args: object) -> None:
            self.calls.append("roc")

        def plot_top_k_accuracy(self, *_args: object) -> None:
            self.calls.append("top-k")

        def plot_latency_histogram(self, *_args: object) -> None:
            self.calls.append("latency")

        def plot_confidence_calibration(self, *_args: object) -> None:
            self.calls.append("confidence")

        def plot_tsne(self, *_args: object) -> None:
            self.calls.append("tsne")

        def plot_class_f1_scores(self, *_args: object) -> None:
            self.calls.append("f1")

        def plot_data_balance(
            self,
            counts: list[int],
            weights: list[float],
            classes: list[str],
        ) -> None:
            self.calls.append("balance")
            assert counts == [2, 1]
            assert weights == [0.75, 1.5]
            assert classes == ["A", "B"]

    monkeypatch.setattr(
        evaluate.ConfigLoader,
        "load",
        lambda _path: {"data": {"split_path": str(tmp_path / "split")}},
    )
    monkeypatch.setattr(evaluate.keras.saving, "load_model", lambda _path: "loaded-model")
    monkeypatch.setattr(evaluate, "PlantDataLoader", FakeLoader)
    monkeypatch.setattr(evaluate, "Evaluator", FakeEvaluator)
    monkeypatch.setattr(evaluate, "Visualizer", FakeVisualizer)

    evaluate.evaluate(str(model_path), "config.yaml")

    assert FakeVisualizer.calls == [
        "confusion",
        "pr",
        "roc",
        "top-k",
        "latency",
        "confidence",
        "tsne",
        "f1",
        "balance",
    ]


def test_main_exits_with_error_when_evaluation_fails(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(evaluate, "evaluate", lambda *_args: (_ for _ in ()).throw(ValueError))

    with pytest.raises(SystemExit) as exc_info:
        evaluate.main(["--model", "missing.keras"])

    assert exc_info.value.code == 1
