"""Manage versioned output directories for model training artifacts."""

from pathlib import Path


class PathManager:
    def __init__(self, config: dict, base_root: str = "outputs") -> None:
        # Allocate a new model version for every training run.
        paths_config = config.get("paths", {})
        configured_root = config.get("output_dir")
        if configured_root is None and isinstance(paths_config, dict):
            configured_root = paths_config.get("output_dir")
        self.base_dir = str(Path(configured_root or base_root))
        self.version_dir = str(self._create_next_version_dir())
        self._create_dirs()

    def _create_next_version_dir(self) -> Path:
        # Ensure the root output area exists before scanning existing versions.
        base_dir = Path(self.base_dir)
        base_dir.mkdir(parents=True, exist_ok=True)

        existing = [path.name for path in base_dir.iterdir() if path.name.startswith("model_v")]

        # Ignore malformed paths so manual files do not block training.
        versions = []
        for name in existing:
            try:
                v_num = int(name.removeprefix("model_v"))
                versions.append(v_num)
            except ValueError:
                continue

        next_version = max(versions, default=0) + 1
        while True:
            candidate = base_dir / f"model_v{next_version}"
            try:
                candidate.mkdir(exist_ok=False)
                return candidate
            except FileExistsError:
                next_version += 1

    def _create_dirs(self) -> None:
        # Mirror the artifact structure consumed by evaluation and reporting.
        version_dir = Path(self.version_dir)
        for directory in ["checkpoints", "figures", "tables"]:
            (version_dir / directory).mkdir(exist_ok=True)
