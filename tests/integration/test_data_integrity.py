"""Check real dataset batches for diversity, shape, and normalization bounds."""

from pathlib import Path

import numpy as np
import pytest

from src.core.config import ConfigLoader
from src.data.loader import PlantDataLoader

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATASET_TRAIN_DIR = PROJECT_ROOT / "datasets" / "split" / "train"

pytestmark = pytest.mark.integration


class TestDataIntegrity:
    @pytest.fixture
    def data_pipeline(self):
        # Build the real training pipeline only when the dataset is available.
        config_path = PROJECT_ROOT / "configs" / "config.yaml"
        config = ConfigLoader.load(str(config_path))
        loader = PlantDataLoader(config)
        return loader.get_dataset("train", shuffle=True)

    @pytest.mark.skipif(not DATASET_TRAIN_DIR.exists(), reason="Dataset not available")
    def test_shuffle_produces_diversity(self, data_pipeline):
        images, labels = next(iter(data_pipeline))
        unique_classes = len(np.unique(labels.numpy(), axis=0))
        assert unique_classes > 1, f"Only {unique_classes} class found, shuffle may be broken"

    @pytest.mark.skipif(not DATASET_TRAIN_DIR.exists(), reason="Dataset not available")
    def test_pixel_range_matches_model_input_contract(self, data_pipeline):
        images, _ = next(iter(data_pipeline))
        max_pixel = float(np.max(images))
        min_pixel = float(np.min(images))

        assert max_pixel <= 255.0, f"Max pixel {max_pixel} exceeds 255.0"
        assert min_pixel >= 0.0, f"Min pixel {min_pixel} below 0.0"

    @pytest.mark.skipif(not DATASET_TRAIN_DIR.exists(), reason="Dataset not available")
    def test_batch_shape_correct(self, data_pipeline):
        images, _ = next(iter(data_pipeline))
        assert len(images.shape) == 4, "Images must be 4D: [B, H, W, C]"
        assert images.shape[1] == 224
        assert images.shape[2] == 224
        assert images.shape[3] == 3
