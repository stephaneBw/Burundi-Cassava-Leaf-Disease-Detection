PYTHON ?= python
PIP := $(PYTHON) -m pip
PYTEST := $(PYTHON) -m pytest
RUFF := $(PYTHON) -m ruff
MYPY := $(PYTHON) -m mypy
FLUTTER ?= flutter
DART ?= dart
DOCKER ?= docker
DOCKER_COMPOSE ?= docker compose
DOCKER_IMAGE ?= plant-disease-edge-ai-ml:local
KAGGLE_DATASET ?= mustafaberatyavas/plantvillage-dataset
MOBILE_DIR := mobile
PYTHON_PATHS := src/ scripts/ tests/
LOCK_FILE := requirements.lock

.PHONY: help upgrade-pip install install-dev setup dataset prepare-data lock format format-check lint typecheck build-check test test-unit test-integration coverage ci ci-python train evaluate export infer docker-build docker-smoke docker-ci-python docker-compose-ci-python docker-dataset docker-prepare-data mobile-get mobile-format mobile-format-check mobile-analyze mobile-test mobile-ci clean

help:
	@echo "Available targets:"
	@echo "  upgrade-pip       Upgrade pip in the active Python environment"
	@echo "  install           Install runtime Python package using requirements.lock constraints"
	@echo "  install-dev       Install runtime and development dependencies using requirements.lock constraints"
	@echo "  setup             Run the platform setup script manually"
	@echo "  dataset           Download or validate the PlantVillage dataset"
	@echo "  prepare-data      Rebuild datasets/split from datasets/raw"
	@echo "  lock              Refresh Python dependency constraints from a clean environment"
	@echo "  format            Format Python code with Ruff"
	@echo "  format-check      Check Python formatting without modifying files"
	@echo "  lint              Run Ruff checks"
	@echo "  typecheck         Run MyPy over src/"
	@echo "  build-check       Build a Python wheel without dependencies"
	@echo "  test              Run all Python tests"
	@echo "  test-unit         Run isolated Python unit tests"
	@echo "  test-integration  Run Python integration tests"
	@echo "  coverage          Run Python tests with coverage reports"
	@echo "  ci-python         Run Python quality gates used by CI"
	@echo "  ci                Run Python and Flutter quality gates used by CI"
	@echo "  docker-build      Build the Python ML Docker image"
	@echo "  docker-smoke      Smoke-test imports inside the Python ML Docker image"
	@echo "  docker-ci-python  Run Python CI gates inside Docker with the repo mounted"
	@echo "  docker-compose-ci-python Run Python CI gates through docker compose"
	@echo "  docker-dataset    Download or validate the dataset inside Docker"
	@echo "  docker-prepare-data Rebuild datasets/split inside Docker"
	@echo "  mobile-get        Install Flutter dependencies from pubspec.lock"
	@echo "  mobile-format     Format Flutter source and tests"
	@echo "  mobile-format-check Check Flutter formatting without modifying files"
	@echo "  mobile-analyze    Run Flutter analyzer"
	@echo "  mobile-test       Run Flutter tests"
	@echo "  mobile-ci         Check Flutter formatting, then run analysis and tests"

upgrade-pip:
	$(PIP) install --upgrade pip

install: upgrade-pip
	$(PIP) install -c $(LOCK_FILE) .

install-dev: upgrade-pip
	$(PIP) install -c $(LOCK_FILE) -e ".[dev]"

setup:
	@echo "Use ./setup.sh on Linux/macOS or setup.bat on Windows."

dataset:
	$(PYTHON) scripts/download_dataset.py --dataset "$(KAGGLE_DATASET)"

prepare-data:
	$(PYTHON) scripts/prepare_data.py

lock:
	@echo "Refreshing $(LOCK_FILE) from the active Python environment."
	@echo "Use a clean virtual environment with only this project and dev extras installed."
	$(PYTHON) -m pip freeze --exclude-editable > $(LOCK_FILE)

format:
	$(RUFF) format $(PYTHON_PATHS)

format-check:
	$(RUFF) format $(PYTHON_PATHS) --check

lint:
	$(RUFF) check $(PYTHON_PATHS)

typecheck:
	$(MYPY) src/

build-check:
	$(PIP) wheel --no-deps --wheel-dir dist .

test:
	$(PYTEST)

test-unit:
	$(PYTEST) tests/unit

test-integration:
	$(PYTEST) tests/integration

coverage:
	$(PYTEST) --cov=src --cov=scripts --cov-report=term-missing --cov-report=xml

ci-python: format-check lint typecheck build-check coverage

ci: ci-python mobile-ci

train:
	$(PYTHON) -m src.cli.train

evaluate:
	$(PYTHON) -m src.cli.evaluate

export:
	$(PYTHON) -m src.cli.export

infer:
	$(PYTHON) -m src.cli.inference

docker-build:
	$(DOCKER) build -t $(DOCKER_IMAGE) .

docker-smoke: docker-build
	$(DOCKER) run --rm $(DOCKER_IMAGE) python -c "import keras; import tensorflow as tf; import src; print(f'TensorFlow {tf.__version__}')"

docker-ci-python: docker-build
	$(DOCKER) run --rm -v "$(CURDIR):/workspace" -w /workspace $(DOCKER_IMAGE) make ci-python

docker-compose-ci-python: docker-build
	$(DOCKER_COMPOSE) run --rm ml

docker-dataset: docker-build
	$(DOCKER_COMPOSE) run --rm ml make dataset KAGGLE_DATASET="$(KAGGLE_DATASET)"

docker-prepare-data: docker-build
	$(DOCKER_COMPOSE) run --rm ml make prepare-data

mobile-get:
	cd $(MOBILE_DIR) && $(FLUTTER) pub get --enforce-lockfile

mobile-format:
	cd $(MOBILE_DIR) && $(DART) format --line-length 100 lib/ test/

mobile-format-check:
	cd $(MOBILE_DIR) && $(DART) format --line-length 100 --set-exit-if-changed lib/ test/

mobile-analyze:
	cd $(MOBILE_DIR) && $(FLUTTER) analyze

mobile-test:
	cd $(MOBILE_DIR) && $(FLUTTER) test

mobile-ci: mobile-format-check mobile-analyze mobile-test

clean:
	$(PYTHON) -c "import shutil; from pathlib import Path; [shutil.rmtree(path, ignore_errors=True) for path in [Path('.pytest_cache'), Path('.ruff_cache'), Path('.mypy_cache'), Path('htmlcov')]]; [path.unlink(missing_ok=True) for path in [Path('.coverage'), Path('coverage.xml')]]"
