// Tests disease library coverage for all bundled PlantVillage classes.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/repositories/disease_repository.dart';

void main() {
  group('DiseaseRepository', () {
    test('contains all disease and healthy library records', () {
      final diseases = DiseaseRepository().getAllDiseases();
      final keys = diseases.map((disease) => disease.localizationKey).toSet();

      expect(diseases.length, 38);
      expect(keys, contains('dsAppleHealthy'));
      expect(keys, contains('dsTomatoHealthy'));
      expect(keys, contains('dsTomatoMosaic'));
    });
  });
}
