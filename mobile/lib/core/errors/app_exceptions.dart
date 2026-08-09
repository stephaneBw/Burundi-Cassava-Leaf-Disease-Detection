// Defines typed application exceptions for recoverable failure cases.

abstract class AppException implements Exception {
  const AppException(this.message, [this.details]);
  final String message;
  final String? details;

  @override
  String toString() => details != null ? '$message: $details' : message;
}

// Network and remote-service failures.
class NetworkException extends AppException {
  const NetworkException([String? details]) : super('Network error', details);
}

class TimeoutException extends AppException {
  const TimeoutException([String? details]) : super('Request timeout', details);
}

class ServerException extends AppException {
  const ServerException([String? details]) : super('Server error', details);
}

// Local persistence and file-access failures.
class StorageException extends AppException {
  const StorageException([String? details]) : super('Storage error', details);
}

class FileNotFoundException extends AppException {
  const FileNotFoundException([String? details]) : super('File not found', details);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String? details]) : super('Permission denied', details);
}

// Model loading and inference failures.
class ModelException extends AppException {
  const ModelException([String? details]) : super('Model error', details);
}

class ModelLoadException extends AppException {
  const ModelLoadException([String? details]) : super('Model load failed', details);
}

class InferenceException extends AppException {
  const InferenceException([String? details]) : super('Inference failed', details);
}

// User-image acquisition and processing failures.
class ImageException extends AppException {
  const ImageException([String? details]) : super('Image error', details);
}

class ImageProcessingException extends AppException {
  const ImageProcessingException([String? details]) : super('Processing failed', details);
}

// Platform permission failures.
class CameraPermissionException extends AppException {
  const CameraPermissionException([String? details]) : super('Camera denied', details);
}

class GalleryPermissionException extends AppException {
  const GalleryPermissionException([String? details]) : super('Gallery denied', details);
}

// Application configuration failures.
class ConfigurationException extends AppException {
  const ConfigurationException([String? details]) : super('Config error', details);
}

class UnexpectedException extends AppException {
  const UnexpectedException([String? details]) : super('Unexpected error', details);
}
