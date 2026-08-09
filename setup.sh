#!/usr/bin/env bash
set -Eeuo pipefail

# Bootstrap the Python ML environment, PlantVillage dataset, and optional Flutter packages.
cd "$(dirname "${BASH_SOURCE[0]}")"

KAGGLE_DATASET="${KAGGLE_DATASET:-mustafaberatyavas/plantvillage-dataset}"
SKIP_DATASET_DOWNLOAD="${SKIP_DATASET_DOWNLOAD:-0}"
SKIP_FLUTTER="${SKIP_FLUTTER:-0}"

if command -v python3 >/dev/null 2>&1; then
  PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_CMD="python"
else
  echo "[ERROR] Python 3.11+ was not found on PATH." >&2
  exit 1
fi

"$PYTHON_CMD" - <<'PY'
import sys

if sys.version_info < (3, 11):
    raise SystemExit("[ERROR] Python 3.11+ is required.")
PY

if [[ ! -x ".venv/bin/python" ]]; then
  echo "[INFO] Creating Python virtual environment..."
  "$PYTHON_CMD" -m venv .venv
else
  echo "[INFO] Reusing existing Python virtual environment."
fi

VENV_PYTHON=".venv/bin/python"

echo "[INFO] Upgrading Python packaging tools..."
"$VENV_PYTHON" -m pip install --upgrade pip setuptools wheel

echo "[INFO] Installing project dependencies and development tools..."
"$VENV_PYTHON" -m pip install -c requirements.lock -e ".[dev]"

echo "[INFO] Verifying installed Python dependency graph..."
"$VENV_PYTHON" -m pip check

if [[ "$SKIP_DATASET_DOWNLOAD" == "1" ]]; then
  echo "[INFO] Skipping dataset download because SKIP_DATASET_DOWNLOAD=1."
else
  echo "[INFO] Downloading or validating PlantVillage dataset..."
  "$VENV_PYTHON" scripts/download_dataset.py --dataset "$KAGGLE_DATASET"
fi

if [[ "$SKIP_FLUTTER" == "1" ]]; then
  echo "[INFO] Skipping Flutter package installation because SKIP_FLUTTER=1."
elif [[ -f "mobile/pubspec.yaml" ]]; then
  if command -v flutter >/dev/null 2>&1; then
    echo "[INFO] Installing Flutter packages..."
    (cd mobile && flutter pub get --enforce-lockfile)
  else
    echo "[WARN] Flutter was not found on PATH. Skipping mobile package installation."
  fi
fi

echo "[OK] Setup completed successfully."
echo "[NEXT] Activate Python with: source .venv/bin/activate"
