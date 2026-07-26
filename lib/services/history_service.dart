import 'package:biopet/services/api_service.dart';
import '../models/breed.dart';
import '../models/history.dart';

class HistoryService {

  /// GET HISTORY
  /// GET HISTORY
  Future<List<EachClassifying>> getHistory(String userId) async {
    print('==============================');
    print('📥 HISTORY SERVICE: GET HISTORY');
    print('👤 USER ID => $userId');

    try {
      final data = await ApiService.getHistory(userId);

      print('📦 RAW DATA => $data');
      print('📊 RAW COUNT => ${data.length}');

      final result = data
          .map<EachClassifying>(
            (item) {
          print('🔍 HISTORY ITEM => $item');

          return EachClassifying.fromMap(
            item as Map<String, dynamic>,
          );
        },
      )
          .toList();

      print('✅ PARSED HISTORY COUNT => ${result.length}');

      for (final item in result) {
        print('🆔 ID => ${item.id}');
        print('📁 IMAGE => ${item.imagePath}');
        print('🐾 BREEDS => ${item.breeds.length}');
        print('🕐 DATE => ${item.timestamp}');
      }

      print('==============================');

      return result;
    } catch (e, stackTrace) {
      print('❌ HISTORY SERVICE ERROR => $e');
      print('📍 STACK => $stackTrace');

      rethrow;
    }
  }

  /// REMOVE ENTRY (FIXED)
  Future<void> removeEntry(String userId, String id) async {
    if (id.isEmpty) {
      throw Exception('Cannot delete entry: missing id');
    }

    await ApiService.deleteHistory(id);
  }

  /// SAVE CLASSIFICATION
  Future<void> saveClassification(
      String userId,
      String imagePath,
      List<EachBreed> breeds,
      ) async {
    final data = {
      'imagePath': imagePath,
      'breeds': breeds.map((b) => b.toMap()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await ApiService.saveClassification(userId, data);
  }

  /// CLEAR ALL HISTORY (FIXED)
  Future<void> clearHistory(String userId) async {
    final items = await getHistory(userId);

    for (final entry in items) {
      if (entry.id.isNotEmpty) {
        await ApiService.deleteHistory(entry.id);
      }
    }
  }
}