
# Burundi Cassava Leaf Disease Detection (Edge AI)

An offline, edge-deployable deep learning system for cassava leaf disease diagnosis designed for smallholder farming environments in Burundi. The pipeline adapts a lightweight **MobileNetV3-Large** architecture, applies **INT8 Post-Training Static Quantization (PTQ)**, and deploys the model within a cross-platform **Flutter** mobile application running natively on Android with zero cloud dependencies.


## Repository Structure

- `configs/` — Configuration YAML files defining model hyperparameters, dataset paths, and training settings.
- `datasets/` — Raw and stratified partition folders (`raw/`, `split/train/`, `split/val/`, `split/test/`).
- `mobile/` — Flutter mobile application (Android) running offline inference via native TFLite C++ bindings.
- `scripts/` — Dataset download and preparation scripts.
- `src/` — Machine learning pipeline:
  - `src/core/` — Configuration and pipeline utilities.
  - `src/data/` — Dataset loaders, preprocessing, and augmentation pipelines.
  - `src/models/` — MobileNetV3-Large architecture and classification head.
  - `src/cli/` — CLI commands for training, evaluation, and TFLite export.
- `outputs/` — Checkpoints (`best_model.keras`), quantized models, and evaluation metrics (confusion matrices, ROC curves).


## Prerequisites

- **Host Machine:** Windows 11 / Linux / macOS
- **Python:** Version 3.10 or 3.11
- **Java Development Kit:** **OpenJDK 17 (LTS)** *(Required by Gradle 8.14 and Kotlin DSL)*
- **Flutter SDK:** Version 3.19+ (Channel stable)
- **Android SDK:** Platform API 34+


## Setup & Execution Guide

### 1. Python Environment & Data Preparation

1. **Create and activate a virtual environment:**
   ```powershell
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1

    ```

2. **Install Python dependencies:**
    ```powershell
    pip install -r requirements.txt

    ```


3. **Download and prepare dataset splits:**
    ```powershell
    # Downloads the raw dataset
    python scripts/download_dataset.py

    # Splits data into stratified train (80%), validation (10%), and test (10%) sets
    python scripts/prepare_data.py

    ```




### 2. Model Training, Evaluation & TFLite Export

1. **Train the MobileNetV3-Large model:**
    ```powershell
    python -m src.cli.train --config configs/config.yaml

    ```


*Trains in two phases (frozen backbone followed by fine-tuning), restoring optimal checkpoint weights at the minimum validation loss.*

2. **Evaluate on the held-out test split:**
    ```powershell
    python -m src.cli.evaluate --model outputs/model_v1/checkpoints/best_model.keras

    ```


*Evaluates across 2,146 unseen test images and outputs confusion matrices and classification reports.*

3. **Export to INT8 Quantized TFLite:**
    ```powershell
    python -m src.cli.export --model outputs/model_v1/checkpoints/best_model.keras

    ```


*Calibrates using a 100-sample representative validation set, compresses the model from ~31 MB to ~3.4 MB, and copies the model and `labels.txt` to `mobile/assets/`.*


### 3. Mobile Application (Flutter & Android)

1. **Configure Flutter JDK:**
Ensure Flutter points to OpenJDK 17:
    ```powershell
    flutter config --jdk-dir "C:\Program Files\Eclipse Adoptium\jdk-17.0.14.7-hotspot"

    ```


2. **Build and run the application on device:**
Connect your physical Android smartphone (e.g., Pixel 7a) with USB Debugging enabled:
    ```powershell
    cd mobile
    flutter pub get
    flutter run --android-skip-build-dependency-validation

    ```


3. **Build the Standalone Release APK:**
    ```powershell
    flutter build apk --release --android-skip-build-dependency-validation

    ```


*Output APK:* `mobile/build/app/outputs/flutter-apk/app-release.apk`


## Technical & Architecture Highlights

* **Zero-Connectivity Guarantee:** The Android client omits the `android.permission.INTERNET` permission entirely, enforcing 100% offline inference and privacy at the operating-system level.
* **Bytecode Uniformity:** Root and app `build.gradle.kts` enforce `JavaVersion.VERSION_17` and `jvmTarget = "17"` across all plugin submodules (`tflite_flutter`, `shared_preferences_android`).
* **Zero-Copy Loading:** Configured with `aaptOptions { noCompress += "tflite" }` so the 3.4 MB model is memory-mapped directly from flash storage without decompression overhead.
* **Multilingual Advisory:** Embedded offline agronomic knowledge store providing management guidance in **Kirundi**, **French**, and **English**.


## Acknowledgments & Attribution

* **Original Project Basis:** This project builds upon and extends the architectural foundation of the **GreenHealer** project, adapting its mobile edge AI vision for localized cassava crop pathologies and offline agronomic deployment in Burundi.
* **Dataset Provenance:** The cassava disease image collection originates from the **Makerere University AI Lab** in collaboration with Uganda's **National Crops Resources Research Institute (NaCRRI)** (Mwebaze et al., 2019), made available via the Kaggle Cassava Leaf Disease Classification challenge under the CC BY 4.0 license.


## License

This project is licensed under the MIT License — see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.


