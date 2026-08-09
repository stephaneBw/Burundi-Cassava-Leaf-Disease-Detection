// Loads disease library content from bundled JSON assets.

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/disease_detail_model.dart';

class LibraryDataSource {
  static final Map<String, Future<Map<String, dynamic>>> _cache = {};

  static Future<DiseaseDetailModel?> getDetail(String diseaseId, String languageCode) async {
    try {
      final String fileName = languageCode == 'tr' ? 'diseases_tr.json' : 'diseases_en.json';
      final decodedJson = await _loadLibrary(fileName);

      final Map<String, dynamic>? diseaseData = decodedJson[diseaseId] as Map<String, dynamic>?;

      if (diseaseData == null) {
        return null;
      }

      return DiseaseDetailModel(
        id: diseaseId,
        symptoms: List<String>.from(diseaseData['symptoms'] as List<dynamic>),
        treatment: List<String>.from(diseaseData['treatment'] as List<dynamic>),
        prevention: List<String>.from(diseaseData['prevention'] as List<dynamic>),
      );
    } catch (error, stackTrace) {
      dev.log(
        'Failed to load disease detail',
        error: error,
        stackTrace: stackTrace,
        name: 'LibraryDataSource',
      );
      return null;
    }
  }

  static Future<Map<String, dynamic>> _loadLibrary(String fileName) {
    return _cache.putIfAbsent(fileName, () async {
      final jsonString = await rootBundle.loadString('assets/data/$fileName');
      return compute(_decodeDiseaseLibrary, jsonString);
    });
  }
}

Map<String, dynamic> _decodeDiseaseLibrary(String jsonString) {
  return json.decode(jsonString) as Map<String, dynamic>;
}
