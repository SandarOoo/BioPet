class EachBreed {
  final String name;
  final int acc;

  EachBreed({
    required this.name,
    required this.acc,
  });

  /// ✅ ADD THIS (FIX)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'acc': acc,
    };
  }

  /// (optional but recommended)
  factory EachBreed.fromMap(Map<String, dynamic> map) {
    return EachBreed(
      name: map['name']?.toString() ?? '',
      acc: (map['acc'] is int)
          ? map['acc']
          : int.tryParse(map['acc']?.toString() ?? '') ?? 0,
    );
  }
}