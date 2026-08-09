// Tests error normalization into domain-specific exception types.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/errors/app_exceptions.dart';
import 'package:mobile/core/errors/error_handler.dart';

void main() {
  group('AppExceptions', () {
    test('NetworkException has correct defaults', () {
      const exception = NetworkException();
      expect(exception.message, 'Network error');
      expect(exception.details, isNull);
    });

    test('StorageException includes details', () {
      const exception = StorageException('/path/to/file');
      expect(exception.message, 'Storage error');
      expect(exception.details, '/path/to/file');
    });

    test('ModelException has correct message', () {
      const exception = ModelException('Model load failed');
      expect(exception.message, 'Model error');
      expect(exception.details, 'Model load failed');
    });

    test('CameraPermissionException has correct message', () {
      const exception = CameraPermissionException();
      expect(exception.message, 'Camera denied');
    });
  });

  group('ErrorHandler', () {
    test('getMessage returns correct message for NetworkException', () {
      const exception = NetworkException();
      final message = ErrorHandler.getMessage(exception);
      expect(message, 'Network error');
    });

    test('getMessage returns correct message for StorageException', () {
      const exception = StorageException();
      final message = ErrorHandler.getMessage(exception);
      expect(message, 'Storage error');
    });

    test('getMessage returns fallback for unknown error', () {
      final message = ErrorHandler.getMessage(Exception('Unknown'));
      expect(message, 'An error occurred');
    });

    test('wrap maps unknown error to UnexpectedException', () {
      final error = Exception('Some error');
      final wrapped = ErrorHandler.wrap(error);
      expect(wrapped, isA<UnexpectedException>());
      expect(wrapped.details, contains('Some error'));
    });
  });
}
