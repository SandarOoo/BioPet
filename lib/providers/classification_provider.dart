import 'package:biopet/models/breed.dart';
import 'package:biopet/services/classification_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/history_service.dart';

class ClassificationProvider extends ChangeNotifier {
  final ClassificationService _classificationService;
  final HistoryService _historyService;
  final ImagePicker _imagePicker = ImagePicker();

  ClassificationProvider({
    required ClassificationService classificationService,
    required HistoryService historyService,
  })  : _classificationService = classificationService,
        _historyService = historyService;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _imagePath;
  List<EachBreed> _breedList = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get imagePath => _imagePath;
  List<EachBreed> get breedList => _breedList;
  String? get errorMessage => _errorMessage;
  bool get hasResult => _breedList.isNotEmpty;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      await _classificationService.initialize();
      _isInitialized = true;
    } catch (error, stackTrace) {
      _isInitialized = false;

      debugPrint('CLASSIFICATION INITIALIZATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _setError(
        'Failed to initialize AI model: $error',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      _clearError();

      final result = await _imagePicker.pickImage(
        source: source,
      );

      if (result == null) {
        return;
      }

      _imagePath = result.path;
      _breedList = [];
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('IMAGE PICK ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _setError(
        'Failed to pick image: $error',
      );
    }
  }

  Future<void> classifyImage(String userId) async {
    if (_imagePath == null || _imagePath!.isEmpty) {
      _setError('No image selected.');
      return;
    }

    if (!_isInitialized) {
      await initialize();

      if (!_isInitialized) {
        _setError(
          'AI model could not be initialized. '
          'Please restart the app and try again.',
        );
        return;
      }
    }

    try {
      _setLoading(true);
      _clearError();

      _breedList = await _classificationService.processImageFile(
        _imagePath!,
      );

      if (_breedList.isNotEmpty) {
        await _historyService.saveClassification(
          userId,
          _imagePath!,
          _breedList,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('CLASSIFICATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _setError(
        'Classification failed: $error',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Used by Newfeed. It checks a prepared image with the existing local
  /// MobileNet model and does not save it to classification history.
  Future<PetImageValidationResult> validatePetImageForPost(
    String imagePath,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      throw StateError(
        _errorMessage ?? 'The local AI model could not be initialized.',
      );
    }

    return _classificationService.validatePetImageFile(
      imagePath,
    );
  }

  /// Checks every selected Newfeed image in order.
  Future<List<PetImageValidationResult>> validatePetImagesForPost(
    Iterable<String> imagePaths,
  ) async {
    final results = <PetImageValidationResult>[];

    for (final imagePath in imagePaths) {
      results.add(
        await validatePetImageForPost(imagePath),
      );
    }

    return results;
  }

  void clearResults() {
    _imagePath = null;
    _breedList = [];
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _classificationService.dispose();
    super.dispose();
  }
}
