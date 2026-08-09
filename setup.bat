@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Bootstrap the Python ML environment, PlantVillage dataset, and optional Flutter packages.
cd /d "%~dp0"

if not defined KAGGLE_DATASET set "KAGGLE_DATASET=mustafaberatyavas/plantvillage-dataset"
if not defined SKIP_DATASET_DOWNLOAD set "SKIP_DATASET_DOWNLOAD=0"
if not defined SKIP_FLUTTER set "SKIP_FLUTTER=0"

set "PYTHON_CMD="
where py >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "PYTHON_CMD=py -3"
) else (
    where python >nul 2>nul && set "PYTHON_CMD=python"
)

if "%PYTHON_CMD%"=="" (
    echo [ERROR] Python 3.11+ was not found on PATH.
    exit /b 1
)

%PYTHON_CMD% -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python 3.11+ is required.
    exit /b 1
)

if not exist ".venv\Scripts\python.exe" (
    echo [INFO] Creating Python virtual environment...
    %PYTHON_CMD% -m venv .venv
    if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
) else (
    echo [INFO] Reusing existing Python virtual environment.
)

set "VENV_PYTHON=.venv\Scripts\python.exe"

echo [INFO] Upgrading Python packaging tools...
"%VENV_PYTHON%" -m pip install --upgrade pip setuptools wheel
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo [INFO] Installing project dependencies and development tools...
"%VENV_PYTHON%" -m pip install -c requirements.lock -e ".[dev]"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo [INFO] Verifying installed Python dependency graph...
"%VENV_PYTHON%" -m pip check
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

if "%SKIP_DATASET_DOWNLOAD%"=="1" (
    echo [INFO] Skipping dataset download because SKIP_DATASET_DOWNLOAD=1.
) else (
    echo [INFO] Downloading or validating PlantVillage dataset...
    "%VENV_PYTHON%" scripts\download_dataset.py --dataset "%KAGGLE_DATASET%"
    if ERRORLEVEL 1 exit /b 1
)

if "%SKIP_FLUTTER%"=="1" (
    echo [INFO] Skipping Flutter package installation because SKIP_FLUTTER=1.
) else if exist "mobile\pubspec.yaml" (
    where flutter >nul 2>nul
    if !ERRORLEVEL! EQU 0 (
        echo [INFO] Installing Flutter packages...
        pushd mobile
        call flutter pub get --enforce-lockfile
        if ERRORLEVEL 1 (
            popd
            exit /b 1
        )
        popd
    ) else (
        echo [WARN] Flutter was not found on PATH. Skipping mobile package installation.
    )
)

echo [OK] Setup completed successfully.
echo [NEXT] Activate Python with: .venv\Scripts\activate

exit /b 0
