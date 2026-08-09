// Tests semantic color helpers used by the mobile UI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_colors.dart';

void main() {
  group('AppColors', () {
    group('getConfidenceColor', () {
      test('returns healthy for high confidence (>= 0.8)', () {
        expect(AppColors.getConfidenceColor(0.8), AppColors.healthy);
        expect(AppColors.getConfidenceColor(0.9), AppColors.healthy);
        expect(AppColors.getConfidenceColor(1.0), AppColors.healthy);
      });

      test('returns warning for medium confidence (0.5-0.8)', () {
        expect(AppColors.getConfidenceColor(0.5), AppColors.warning);
        expect(AppColors.getConfidenceColor(0.65), AppColors.warning);
        expect(AppColors.getConfidenceColor(0.79), AppColors.warning);
      });

      test('returns error for low confidence (< 0.5)', () {
        expect(AppColors.getConfidenceColor(0.0), AppColors.error);
        expect(AppColors.getConfidenceColor(0.3), AppColors.error);
        expect(AppColors.getConfidenceColor(0.49), AppColors.error);
      });
    });

    test('primary colors are defined correctly', () {
      expect(AppColors.primary, const Color(0xFF2E7D32));
      expect(AppColors.secondary, const Color(0xFF81C784));
    });

    test('status colors match implementation', () {
      expect(AppColors.healthy, const Color(0xFF4CAF50));
      expect(AppColors.warning, const Color(0xFFFF9800));
      expect(AppColors.error, const Color(0xFFF44336));
    });
  });
}
