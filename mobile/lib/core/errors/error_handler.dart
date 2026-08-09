// Converts framework and domain errors into user-facing exception types.

import 'dart:developer' as dev;
import 'dart:io';

import 'app_exceptions.dart';

class ErrorHandler {
  static void log(Object error, [StackTrace? stackTrace]) {
    dev.log('Error: $error', error: error, stackTrace: stackTrace, name: 'ErrorHandler');
  }

  static AppException wrap(Object error) {
    if (error is AppException) return error;
    if (error is FileSystemException) return StorageException(error.message);
    return UnexpectedException(error.toString());
  }

  static String getMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'An error occurred';
  }

  static Future<T?> handle<T>(
    Future<T> Function() action, {
    void Function(AppException)? onError,
  }) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      log(e, stackTrace);
      final exception = wrap(e);
      onError?.call(exception);
      return null;
    }
  }

  static Future<T> withDefault<T>(Future<T> Function() action, T defaultValue) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      log(e, stackTrace);
      return defaultValue;
    }
  }
}
