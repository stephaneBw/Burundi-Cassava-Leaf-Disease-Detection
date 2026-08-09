"""Test single-image prediction preprocessing, labels, and output mapping."""

from unittest.mock import MagicMock, patch

import numpy as np
import pytest


class TestPredictor:
    @patch("keras.saving.load_model")
    def test_init_with_valid_paths(self, mock_load, sample_config, tmp_path):
        from src.cli.inference import Predictor

        model_path = tmp_path / "model.keras"
        model_path.touch()

        labels_path = tmp_path / "labels.csv"
        labels_path.write_text("index,class_name\n0,Apple___healthy\n1,Tomato___healthy")

        sample_config["defaults"]["model_path"] = str(model_path)

        with patch("src.core.config.ConfigLoader.load", return_value=sample_config):
            predictor = Predictor(
                model_path=str(model_path),
                config_path="configs/config.yaml",
                labels_path=str(labels_path),
            )

        assert len(predictor.class_names) == 2
        assert predictor.class_names[0] == "Apple___healthy"

    def test_load_labels_correct_order(self, tmp_path):
        from src.cli.inference import Predictor

        labels_path = tmp_path / "labels.csv"
        labels_path.write_text("index,class_name\n0,ClassA\n2,ClassC\n1,ClassB\n")

        with patch.object(Predictor, "__init__", lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.class_names = predictor._load_labels(str(labels_path))

        assert predictor.class_names == ["ClassA", "ClassB", "ClassC"]

    def test_load_txt_labels(self, tmp_path):
        from src.cli.inference import Predictor

        labels_path = tmp_path / "labels.txt"
        labels_path.write_text("ClassA\n\nClassB\n")

        with patch.object(Predictor, "__init__", lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.class_names = predictor._load_labels(str(labels_path))

        assert predictor.class_names == ["ClassA", "ClassB"]

    def test_init_rejects_missing_model_path(self, sample_config):
        from src.cli.inference import Predictor

        sample_config["defaults"]["model_path"] = None

        with patch("src.core.config.ConfigLoader.load", return_value=sample_config):
            with pytest.raises(ValueError, match="Invalid model path"):
                Predictor(model_path=None, config_path="configs/config.yaml")

    def test_find_labels_prefers_model_directory(self, tmp_path):
        from src.cli.inference import Predictor

        model_dir = tmp_path / "model_v1" / "checkpoints"
        model_dir.mkdir(parents=True)
        model_path = model_dir / "best_model.keras"
        model_path.touch()

        model_labels = model_dir / "labels.csv"
        version_labels = tmp_path / "model_v1" / "labels.csv"
        model_labels.write_text("index,class_name\n0,ModelDir\n")
        version_labels.write_text("index,class_name\n0,VersionDir\n")

        predictor = Predictor.__new__(Predictor)

        assert predictor._find_labels(str(model_path)) == str(model_labels)

    def test_find_labels_rejects_missing_label_file(self, tmp_path):
        from src.cli.inference import Predictor

        model_path = tmp_path / "model_v1" / "checkpoints" / "best_model.keras"
        model_path.parent.mkdir(parents=True)
        model_path.touch()
        predictor = Predictor.__new__(Predictor)

        with pytest.raises(FileNotFoundError, match="labels.csv or labels.txt"):
            predictor._find_labels(str(model_path))

    def test_load_labels_rejects_non_contiguous_indices(self, tmp_path):
        from src.cli.inference import Predictor

        labels_path = tmp_path / "labels.csv"
        labels_path.write_text("index,class_name\n0,ClassA\n2,ClassC\n")

        predictor = Predictor.__new__(Predictor)

        with pytest.raises(ValueError, match="contiguous"):
            predictor._load_labels(str(labels_path))

    @patch("cv2.imread")
    @patch("cv2.cvtColor")
    @patch("cv2.resize")
    def test_preprocess_keras_keeps_raw_pixel_contract(
        self, mock_resize, mock_cvtcolor, mock_imread, sample_config
    ):
        from src.cli.inference import Predictor

        mock_imread.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_cvtcolor.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_resize.return_value = np.full((224, 224, 3), 127, dtype=np.uint8)

        with patch.object(Predictor, "__init__", lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.config = sample_config
            predictor.image_size = (224, 224)
            predictor.resize_size = (224, 224)
            predictor.is_tflite = False

            result = predictor.preprocess("dummy.jpg")

        assert result.shape == (1, 224, 224, 3)
        assert result.dtype == np.float32
        assert float(result[0, 0, 0, 0]) == 127.0

    @patch("cv2.imread")
    @patch("cv2.cvtColor")
    @patch("cv2.resize")
    def test_preprocess_tflite_uint8(self, mock_resize, mock_cvtcolor, mock_imread, sample_config):
        from src.cli.inference import Predictor

        mock_imread.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_cvtcolor.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_resize.return_value = np.full((224, 224, 3), 127, dtype=np.uint8)

        with patch.object(Predictor, "__init__", lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.config = sample_config
            predictor.image_size = (224, 224)
            predictor.resize_size = (224, 224)
            predictor.is_tflite = True
            predictor.input_details = [{"dtype": np.uint8}]

            result = predictor.preprocess("dummy.jpg")

        assert result.shape == (1, 224, 224, 3)
        assert result.dtype == np.uint8

    @patch("cv2.imread")
    @patch("cv2.cvtColor")
    @patch("cv2.resize")
    def test_preprocess_tflite_float_keeps_raw_pixel_contract(
        self, mock_resize, mock_cvtcolor, mock_imread, sample_config
    ):
        from src.cli.inference import Predictor

        mock_imread.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_cvtcolor.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_resize.return_value = np.full((224, 224, 3), 127, dtype=np.uint8)

        with patch.object(Predictor, "__init__", lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.config = sample_config
            predictor.image_size = (224, 224)
            predictor.resize_size = (224, 224)
            predictor.is_tflite = True
            predictor.input_details = [{"dtype": np.float32}]

            result = predictor.preprocess("dummy.jpg")

        assert result.shape == (1, 224, 224, 3)
        assert result.dtype == np.float32
        assert float(result[0, 0, 0, 0]) == 127.0

    @patch("cv2.imread")
    @patch("cv2.cvtColor")
    @patch("cv2.resize")
    def test_preprocess_uses_cv2_width_height_order(
        self, mock_resize, mock_cvtcolor, mock_imread, sample_config
    ):
        from src.cli.inference import Predictor

        mock_imread.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_cvtcolor.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_resize.return_value = np.zeros((128, 256, 3), dtype=np.uint8)

        with patch.object(Predictor, "__init__", lambda x, *args, **kwargs: None):
            predictor = Predictor.__new__(Predictor)
            predictor.config = sample_config
            predictor.image_size = (128, 256)
            predictor.resize_size = (256, 128)
            predictor.is_tflite = False

            predictor.preprocess("dummy.jpg")

        mock_resize.assert_called_once()
        assert mock_resize.call_args.args[1] == (256, 128)

    def test_predict_rejects_model_index_without_label(self):
        from src.cli.inference import Predictor

        predictor = Predictor.__new__(Predictor)
        predictor.is_tflite = False
        predictor.class_names = ["OnlyClass"]
        predictor.preprocess = MagicMock(return_value=np.zeros((1, 224, 224, 3), dtype=np.float32))
        predictor.model = MagicMock()
        predictor.model.predict.return_value = np.array([[0.1, 0.9]])

        with pytest.raises(ValueError, match="only 1 labels"):
            predictor.predict("leaf.jpg")

    def test_validate_label_contract_rejects_empty_labels(self):
        from src.cli.inference import Predictor

        predictor = Predictor.__new__(Predictor)
        predictor.class_names = []
        predictor.is_tflite = False

        with pytest.raises(ValueError, match="No labels loaded"):
            predictor._validate_label_contract()

    def test_validate_label_contract_rejects_tflite_output_mismatch(self):
        from src.cli.inference import Predictor

        predictor = Predictor.__new__(Predictor)
        predictor.class_names = ["A"]
        predictor.is_tflite = True
        predictor.output_details = [{"shape": np.array([1, 2])}]

        with pytest.raises(ValueError, match="Label count"):
            predictor._validate_label_contract()


class TestPredictorIntegration:
    @patch("keras.saving.load_model")
    def test_predict_returns_valid_output(
        self, mock_load, sample_config, temp_image_path, tmp_path
    ):
        from src.cli.inference import Predictor

        mock_model = MagicMock()
        mock_model.predict.return_value = np.array([[0.1, 0.9]])
        mock_load.return_value = mock_model

        labels_path = tmp_path / "labels.csv"
        labels_path.write_text("index,class_name\n0,Diseased\n1,Healthy")

        model_path = tmp_path / "model.keras"
        model_path.touch()

        sample_config["defaults"]["model_path"] = str(model_path)

        with patch("src.core.config.ConfigLoader.load", return_value=sample_config):
            predictor = Predictor(
                model_path=str(model_path),
                config_path="configs/config.yaml",
                labels_path=str(labels_path),
            )

            label, confidence = predictor.predict(temp_image_path)

        assert label == "Healthy"
        assert 0.0 <= confidence <= 1.0


def test_main_prints_prediction_result(monkeypatch, capsys):
    from src.cli import inference

    class FakePredictor:
        def __init__(self, model_path, config_path, labels_path) -> None:
            assert (model_path, config_path, labels_path) == (
                "model.keras",
                "config.yaml",
                "labels.csv",
            )

        def predict(self, image_path: str) -> tuple[str, float]:
            assert image_path == "leaf.jpg"
            return "Healthy", 0.9876

    monkeypatch.setattr(inference, "Predictor", FakePredictor)

    inference.main(
        [
            "--image",
            "leaf.jpg",
            "--model",
            "model.keras",
            "--config",
            "config.yaml",
            "--labels",
            "labels.csv",
        ]
    )

    captured = capsys.readouterr()
    assert "Result: Healthy (0.9876)" in captured.out
    assert "Latency:" in captured.out


def test_main_exits_with_error_when_prediction_fails(monkeypatch, capsys):
    from src.cli import inference

    class FailingPredictor:
        def __init__(self, *_args: object) -> None:
            raise ValueError("bad model")

    monkeypatch.setattr(inference, "Predictor", FailingPredictor)

    with pytest.raises(SystemExit) as exc_info:
        inference.main(["--image", "leaf.jpg"])

    captured = capsys.readouterr()
    assert exc_info.value.code == 1
    assert "inference failed" in captured.err
