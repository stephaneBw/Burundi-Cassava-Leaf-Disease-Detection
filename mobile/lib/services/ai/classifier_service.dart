// Runs TensorFlow Lite image classification in a background isolate.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../core/constants/app_assets.dart';

// Contains only copyable data so Flutter can move inference work to a background isolate.
class InferenceData {
  InferenceData({required this.imageBytes, required this.modelBytes, required this.labels});
  final Uint8List imageBytes;
  final Uint8List modelBytes;
  final List<String> labels;
}

class ClassifierService {
  Uint8List? _modelBuffer;
  List<String> _labels = [];
  Future<void>? _initializeFuture;

  Future<void> initialize() async {
    _initializeFuture ??= _initializeOnce();
    await _initializeFuture;
  }

  Future<void> _initializeOnce() async {
    // Load the model and labels as one contract; either both are ready or inference is blocked.
    await _loadModelBytes();
    await _loadLabels();
  }

  Future<void> _loadModelBytes() async {
    final byteData = await rootBundle.load(AppAssets.model);
    _modelBuffer = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

  Future<void> _loadLabels() async {
    final labelData = await rootBundle.loadString(AppAssets.labels);
    _labels = labelData.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<List<Map<String, dynamic>>> predict(File imageFile) async {
    await initialize();

    if (_modelBuffer == null || _labels.isEmpty) {
      throw Exception('Model not initialized');
    }

    final imageBytes = await imageFile.readAsBytes();

    final inferenceData = InferenceData(
      imageBytes: imageBytes,
      modelBytes: _modelBuffer!,
      labels: _labels,
    );

    return compute(_runInferenceInIsolate, inferenceData);
  }
}

Future<List<Map<String, dynamic>>> _runInferenceInIsolate(InferenceData data) async {
  // Create an isolate-local interpreter so the UI thread never owns native model state.
  final interpreter = Interpreter.fromBuffer(data.modelBytes);

  try {
    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);
    final inputShape = inputTensor.shape;
    final outputShape = outputTensor.shape;

    if (inputShape.length != 4 || outputShape.length < 2) {
      throw Exception('Unsupported model tensor shape');
    }

    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];
    final inputChannels = inputShape[3];
    final outputCount = outputShape.last;

    if (inputChannels != 3) {
      throw Exception('Expected RGB model input');
    }

    if (outputTensor.type != TensorType.float32) {
      throw Exception('Expected float32 model output');
    }

    if (data.labels.length != outputCount) {
      throw Exception('Label count does not match model output count');
    }

    // Decode and orient user images before resizing to the model tensor dimensions.
    var rawImage = img.decodeImage(data.imageBytes);
    if (rawImage == null) {
      throw Exception('Image decode failed');
    }

    rawImage = img.bakeOrientation(rawImage);
    final resized = img.copyResize(rawImage, width: inputWidth, height: inputHeight);

    final inputType = inputTensor.type;
    final isQuantized = (inputType == TensorType.uint8);

    // Build an NHWC tensor that matches the exported TensorFlow Lite model.
    final input = List.generate(
      1,
      (_) => List.generate(
        inputHeight,
        (y) => List.generate(inputWidth, (x) {
          final pixel = resized.getPixel(x, y);
          if (isQuantized) {
            return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
          } else {
            // MobileNetV3 preprocessing is embedded in the exported model graph.
            return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
          }
        }),
      ),
    );

    final output = List<double>.filled(outputCount, 0.0).reshape<double>([1, outputCount]);

    interpreter.run(input, output);

    final outputList = output[0] as List<double>;
    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < outputList.length; i++) {
      results.add({'label': data.labels[i], 'confidence': outputList[i]});
    }

    results.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

    return results.take(5).toList();
  } finally {
    interpreter.close();
  }
}
