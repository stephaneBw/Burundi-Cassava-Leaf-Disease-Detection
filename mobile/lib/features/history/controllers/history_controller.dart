// Manages diagnosis history state, filters, deletion, and image paths.

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import '../../../data/models/history_filter_model.dart';
import '../../../data/models/scan_history_model.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../services/media/media_service.dart';

class HistoryController extends ChangeNotifier {
  HistoryController(this._repository, this._mediaService);
  final HistoryRepository _repository;
  final MediaService _mediaService;
  List<ScanHistoryModel> _allHistory = [];
  List<ScanHistoryModel> _filteredHistory = [];
  HistoryFilterModel _filter = const HistoryFilterModel();

  List<ScanHistoryModel> get history => List.unmodifiable(_filteredHistory);
  HistoryFilterModel get filter => _filter;

  void loadHistory() {
    _allHistory = _repository.getHistory();
    _applyFilter();
  }

  Future<void> addScan(ScanHistoryModel scan) async {
    await _repository.saveScan(scan);
    loadHistory();
  }

  Future<void> deleteScan(String id) async {
    final itemIndex = _allHistory.indexWhere((element) => element.id == id);
    if (itemIndex != -1) {
      final item = _allHistory[itemIndex];
      // Update the UI optimistically, then restore repository state on failure.
      _allHistory.removeWhere((element) => element.id == id);
      _applyFilter();

      try {
        await _deleteStoredImage(item);
        await _repository.deleteScan(id);
      } catch (error, stackTrace) {
        dev.log(
          'Failed to delete scan history item',
          error: error,
          stackTrace: stackTrace,
          name: 'HistoryController',
        );
        loadHistory();
      }
    }
  }

  Future<void> clearHistory() async {
    final items = List<ScanHistoryModel>.from(_allHistory);
    // Clear the UI optimistically while stored images and preferences are deleted.
    _allHistory = [];
    _applyFilter();

    try {
      for (final item in items) {
        await _deleteStoredImage(item);
      }
      await _repository.clearHistory();
    } catch (error, stackTrace) {
      dev.log(
        'Failed to clear scan history',
        error: error,
        stackTrace: stackTrace,
        name: 'HistoryController',
      );
      loadHistory();
    }
  }

  void updateFilter(HistoryFilterModel newFilter) {
    _filter = newFilter;
    _applyFilter();
  }

  Set<String> getAvailablePlants() {
    return _allHistory.map((e) => _getPlantName(e.diseaseId)).toSet();
  }

  String _getPlantName(String diseaseId) {
    return diseaseId.split('___').first.replaceAll('_', ' ');
  }

  void _applyFilter() {
    _filteredHistory = _allHistory.where((scan) {
      final matchesDate = _checkDateFilter(scan.date);
      final matchesHealth = _checkHealthFilter(scan.diseaseId);
      final matchesPlant = _checkPlantFilter(scan.diseaseId);
      return matchesDate && matchesHealth && matchesPlant;
    }).toList();
    notifyListeners();
  }

  bool _checkDateFilter(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    switch (_filter.dateFilter) {
      case DateFilter.last15Minutes:
        return difference.inMinutes <= 15;
      case DateFilter.lastHour:
        return difference.inHours <= 1;
      case DateFilter.last24Hours:
        return difference.inHours <= 24;
      case DateFilter.lastWeek:
        return difference.inDays <= 7;
      case DateFilter.lastMonth:
        return difference.inDays <= 30;
      case DateFilter.allTime:
        return true;
    }
  }

  bool _checkHealthFilter(String diseaseId) {
    final isHealthy = diseaseId.toLowerCase().contains('healthy');
    switch (_filter.healthFilter) {
      case HealthStatusFilter.healthy:
        return isHealthy;
      case HealthStatusFilter.infected:
        return !isHealthy;
      case HealthStatusFilter.all:
        return true;
    }
  }

  bool _checkPlantFilter(String diseaseId) {
    if (_filter.selectedPlants.isEmpty) return true;
    final plantName = _getPlantName(diseaseId);
    return _filter.selectedPlants.contains(plantName);
  }

  Future<void> _deleteStoredImage(ScanHistoryModel item) async {
    try {
      final file = _mediaService.getFileFromStorage(item.imagePath);
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        // ignore: avoid_slow_async_io
        await file.delete();
      }
    } catch (error, stackTrace) {
      dev.log(
        'Failed to delete stored scan image',
        error: error,
        stackTrace: stackTrace,
        name: 'HistoryController',
      );
    }
  }
}
