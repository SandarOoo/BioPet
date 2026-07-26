class Comment {
  final String userId;
  final String text;

  Comment({
    required this.userId,
    required this.text,
  });

  factory Comment.fromJson(
      Map<String, dynamic> json,
      ) {
    return Comment(
      userId:
      json['userId']?.toString() ?? '',
      text:
      json['text']?.toString() ?? '',
    );
  }
}

// =====================================================
// IMAGE DATA
// =====================================================

class ImageData {
  final String data;
  final String contentType;
  final String filename;

  ImageData({
    required this.data,
    required this.contentType,
    required this.filename,
  });

  factory ImageData.fromJson(
      Map<String, dynamic> json,
      ) {
    return ImageData(
      data:
      json['data']?.toString() ?? '',

      contentType:
      json['contentType']?.toString() ?? '',

      filename:
      json['filename']?.toString() ?? '',
    );
  }
}

// =====================================================
// POST
// =====================================================

class Post {
  final String id;
  final String name;
  final String text;
  final DateTime createdAt;

  List<String> likes;

  List<Comment> comments;

  final List<ImageData> images;

  Post({
    required this.id,
    required this.name,
    required this.text,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.images,
  });

  factory Post.fromJson(
      Map<String, dynamic> json,
      ) {
    return Post(
      id:
      json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      name:
      json['name']?.toString() ??
          'Anonymous',

      text:
      json['text']?.toString() ??
          '',

      createdAt:
      json['createdAt'] != null
          ? DateTime.parse(
        json['createdAt'].toString(),
      )
          : DateTime.now(),

      likes:
      (json['likes'] as List<dynamic>? ?? [])
          .map(
            (e) => e.toString(),
      )
          .toList(),

      comments:
      (json['comments']
      as List<dynamic>? ??
          [])
          .whereType<Map>()
          .map(
            (e) =>
            Comment.fromJson(
              Map<String, dynamic>.from(
                e,
              ),
            ),
      )
          .toList(),

      images:
      (json['images']
      as List<dynamic>? ??
          [])
          .whereType<Map>()
          .map(
            (e) =>
            ImageData.fromJson(
              Map<String, dynamic>.from(
                e,
              ),
            ),
      )
          .toList(),
    );
  }
}