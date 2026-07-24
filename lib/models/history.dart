import 'dart:convert';
import 'package:biopet/models/breed.dart';

class EachClassifying {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final List<EachBreed> breeds;

  EachClassifying({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.breeds,
  });

  /// =========================
  /// FROM MAP (API → MODEL)
  /// =========================
  factory EachClassifying.fromMap(Map<String, dynamic> map) {
    final breedList = <EachBreed>[];

    if (map['breeds'] is List) {
      for (final item in (map['breeds'] as List)) {
        if (item is Map) {
          final name = item['name']?.toString() ?? '';

          final acc = (item['acc'] is int)
              ? item['acc'] as int
              : int.tryParse(item['acc']?.toString() ?? '') ?? 0;

          breedList.add(EachBreed(name: name, acc: acc));
        } else if (item is String) {
          try {
            final m = json.decode(item) as Map<String, dynamic>;

            final name = m['name']?.toString() ?? '';

            final acc = (m['acc'] is int)
                ? m['acc'] as int
                : int.tryParse(m['acc']?.toString() ?? '') ?? 0;

            breedList.add(EachBreed(name: name, acc: acc));
          } catch (_) {
            // ignore invalid json
          }
        }
      }
    }

    return EachClassifying(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      imagePath: map['imagePath']?.toString() ?? '',
      timestamp: DateTime.tryParse(
        map['createdAt']?.toString() ??
            map['timestamp']?.toString() ??
            '',
      ) ??
          DateTime.now(),
      breeds: breedList,
    );
  }

  /// =========================
  /// TO MAP (MODEL → API)
  /// =========================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'breeds': breeds.map((b) => b.toMap()).toList(),
    };
  }

  /// =========================
  /// JSON HELPERS
  /// =========================
  String toJson() => json.encode(toMap());

  factory EachClassifying.fromJson(String source) =>
      EachClassifying.fromMap(json.decode(source));
}