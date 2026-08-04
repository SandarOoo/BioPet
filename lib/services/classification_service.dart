import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:biopet/helper/isolate_inference.dart';
import 'package:biopet/models/breed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PetImageValidationResult {
  final bool allowed;
  final String? species;
  final String topLabel;
  final double topConfidence;
  final double petProbability;
  final String message;

  const PetImageValidationResult({
    required this.allowed,
    required this.species,
    required this.topLabel,
    required this.topConfidence,
    required this.petProbability,
    required this.message,
  });
}

class ClassificationService {
  late Interpreter _interpreter;
  late List<String> _labels;
  late IsolateInference _isolateInference;
  late Tensor _inputTensor;
  late Tensor _outputTensor;

  static const String _modelPath =
      'assets/models/mobilenet_quant.tflite';
  static const String _labelsPath = 'assets/models/labels.txt';

  bool _isInitialized = false;
  bool _isInitializing = false;

  bool get isInitialized => _isInitialized;

  Set<String> _dogLabels = <String>{};
  Set<String> _catLabels = <String>{};

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    while (_isInitializing) {
      await Future<void>.delayed(const Duration(milliseconds: 50));

      if (_isInitialized) {
        return;
      }
    }

    _isInitializing = true;

    try {
      await _loadLabels();
      await _loadModel();

      _isolateInference = IsolateInference();
      await _isolateInference.start();

      _isInitialized = true;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _loadModel() async {
    // The model is small and quantized, so CPU inference is fast enough
    // and avoids device-specific GPU/delegate compatibility problems.
    _interpreter = await Interpreter.fromAsset(_modelPath);

    _inputTensor = _interpreter.getInputTensors().first;
    _outputTensor = _interpreter.getOutputTensors().first;
  }

  Future<void> _loadLabels() async {
    final labelText = await rootBundle.loadString(_labelsPath);

    _labels = labelText
        .split(RegExp(r'\r?\n'))
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);

    if (_labels.isEmpty) {
      throw StateError('The classification label file is empty.');
    }

    _buildPetLabelSets();
  }

  void _buildPetLabelSets() {
    final dogs = <String>{
      'dog',
      'domestic dog',
      'puppy',
    };

    final cats = <String>{
      'cat',
      'domestic cat',
      'kitten',
    };

    // This project uses the 1001-label ImageNet MobileNet model.
    // Zero-based labels 152..269 are domestic dog breeds.
    // Zero-based labels 282..286 are domestic cat breeds.
    if (_labels.length >= 287) {
      dogs.addAll(
        _labels.sublist(152, 270).map(_normalizeLabel),
      );

      cats.addAll(
        _labels.sublist(282, 287).map(_normalizeLabel),
      );
    }

    _dogLabels = dogs.map(_normalizeLabel).toSet();
    _catLabels = cats.map(_normalizeLabel).toSet();
  }

  String _normalizeLabel(String value) {
    return value.trim().toLowerCase();
  }

  Future<Map<String, double>> classifyImage(img.Image image) async {
    if (!_isInitialized) {
      throw StateError(
        'ClassificationService is not initialized.',
      );
    }

    final inferenceModel = InferenceModel(
      image,
      _interpreter.address,
      _labels,
      _inputTensor.shape,
      _outputTensor.shape,
    );

    return _runInference(inferenceModel);
  }

  Future<Map<String, double>> _runInference(
      InferenceModel inferenceModel,
      ) async {
    final responsePort = ReceivePort();

    try {
      _isolateInference.sendPort.send(
        inferenceModel..responsePort = responsePort.sendPort,
      );

      final result = await responsePort.first.timeout(
        const Duration(seconds: 25),
      );

      if (result is! Map) {
        throw StateError('The local AI returned an invalid result.');
      }

      return Map<String, double>.from(result);
    } on TimeoutException {
      throw TimeoutException(
        'Local image classification took too long.',
      );
    } finally {
      responsePort.close();
    }
  }

  Future<Map<String, double>> _classifyImageFile(
      String imagePath,
      ) async {
    final file = File(imagePath);

    if (!await file.exists()) {
      throw FileSystemException(
        'Selected image file was not found.',
        imagePath,
      );
    }

    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw const FormatException(
        'The selected image could not be decoded.',
      );
    }

    return classifyImage(image);
  }

  Future<List<EachBreed>> processImageFile(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    final breedMap = await _classifyImageFile(imagePath);

    final breedList = breedMap.entries
        .map(
          (entry) => EachBreed(
        name: entry.key,
        acc: (entry.value * 100).round(),
      ),
    )
        .where((breed) => breed.acc > 0)
        .toList();

    breedList.sort(
          (a, b) => b.acc.compareTo(a.acc),
    );

    return breedList;
  }

  Future<PetImageValidationResult> validatePetImageFile(
      String imagePath, {
        double minimumTopConfidence = 0.08,
        double minimumPetProbability = 0.20,
      }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final classification = await _classifyImageFile(imagePath);

    if (classification.isEmpty) {
      return const PetImageValidationResult(
        allowed: false,
        species: null,
        topLabel: 'unknown',
        topConfidence: 0,
        petProbability: 0,
        message:
        'ပုံထဲမှာ ခွေး သို့မဟုတ် ကြောင် ရှိ/မရှိ မသေချာပါ။ ပိုရှင်းသောပုံကို ရွေးပါ။',
      );
    }

    final sorted = classification.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = sorted.first;
    final normalizedTopLabel = _normalizeLabel(top.key);
    final topConfidence = top.value;

    final petProbability = classification.entries
        .where((entry) {
      final label = _normalizeLabel(entry.key);

      return _dogLabels.contains(label) ||
          _catLabels.contains(label);
    })
        .fold<double>(
      0,
          (sum, entry) => sum + entry.value,
    );

    String? species;

    if (_dogLabels.contains(normalizedTopLabel)) {
      species = 'dog';
    } else if (_catLabels.contains(normalizedTopLabel)) {
      species = 'cat';
    }

    final allowed = species != null &&
        topConfidence >= minimumTopConfidence &&
        petProbability >= minimumPetProbability;

    if (allowed) {
      return PetImageValidationResult(
        allowed: true,
        species: species,
        topLabel: top.key,
        topConfidence: topConfidence,
        petProbability: petProbability,
        message: species == 'dog'
            ? 'ခွေးပုံဖြစ်ကြောင်း စစ်ဆေးပြီးပါပြီ။'
            : 'ကြောင်ပုံဖြစ်ကြောင်း စစ်ဆေးပြီးပါပြီ။',
      );
    }

    return PetImageValidationResult(
      allowed: false,
      species: species,
      topLabel: top.key,
      topConfidence: topConfidence,
      petProbability: petProbability,
      message:
      'ခွေး သို့မဟုတ် ကြောင် ရှင်းရှင်းလင်းလင်းပါသောပုံကိုသာ တင်နိုင်ပါသည်။',
    );
  }

  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    await _isolateInference.close();
    _interpreter.close();
    _isInitialized = false;
  }
}
