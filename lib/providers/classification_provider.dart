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

// ============================================================
// STATE
// ============================================================

  bool _isLoading = false;
  bool _isInitialized = false;

  String? _imagePath;

  List<EachBreed> _breedList = [];

  String? _errorMessage;

// ============================================================
// GETTERS
// ============================================================

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get imagePath => _imagePath;

  List<EachBreed> get breedList => _breedList;

  String? get errorMessage => _errorMessage;

  bool get hasResult => _breedList.isNotEmpty;

// ============================================================
// INITIALIZE MODEL
// ============================================================

  Future<void> initialize() async {
// Already initialized
    if (_isInitialized) {
      print('🤖 ClassificationService already initialized');
      return;
    }


    try {
    print('================================');
    print('🤖 INITIALIZING CLASSIFICATION');
    print('================================');

    _setLoading(true);
    _clearError();

    print('🤖 Loading AI model...');

    await _classificationService.initialize();

    _isInitialized = true;

    print('✅ CLASSIFICATION SERVICE INITIALIZED');
    print('================================');
    } catch (e, stackTrace) {
    _isInitialized = false;

    print('❌ CLASSIFICATION INITIALIZATION ERROR');
    print('ERROR => $e');
    print('STACK => $stackTrace');

    _setError(
    'Failed to initialize AI model: $e',
    );
    } finally {
    _setLoading(false);
    }


  }

// ============================================================
// PICK IMAGE
// ============================================================

  Future<void> pickImage(ImageSource source) async {
    try {
      print('================================');
      print('📸 PICKING IMAGE');
      print('================================');


    _clearError();

    final result = await _imagePicker.pickImage(
    source: source,
    );

    if (result == null) {
    print('⚠️ USER CANCELLED IMAGE PICKER');
    return;
    }

    _imagePath = result.path;

    // Clear previous result
    _breedList = [];

    print('📁 IMAGE SELECTED');
    print('📁 PATH => $_imagePath');

    notifyListeners();
    } catch (e, stackTrace) {
    print('❌ IMAGE PICK ERROR');
    print('ERROR => $e');
    print('STACK => $stackTrace');

    _setError(
    'Failed to pick image: $e',
    );
    }


  }

// ============================================================
// CLASSIFY IMAGE
// ============================================================

  Future<void> classifyImage(String userId) async {
    print('================================');
    print('🤖 CLASSIFY IMAGE START');
    print('================================');


    print('👤 USER ID => $userId');
    print('📁 IMAGE PATH => $_imagePath');
    print('🤖 INITIALIZED => $_isInitialized');

// ------------------------------------------------------------
// CHECK IMAGE
// ------------------------------------------------------------

    if (_imagePath == null ||
    _imagePath!.isEmpty) {
    _setError(
    'No image selected.',
    );

    print('❌ NO IMAGE SELECTED');

    return;
    }

// ------------------------------------------------------------
// CHECK INITIALIZATION
// ------------------------------------------------------------

    if (!_isInitialized) {
    print(
    '⚠️ ClassificationService is not initialized.',
    );

    print(
    '🤖 Trying to initialize automatically...',
    );

    await initialize();

    // Initialization failed
    if (!_isInitialized) {
    _setError(
    'AI model could not be initialized. '
    'Please restart the app and try again.',
    );

    print(
    '❌ INITIALIZATION FAILED',
    );

    return;
    }
    }

// ------------------------------------------------------------
// CLASSIFICATION
// ------------------------------------------------------------

    try {
    _setLoading(true);
    _clearError();

    print('================================');
    print('🚀 CALLING CLASSIFICATION SERVICE');
    print('================================');

    print(
    '📁 IMAGE => $_imagePath',
    );

    _breedList =
    await _classificationService.processImageFile(
    _imagePath!,
    );

    print('================================');
    print('✅ CLASSIFICATION COMPLETED');
    print('================================');

    print(
    '🐾 BREED COUNT => ${_breedList.length}',
    );

    // ----------------------------------------------------------
    // SAVE HISTORY
    // ----------------------------------------------------------

    if (_breedList.isNotEmpty) {
    print(
    '💾 SAVING CLASSIFICATION HISTORY',
    );

    await _historyService.saveClassification(
    userId,
    _imagePath!,
    _breedList,
    );

    print(
    '✅ HISTORY SAVED SUCCESSFULLY',
    );
    } else {
    print(
    '⚠️ NO BREED RESULT RETURNED',
    );
    }
    } catch (e, stackTrace) {
    print('================================');
    print('❌ CLASSIFICATION ERROR');
    print('================================');

    print(
    'ERROR TYPE => ${e.runtimeType}',
    );

    print(
    'ERROR => $e',
    );

    print(
    'STACK TRACE => $stackTrace',
    );

    _setError(
    'Classification failed: $e',
    );
    } finally {
    _setLoading(false);

    print('================================');
    print('🏁 CLASSIFICATION FINISHED');
    print('================================');

    print(
    'IS LOADING => $_isLoading',
    );

    print(
    'HAS RESULT => $hasResult',
    );

    print(
    'BREED COUNT => ${_breedList.length}',
    );

    print(
    'ERROR => $_errorMessage',
    );
    }


  }

// ============================================================
// CLEAR RESULTS
// ============================================================

  void clearResults() {
    _imagePath = null;
    _breedList = [];
    _errorMessage = null;


    notifyListeners();


    }

// ============================================================
// HELPERS
// ============================================================

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

// ============================================================
// DISPOSE
// ============================================================

  @override
  void dispose() {
    _classificationService.dispose();
    super.dispose();
  }
}
