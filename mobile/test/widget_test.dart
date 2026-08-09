// Verifies the mobile app can build inside a widget test harness.

import 'package:flutter_test/flutter_test.dart';

import 'core/app_colors_test.dart' as app_colors;
import 'core/error_handler_test.dart' as error_handler;
import 'data/disease_repository_test.dart' as disease_repository;
import 'data/models_test.dart' as models;
import 'utils/disease_label_mapper_test.dart' as disease_label_mapper;

void main() {
  group('GreenHealer App Tests', () {
    disease_label_mapper.main();
    app_colors.main();
    error_handler.main();
    models.main();
    disease_repository.main();
  });
}
