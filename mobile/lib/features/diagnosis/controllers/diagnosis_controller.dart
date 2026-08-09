// Coordinates image capture, model inference, and history persistence.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../../../data/models/scan_history_model.dart';
import '../../../services/ai/classifier_service.dart';
import '../../../services/media/media_service.dart';
import '../../history/controllers/history_controller.dart';

enum DiagnosisStatus { greeting, analyzing, result, error }

class DiagnosisController extends ChangeNotifier {
  DiagnosisController(this._classifierService, this._historyController, this._mediaService);

  static const Duration _minimumAnalysisDuration = Duration(milliseconds: 900);

  final ClassifierService _classifierService;
  final HistoryController _historyController;
  final MediaService _mediaService;

  DiagnosisStatus _status = DiagnosisStatus.greeting;
  Map<String, dynamic>? _topResult;
  Map<String, dynamic>? _secondResult;
  String? _customBubbleMessage;
  String? _customBubbleTitle;
  int _analysisToken = 0;

  DiagnosisStatus get status => _status;
  Map<String, dynamic>? get topResult => _topResult;
  Map<String, dynamic>? get secondResult => _secondResult;
  String? get customBubbleMessage => _customBubbleMessage;
  String? get customBubbleTitle => _customBubbleTitle;

  Future<void> initialize() async {
    await _classifierService.initialize();
  }

  void reset() {
    _analysisToken++;
    _status = DiagnosisStatus.greeting;
    _topResult = null;
    _secondResult = null;
    _customBubbleMessage = null;
    _customBubbleTitle = null;
    notifyListeners();
  }

  void updateBubbleMessage(String message, {String? title}) {
    _customBubbleMessage = message;
    _customBubbleTitle = title;
    notifyListeners();
  }

  Future<void> analyzeImage(File image) async {
    final token = ++_analysisToken;
    _status = DiagnosisStatus.analyzing;
    _customBubbleMessage = null;
    _customBubbleTitle = null;
    notifyListeners();

    try {
      // Warm up the model and keep the analyzing state visible long enough for UX continuity.
      final minWait = Future<void>.delayed(_minimumAnalysisDuration);
      final predictionFuture = () async {
        await initialize();
        return _classifierService.predict(image);
      }();

      final results = await Future.wait([minWait, predictionFuture]);
      if (token != _analysisToken) return;

      final predictions = results[1] as List<Map<String, dynamic>>;

      if (predictions.isEmpty) {
        throw Exception('No prediction results');
      }

      _topResult = predictions.first;

      if (predictions.length > 1 && (predictions[1]['confidence'] as double) > 0.1) {
        _secondResult = predictions[1];
      } else {
        _secondResult = null;
      }

      await _saveToHistory(image, _topResult!);
      if (token != _analysisToken) return;

      _status = DiagnosisStatus.result;
    } catch (e, stackTrace) {
      if (token != _analysisToken) return;
      ErrorHandler.log(e, stackTrace);
      _status = DiagnosisStatus.error;
    }
    notifyListeners();
  }

  Future<void> _saveToHistory(File image, Map<String, dynamic> result) async {
    final fileName = await _mediaService.saveToPermanentStorage(image);

    final historyItem = ScanHistoryModel(
      id: const Uuid().v4(),
      imagePath: fileName,
      diseaseId: result['label'] as String,
      confidence: (result['confidence'] as num).toDouble(),
      date: DateTime.now(),
    );
    await _historyController.addScan(historyItem);
  }
}
