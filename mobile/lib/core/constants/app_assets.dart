// Centralizes asset paths for images, models, labels, and data files.

class AppAssets {
  // Model artifacts exported by the Python pipeline.
  static const String labels = 'assets/labels.txt';
  static const String model = 'assets/models/best_model_quantized.tflite';

  // Background images
  static const String bgLight = 'assets/images/backgrounds/home_background_light.png';
  static const String bgDark = 'assets/images/backgrounds/home_background_dark.png';
  static const String bgLibrary = 'assets/images/backgrounds/library_background.png';
  static const String bgHistory = 'assets/images/backgrounds/history_background.png';

  // Branding assets
  static const String logo = 'assets/images/branding/app_logo.png';

  // Character states
  static const String farmerGreet = 'assets/images/farmer/greet.png';
  static const String farmerDiagnosis = 'assets/images/farmer/diagnosis.png';
  static const String farmerResult = 'assets/images/farmer/result.png';
  static const String farmerReading = 'assets/images/farmer/reading.png';
}
