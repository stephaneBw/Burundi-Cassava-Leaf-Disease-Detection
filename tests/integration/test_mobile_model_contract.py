"""Verify the bundled mobile model and labels share one inference contract."""

from pathlib import Path

import numpy as np
import pytest
import tensorflow as tf

PROJECT_ROOT = Path(__file__).resolve().parents[2]
MODEL_PATH = PROJECT_ROOT / "mobile" / "assets" / "models" / "best_model_quantized.tflite"
LABELS_PATH = PROJECT_ROOT / "mobile" / "assets" / "labels.txt"

pytestmark = pytest.mark.integration


@pytest.mark.skipif(not MODEL_PATH.exists(), reason="Bundled mobile model is not available")
def test_mobile_tflite_contract_matches_flutter_classifier() -> None:
    # Validate the exact tensor contract expected by the Flutter classifier.
    labels = [line.strip() for line in LABELS_PATH.read_text().splitlines() if line.strip()]

    interpreter = tf.lite.Interpreter(model_path=str(MODEL_PATH))
    interpreter.allocate_tensors()
    input_info = interpreter.get_input_details()[0]
    output_info = interpreter.get_output_details()[0]

    assert input_info["dtype"] == np.float32
    assert tuple(input_info["shape"][1:]) == (224, 224, 3)
    assert output_info["dtype"] == np.float32
    assert int(output_info["shape"][-1]) == len(labels)
