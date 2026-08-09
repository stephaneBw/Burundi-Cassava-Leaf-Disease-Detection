// Persists and retrieves scan history from local preferences storage.

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history_model.dart';

class HistoryRepository {
  HistoryRepository(this._prefs);
  final SharedPreferences _prefs;
  static const String _keyHistory = 'scan_history';

  List<ScanHistoryModel> getHistory() {
    final List<String>? jsonList = _prefs.getStringList(_keyHistory);
    if (jsonList == null) return [];

    final history = <ScanHistoryModel>[];
    for (final encodedItem in jsonList) {
      try {
        history.add(ScanHistoryModel.fromJson(json.decode(encodedItem) as Map<String, dynamic>));
      } catch (error, stackTrace) {
        dev.log(
          'Skipping corrupt scan history record',
          error: error,
          stackTrace: stackTrace,
          name: 'HistoryRepository',
        );
      }
    }

    return history..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveScan(ScanHistoryModel scan) async {
    final currentList = List<String>.from(_prefs.getStringList(_keyHistory) ?? const []);
    currentList.add(json.encode(scan.toJson()));
    await _prefs.setStringList(_keyHistory, currentList);
  }

  Future<void> deleteScan(String id) async {
    final List<ScanHistoryModel> currentList = getHistory();
    currentList.removeWhere((item) => item.id == id);
    await _saveList(currentList);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_keyHistory);
  }

  Future<void> _saveList(List<ScanHistoryModel> list) async {
    final List<String> jsonList = list.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList(_keyHistory, jsonList);
  }
}
