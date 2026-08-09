// Tests model-label mapping into localized display metadata.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/disease_label_mapper.dart';

void main() {
  group('DiseaseLabelMapper', () {
    group('getJsonKey', () {
      test('returns correct key for Apple scab', () {
        final result = DiseaseLabelMapper.getJsonKey('Apple___Apple_scab');
        expect(result, 'dsAppleScab');
      });

      test('returns correct key for Tomato healthy', () {
        final result = DiseaseLabelMapper.getJsonKey('Tomato___healthy');
        expect(result, 'dsTomatoHealthy');
      });

      test('returns correct key for Corn disease', () {
        final result = DiseaseLabelMapper.getJsonKey(
          'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
        );
        expect(result, 'dsCornCercospora');
      });

      test('returns null for unknown label', () {
        final result = DiseaseLabelMapper.getJsonKey('Unknown___Disease');
        expect(result, isNull);
      });

      test('trims whitespace from input', () {
        final result = DiseaseLabelMapper.getJsonKey('  Apple___healthy  ');
        expect(result, 'dsAppleHealthy');
      });

      test('handles all PlantVillage labels', () {
        final labels = [
          'Apple___Apple_scab',
          'Apple___Black_rot',
          'Apple___Cedar_apple_rust',
          'Apple___healthy',
          'Blueberry___healthy',
          'Cherry_(including_sour)___Powdery_mildew',
          'Cherry_(including_sour)___healthy',
          'Grape___Black_rot',
          'Grape___Esca_(Black_Measles)',
          'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
          'Grape___healthy',
          'Orange___Haunglongbing_(Citrus_greening)',
          'Peach___Bacterial_spot',
          'Peach___healthy',
          'Tomato___healthy',
        ];

        for (final label in labels) {
          final result = DiseaseLabelMapper.getJsonKey(label);
          expect(result, isNotNull, reason: 'Failed for label: $label');
        }
      });
    });
  });
}
