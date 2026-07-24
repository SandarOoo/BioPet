import 'package:biopet/services/classification_service.dart';
import 'package:biopet/models/breed.dart';
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

  // STATE
  bool _isLoading = false;
  String? _imagePath;
  List<EachBreed> _breedList = [];
  String? _errorMessage;

  // GETTERS
  bool get isLoading => _isLoading;
  String? get imagePath => _imagePath;
  List<EachBreed> get breedList => _breedList;
  String? get errorMessage => _errorMessage;
  bool get hasResult => _breedList.isNotEmpty;

  /// INIT MODEL
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await _classificationService.initialize();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// PICK IMAGE
  Future<void> pickImage(ImageSource source) async {
    try {
      _clearError();
      final result = await _imagePicker.pickImage(source: source);

      if (result != null) {
        _imagePath = result.path;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  /// CLASSIFY IMAGE
  Future<void> classifyImage(String userId) async {
    if (_imagePath == null) {
      _setError('No image selected');
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      // CLASSIFY
      _breedList =
      await _classificationService.processImageFile(_imagePath!);

      // SAVE HISTORY (FIXED)
      if (_breedList.isNotEmpty) {
        await _historyService.saveClassification(
          userId,
          _imagePath!,
          _breedList,
        );
      }
    } catch (e) {
      _setError('Classification failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// CLEAR RESULTS
  void clearResults() {
    _imagePath = null;
    _breedList = [];
    _errorMessage = null;
    notifyListeners();
  }

  // HELPERS
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