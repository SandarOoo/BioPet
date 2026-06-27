class comment {
  final String userId;
  final String text;


  comment({required this.userId, required this.text});

  factory comment.fromJson(Map<String,dynamic> json) => comment(
      userId: json['userId'] ?? "", text: json['text'] ?? "");
}

class imageData {
  final String data;
  final String contentType;
  final String filename;

  imageData({
    required this.data,
    required this.contentType,
    required this.filename
});

  factory imageData.fromJson(Map<String,dynamic> json) => imageData(
      data: json['data'] ?? "", contentType: json['contentType'] ?? "", filename: json['filename'] ?? "");


}

class Post {
  final String id;
  final String name;
  final String text;
  final DateTime createdAt;   // ✅ add this

  List<String> likes;
  List<comment> comments;
  final List<imageData> images;

  Post({
    required this.id,
    required this.name,
    required this.text,
    required this.likes,
    required this.comments,
    required this.images,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['_id'] ?? '',
    name: json['name'] ?? 'Anonymous',
    text: json['text'] ?? '',
    likes: List<String>.from(json['likes'] ?? []),
    comments: (json['comments'] as List<dynamic>? ?? [])
        .map((c) => comment.fromJson(c))
        .toList(),
    images: (json['images'] as List<dynamic>? ?? [])
        .map((i) => imageData.fromJson(i))
        .toList(),

    createdAt: DateTime.parse(json['createdAt']),
  );
}