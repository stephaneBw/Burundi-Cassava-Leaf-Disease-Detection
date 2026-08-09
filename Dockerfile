FROM python:3.11-slim

ARG APP_VERSION=1.0.0

LABEL org.opencontainers.image.title="Plant Disease Edge AI Diagnosis System" \
    org.opencontainers.image.description="Minimal Python ML environment for quality gates, tests, TensorFlow Lite export, and model artifact workflows." \
    org.opencontainers.image.source="https://github.com/MustafaBeratYavas/plant-disease-edge-ai-diagnosis-system" \
    org.opencontainers.image.version="${APP_VERSION}" \
    org.opencontainers.image.licenses="MIT"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    TF_CPP_MIN_LOG_LEVEL=2 \
    MPLBACKEND=Agg

WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends make libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY README.md LICENSE Makefile pyproject.toml requirements.lock ./
COPY configs ./configs
COPY scripts ./scripts
COPY src ./src
COPY tests ./tests

RUN python -m pip install --upgrade -c requirements.lock setuptools wheel \
    && python -m pip install -c requirements.lock -e ".[dev]" \
    && python -m pip check

CMD ["python"]
