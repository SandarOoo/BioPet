import 'dart:convert';
import 'dart:io';

import 'package:biopet/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/post.dart';

class PostApiService {
  // ============================================================
  // BASE URL
  // ============================================================

  static String get _baseUrl =>
      ApiService.baseUrl;

  // ============================================================
  // CURRENT USER CACHE
  // ============================================================

  static String currentUserId = '';

  static String currentUserName = '';

  // ============================================================
  // INIT USER
  // ============================================================

  static Future<void> init() async {
    try {
      currentUserId =
          await ApiService.getUserId() ?? '';

      currentUserName =
          await ApiService.getUserName() ?? '';

      print(
        'POST API USER ID => '
            '$currentUserId',
      );

      print(
        'POST API USER NAME => '
            '$currentUserName',
      );

    } catch (e) {

      print(
        'POST API INIT ERROR => $e',
      );

      currentUserId = '';

      currentUserName = '';
    }
  }

  // ============================================================
  // COMMON HEADERS
  // ============================================================

  static Future<Map<String, String>>
  _headers({
    bool jsonContent = false,
  }) async {

    final token =
    await ApiService.getToken();

    final headers =
    <String, String>{
      'Accept':
      'application/json',
    };

    if (jsonContent) {
      headers['Content-Type'] =
      'application/json';
    }

    if (
    token != null &&
        token.isNotEmpty
    ) {
      headers['Authorization'] =
      'Bearer $token';
    }

    return headers;
  }

  // ============================================================
  // FETCH POSTS
  // ============================================================

  static Future<List<Post>>
  fetchPosts(
      int page,
      ) async {

    final uri = Uri.parse(
      '$_baseUrl/api/posts'
          '?page=$page'
          '&limit=10',
    );

    print(
      'GET POSTS URL => $uri',
    );

    try {

      final response =
      await http.get(
        uri,
        headers:
        await _headers(),
      );

      print(
        'GET POSTS STATUS => '
            '${response.statusCode}',
      );

      print(
        'GET POSTS BODY => '
            '${response.body}',
      );

      if (
      response.statusCode != 200
      ) {
        throw Exception(
          'Failed to load posts: '
              '${response.body}',
        );
      }

      if (
      response.body.isEmpty
      ) {
        return [];
      }

      final decoded =
      jsonDecode(
        response.body,
      );

      if (
      decoded
      is Map<String, dynamic>
      ) {

        final postsData =
        decoded['posts'];

        if (
        postsData is List
        ) {

          return postsData
              .whereType<Map>()
              .map(
                (post) =>
                Post.fromJson(
                  Map<String, dynamic>
                      .from(post),
                ),
          )
              .toList();
        }
      }

      return [];

    } catch (e) {

      print(
        'FETCH POSTS ERROR => $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // CREATE POST WITH IMAGES
  // ============================================================

  static Future<
      Map<String, dynamic>>
  createPostWithImages({
    required String text,
    required List<File>
    imageFiles,
  }) async {

    // ==========================================================
    // GET USER
    // ==========================================================

    final userId =
    await ApiService.getUserId();

    final userName =
    await ApiService.getUserName();

    print(
      '======================================',
    );

    print(
      'CREATE POST REQUEST',
    );

    print(
      'USER ID => $userId',
    );

    print(
      'USER NAME => $userName',
    );

    print(
      'TEXT => $text',
    );

    print(
      'IMAGE COUNT => '
          '${imageFiles.length}',
    );

    print(
      '======================================',
    );

    if (
    userId == null ||
        userId.isEmpty
    ) {
      throw Exception(
        'Not logged in. Please login again.',
      );
    }

    // ==========================================================
    // URL
    // ==========================================================

    final uri = Uri.parse(
      '$_baseUrl/api/posts/create',
    );

    // ==========================================================
    // MULTIPART REQUEST
    // ==========================================================

    final request =
    http.MultipartRequest(
      'POST',
      uri,
    );

    // ==========================================================
    // AUTHORIZATION
    // ==========================================================

    final token =
    await ApiService.getToken();

    request.headers[
    'Accept'] =
    'application/json';

    if (
    token != null &&
        token.isNotEmpty
    ) {
      request.headers[
      'Authorization'] =
      'Bearer $token';
    }

    // ==========================================================
    // TEXT FIELDS
    // ==========================================================

    request.fields[
    'userId'] = userId;

    request.fields[
    'name'] =
        userName ?? 'Unknown';

    request.fields[
    'text'] = text;

    // ==========================================================
    // ADD IMAGES
    // ==========================================================

    for (
    final file
    in imageFiles
    ) {

      // --------------------------------------------------------
      // CHECK FILE EXISTS
      // --------------------------------------------------------

      if (
      !await file.exists()
      ) {

        print(
          '❌ IMAGE FILE NOT FOUND => '
              '${file.path}',
        );

        continue;
      }

      // --------------------------------------------------------
      // FILE NAME
      // --------------------------------------------------------

      final fileName =
          file.path.split(
            Platform.pathSeparator,
          ).last;

      // --------------------------------------------------------
      // MIME TYPE
      // --------------------------------------------------------

      final mimeType =
          lookupMimeType(
            file.path,
          ) ??
              'image/jpeg';

      final mimeParts =
      mimeType.split('/');

      final mainType =
      mimeParts.isNotEmpty
          ? mimeParts[0]
          : 'image';

      final subType =
      mimeParts.length > 1
          ? mimeParts[1]
          : 'jpeg';

      // --------------------------------------------------------
      // FILE SIZE
      // --------------------------------------------------------

      final fileSize =
      await file.length();

      print(
        '======================================',
      );

      print(
        'ADDING IMAGE',
      );

      print(
        'FILE NAME => $fileName',
      );

      print(
        'FILE PATH => ${file.path}',
      );

      print(
        'MIME TYPE => $mimeType',
      );

      print(
        'FILE SIZE => $fileSize bytes',
      );

      print(
        'FIELD NAME => images',
      );

      print(
        '======================================',
      );

      // --------------------------------------------------------
      // MULTIPART FILE
      // --------------------------------------------------------

      final multipartFile =
      await http.MultipartFile.fromPath(
        'images',
        file.path,
        filename: fileName,
        contentType:
        MediaType(
          mainType,
          subType,
        ),
      );

      request.files.add(
        multipartFile,
      );
    }

    // ==========================================================
    // DEBUG BEFORE SEND
    // ==========================================================

    print(
      '======================================',
    );

    print(
      'SENDING MULTIPART REQUEST',
    );

    print(
      'FIELDS => '
          '${request.fields}',
    );

    print(
      'FILES COUNT => '
          '${request.files.length}',
    );

    for (
    final file
    in request.files
    ) {

      print(
        'REQUEST FILE => '
            'field=${file.field}, '
            'filename=${file.filename}, '
            'length=${file.length}',
      );
    }

    print(
      '======================================',
    );

    // ==========================================================
    // SEND REQUEST
    // ==========================================================

    final response =
    await request.send();

    // ==========================================================
    // READ RESPONSE
    // ==========================================================

    final responseBody =
    await response.stream
        .bytesToString();

    print(
      '======================================',
    );

    print(
      'CREATE POST STATUS => '
          '${response.statusCode}',
    );

    print(
      'CREATE POST BODY => '
          '$responseBody',
    );

    print(
      '======================================',
    );

    // ==========================================================
    // EMPTY RESPONSE
    // ==========================================================

    if (
    responseBody.isEmpty
    ) {
      throw Exception(
        'Server returned an empty response.',
      );
    }

    // ==========================================================
    // JSON PARSE
    // ==========================================================

    dynamic decoded;

    try {

      decoded =
          jsonDecode(
            responseBody,
          );

    } catch (e) {

      throw Exception(
        'Invalid server response: '
            '$responseBody',
      );
    }

    // ==========================================================
    // SUCCESS
    // ==========================================================

    if (
    response.statusCode == 201 ||
        response.statusCode == 200
    ) {

      if (
      decoded
      is Map<String, dynamic>
      ) {

        return decoded;
      }

      throw Exception(
        'Invalid create post response.',
      );
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (
    decoded
    is Map<String, dynamic>
    ) {

      final message =
          decoded['message'] ??
              decoded['error'] ??
              'Create post failed';

      throw Exception(
        message.toString(),
      );
    }

    throw Exception(
      'Create post failed: '
          '$responseBody',
    );
  }

  // ============================================================
  // TOGGLE LIKE
  // ============================================================

  static Future<
      Map<String, dynamic>>
  toggleLike(
      String postId,
      ) async {

    if (
    currentUserId.isEmpty
    ) {
      await init();
    }

    if (
    currentUserId.isEmpty
    ) {
      throw Exception(
        'User information not found. Please login again.',
      );
    }

    final response =
    await http.post(
      Uri.parse(
        '$_baseUrl/api/posts/like',
      ),
      headers:
      await _headers(
        jsonContent: true,
      ),
      body:
      jsonEncode({
        'postId':
        postId,

        'userId':
        currentUserId,
      }),
    );

    print(
      'TOGGLE LIKE STATUS => '
          '${response.statusCode}',
    );

    if (
    response.statusCode != 200
    ) {
      throw Exception(
        response.body,
      );
    }

    if (
    response.body.isEmpty
    ) {
      return {};
    }

    final decoded =
    jsonDecode(
      response.body,
    );

    if (
    decoded
    is Map<String, dynamic>
    ) {
      return decoded;
    }

    return {};
  }

  // ============================================================
  // ADD COMMENT
  // ============================================================

  static Future<
      Map<String, dynamic>>
  addComment(
      String postId,
      String text,
      ) async {

    if (
    currentUserId.isEmpty
    ) {
      await init();
    }

    if (
    currentUserId.isEmpty
    ) {
      throw Exception(
        'User information not found. Please login again.',
      );
    }

    final response =
    await http.post(
      Uri.parse(
        '$_baseUrl/api/posts/comment',
      ),
      headers:
      await _headers(
        jsonContent: true,
      ),
      body:
      jsonEncode({
        'postId':
        postId,

        'userId':
        currentUserId,

        'text':
        text,
      }),
    );

    print(
      'ADD COMMENT STATUS => '
          '${response.statusCode}',
    );

    if (
    response.statusCode != 200 &&
        response.statusCode != 201
    ) {
      throw Exception(
        response.body,
      );
    }

    if (
    response.body.isEmpty
    ) {
      return {};
    }

    final decoded =
    jsonDecode(
      response.body,
    );

    if (
    decoded
    is Map<String, dynamic>
    ) {
      return decoded;
    }

    return {};
  }
}