"""Load and validate runtime configuration for the ML pipeline."""

from numbers import Real
from pathlib import Path
from typing import Any

import yaml  # type: ignore[import-untyped]


class ConfigLoader:
    SUPPORTED_BASE_MODELS = frozenset(
        {
            "MobileNetV3Large",
            "MobileNetV3Small",
            "EfficientNetV2B0",
        }
    )
    DEFAULT_SPLIT_RATIO = {"train": 0.8, "val": 0.1, "test": 0.1}
    DEFAULT_PATIENCE = 3

    @staticmethod
    def load(path: str) -> dict[str, Any]:
        # Fail early when the configuration file cannot define a usable mapping.
        config_path = Path(path).expanduser()
        if config_path.suffix.lower() not in {".yaml", ".yml"}:
            raise ValueError("Config file must use a .yaml or .yml extension")

        with config_path.open() as f:
            raw = yaml.safe_load(f)

        if not isinstance(raw, dict):
            raise ValueError("Config file must contain a YAML mapping")

        ConfigLoader._validate(raw)
        return raw

    @staticmethod
    def _validate(raw: dict[str, Any]) -> None:
        # Validate top-level sections before reading nested values.
        required_sections = ["data", "model"]
        for section in required_sections:
            if section not in raw:
                raise ValueError(f"Missing config section: '{section}'")
            if not isinstance(raw[section], dict):
                raise ValueError(f"Config section '{section}' must be a mapping")

        data = raw["data"]
        required_data = ["raw_path", "split_path", "img_size", "batch_size", "seed"]
        for key in required_data:
            if key not in data:
                raise ValueError(f"Missing data config: '{key}'")

        # Keep filesystem inputs explicit so destructive operations can guard them.
        for key in ["raw_path", "split_path"]:
            if not isinstance(data[key], str) or not data[key].strip():
                raise ValueError(f"Data config '{key}' must be a non-empty path string")

        img_size = data["img_size"]
        if (
            not isinstance(img_size, (list, tuple))
            or len(img_size) != 2
            or any(not isinstance(value, int) or value <= 0 for value in img_size)
        ):
            raise ValueError("img_size must have exactly 2 values: [H, W]")

        ConfigLoader._require_positive_int(data["batch_size"], "batch_size")
        ConfigLoader._require_non_negative_int(data["seed"], "seed")

        # Keep the split contract complete and deterministic for all downstream scripts.
        data.setdefault("split_ratio", ConfigLoader.DEFAULT_SPLIT_RATIO.copy())
        ratios = data["split_ratio"]
        if not isinstance(ratios, dict):
            raise ValueError("split_ratio must be a mapping")
        required_splits = {"train", "val", "test"}
        if set(ratios) != required_splits:
            raise ValueError("split_ratio must define train, val, and test")
        if any(not isinstance(value, Real) or value <= 0 for value in ratios.values()):
            raise ValueError("split_ratio values must be positive numbers")
        total = sum(ratios.values())
        if abs(total - 1.0) > 0.01:
            raise ValueError(f"Split ratios must sum to 1.0, got {total}")

        model = raw["model"]
        required_model = [
            "base_model",
            "learning_rate_stage1",
            "learning_rate_stage2",
            "epochs_stage1",
            "epochs_stage2",
        ]
        for key in required_model:
            if key not in model:
                raise ValueError(f"Missing model config: '{key}'")

        if not isinstance(model["base_model"], str) or not model["base_model"].strip():
            raise ValueError("base_model must be a non-empty string")
        if model["base_model"] not in ConfigLoader.SUPPORTED_BASE_MODELS:
            supported = ", ".join(sorted(ConfigLoader.SUPPORTED_BASE_MODELS))
            raise ValueError(
                f"Unsupported base_model '{model['base_model']}'. Supported: {supported}"
            )

        ConfigLoader._require_positive_number(model["learning_rate_stage1"], "learning_rate_stage1")
        ConfigLoader._require_positive_number(model["learning_rate_stage2"], "learning_rate_stage2")
        ConfigLoader._require_positive_int(model["epochs_stage1"], "epochs_stage1")
        ConfigLoader._require_positive_int(model["epochs_stage2"], "epochs_stage2")

        if "fine_tune_fraction" in model:
            fraction = model["fine_tune_fraction"]
            if not isinstance(fraction, Real):
                raise ValueError("fine_tune_fraction must be in the range (0, 1]")
            fraction_value = float(fraction)
            if not 0 < fraction_value <= 1:
                raise ValueError("fine_tune_fraction must be in the range (0, 1]")

        model.setdefault("patience", ConfigLoader.DEFAULT_PATIENCE)
        ConfigLoader._require_non_negative_int(model["patience"], "patience")

        defaults = raw.get("defaults", {})
        if defaults is not None and not isinstance(defaults, dict):
            raise ValueError("Config section 'defaults' must be a mapping")

        default_model_path = (defaults or {}).get("model_path")
        if default_model_path is not None and not isinstance(default_model_path, str):
            raise ValueError("defaults.model_path must be a string or null")

    @staticmethod
    def _require_positive_number(value: Any, key: str) -> None:
        if not isinstance(value, Real) or value <= 0:
            raise ValueError(f"Model config '{key}' must be a positive number")

    @staticmethod
    def _require_positive_int(value: Any, key: str) -> None:
        if not isinstance(value, int) or value <= 0:
            raise ValueError(f"Data/model config '{key}' must be a positive integer")

    @staticmethod
    def _require_non_negative_int(value: Any, key: str) -> None:
        if not isinstance(value, int) or value < 0:
            raise ValueError(f"Data/model config '{key}' must be a non-negative integer")
