import 'dart:io';
import 'dart:isolate';

import 'package:biopet/helper/isolate_inference.dart';
import 'package:biopet/models/breed.dart';
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

/// Service responsible for local TensorFlow Lite classification operations.
class ClassificationService {
  late final Interpreter _interpreter;
  late final List<String> _labels;
  late final IsolateInference _isolateInference;
  late Tensor _inputTensor;
  late Tensor _outputTensor;

  static const String _modelPath =
      'assets/models/mobilenet_quant.tflite';
  static const String _labelsPath = 'assets/models/labels.txt';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Set<String> _dogLabels = <String>{};
  Set<String> _catLabels = <String>{};

  /// Initialize the ML model and isolate inference.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadLabels();
    await _loadModel();

    _isolateInference = IsolateInference();
    await _isolateInference.start();

    _isInitialized = true;
  }

  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }

    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    _interpreter = await Interpreter.fromAsset(
      _modelPath,
      options: options,
    );

    _inputTensor = _interpreter.getInputTensors().first;
    _outputTensor = _interpreter.getOutputTensors().first;
  }

  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(_labelsPath);

    _labels = labelTxt
        .split(RegExp(r'\r?\n'))
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);

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

    // ImageNet labels used by mobilenet_quant.tflite:
    // 152...269 = domestic dog breeds.
    // 282...286 = domestic cat breeds.
    if (_labels.length >= 287) {
      dogs.addAll(
        _labels
            .sublist(152, 270)
            .map(_normalizeLabel),
      );

      cats.addAll(
        _labels
            .sublist(282, 287)
            .map(_normalizeLabel),
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
        'ClassificationService not initialized. Call initialize() first.',
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

    _isolateInference.sendPort.send(
      inferenceModel..responsePort = responsePort.sendPort,
    );

    final results = await responsePort.first;
    responsePort.close();

    return Map<String, double>.from(
      results as Map,
    );
  }

  Future<Map<String, double>> _classifyImageFile(
    String imagePath,
  ) async {
    final imageData = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageData);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    return classifyImage(image);
  }

  /// Process an image and return sorted ImageNet classifications.
  Future<List<EachBreed>> processImageFile(String imagePath) async {
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

  /// Validate a Newfeed image locally without using OpenAI, Gemini,
  /// OpenRouter, Railway variables, or any network request.
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
    final topLabel = _normalizeLabel(top.key);
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

    if (_dogLabels.contains(topLabel)) {
      species = 'dog';
    } else if (_catLabels.contains(topLabel)) {
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
    if (_isInitialized) {
      await _isolateInference.close();
      _interpreter.close();
      _isInitialized = false;
    }
  }
}
