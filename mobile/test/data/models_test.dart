// Tests serialization and value behavior for mobile data models.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/history_filter_model.dart';
import 'package:mobile/data/models/scan_history_model.dart';

void main() {
  group('ScanHistoryModel', () {
    test('creates instance with required fields', () {
      final model = ScanHistoryModel(
        id: 'test-id',
        imagePath: 'test.jpg',
        diseaseId: 'dsAppleScab',
        confidence: 0.95,
        date: DateTime(2026, 1, 1),
      );

      expect(model.id, 'test-id');
      expect(model.imagePath, 'test.jpg');
      expect(model.diseaseId, 'dsAppleScab');
      expect(model.confidence, 0.95);
    });

    test('serializes to JSON correctly', () {
      final model = ScanHistoryModel(
        id: 'test-id',
        imagePath: 'test.jpg',
        diseaseId: 'dsAppleScab',
        confidence: 0.95,
        date: DateTime(2026, 1, 1, 12, 0, 0),
      );

      final json = model.toJson();

      expect(json['id'], 'test-id');
      expect(json['imagePath'], 'test.jpg');
      expect(json['diseaseId'], 'dsAppleScab');
      expect(json['confidence'], 0.95);
      expect(json['date'], contains('2026-01-01'));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'imagePath': 'test.jpg',
        'diseaseId': 'dsAppleScab',
        'confidence': 0.95,
        'date': '2026-01-01T12:00:00.000',
      };

      final model = ScanHistoryModel.fromJson(json);

      expect(model.id, 'test-id');
      expect(model.diseaseId, 'dsAppleScab');
      expect(model.date.year, 2026);
    });

    test('compares by value', () {
      final first = ScanHistoryModel(
        id: 'same-id',
        imagePath: 'test.jpg',
        diseaseId: 'dsAppleScab',
        confidence: 0.95,
        date: DateTime(2026, 1, 1),
      );
      final second = ScanHistoryModel(
        id: 'same-id',
        imagePath: 'test.jpg',
        diseaseId: 'dsAppleScab',
        confidence: 0.95,
        date: DateTime(2026, 1, 1),
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });

  group('HistoryFilterModel', () {
    test('creates with default values', () {
      const filter = HistoryFilterModel();

      expect(filter.dateFilter, DateFilter.allTime);
      expect(filter.healthFilter, HealthStatusFilter.all);
      expect(filter.selectedPlants, isEmpty);
    });

    test('copyWith creates modified copy', () {
      const original = HistoryFilterModel();
      final modified = original.copyWith(
        dateFilter: DateFilter.lastWeek,
        healthFilter: HealthStatusFilter.healthy,
      );

      expect(modified.dateFilter, DateFilter.lastWeek);
      expect(modified.healthFilter, HealthStatusFilter.healthy);
      expect(original.dateFilter, DateFilter.allTime);
    });

    test('copyWith with selectedPlants', () {
      const original = HistoryFilterModel();
      final modified = original.copyWith(selectedPlants: {'Apple', 'Tomato'});

      expect(modified.selectedPlants, contains('Apple'));
      expect(modified.selectedPlants, contains('Tomato'));
      expect(modified.selectedPlants.length, 2);
    });
  });
}
