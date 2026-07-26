
import 'dart:convert';
import 'dart:io';

import 'package:biopet/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PostApiService {
// ============================================================
// BASE URL
// ============================================================

static String get _baseUrl => ApiService.baseUrl;

// ============================================================
// CURRENT USER CACHE
// ============================================================

static String currentUserId = '';
static String currentUserName = '';

// ============================================================
// INIT USER DATA
// Call this before loading the feed
// ============================================================

static Future<void> init() async {
try {
currentUserId = await ApiService.getUserId() ?? '';
currentUserName = await ApiService.getUserName() ?? '';

print('POST API USER ID => $currentUserId');
print('POST API USER NAME => $currentUserName');
} catch (e) {
print('POST API INIT ERROR => $e');

currentUserId = '';
currentUserName = '';
}
}

// ============================================================
// COMMON HEADERS
// ============================================================

static Future<Map<String, String>> _headers({
bool jsonContent = false,
}) async {
final token = await ApiService.getToken();

final headers = <String, String>{
'Accept': 'application/json',
};

if (jsonContent) {
headers['Content-Type'] = 'application/json';
}

if (token != null && token.isNotEmpty) {
headers['Authorization'] = 'Bearer $token';
}

return headers;
}

// ============================================================
// FETCH POSTS
// GET /api/posts?page=1&limit=10
// ============================================================

static Future<List<Map<String, dynamic>>> fetchPosts(
int page,
) async {
final uri = Uri.parse(
'$_baseUrl/api/posts?page=$page&limit=10',
);

print('======================================');
print('GET POSTS');
print('URL => $uri');
print('======================================');

try {
final response = await http.get(
uri,
headers: await _headers(),
);

print('GET POSTS STATUS => ${response.statusCode}');
print('GET POSTS BODY => ${response.body}');

if (response.statusCode != 200) {
throw Exception(
'Fetch posts failed: ${response.body}',
);
}

if (response.body.isEmpty) {
return [];
}

final decoded = jsonDecode(response.body);

// ========================================================
// BACKEND RESPONSE
//
// {
//   "success": true,
//   "posts": [...]
// }
// ========================================================

if (decoded is Map<String, dynamic>) {
final posts = decoded['posts'];

if (posts is List) {
return posts
    .whereType<Map>()
    .map(
(post) => Map<String, dynamic>.from(post),
)
    .toList();
}
}

// ========================================================
// BACKWARD COMPATIBILITY
//
// [
//   {...},
//   {...}
// ]
// ========================================================

if (decoded is List) {
return decoded
    .whereType<Map>()
    .map(
(post) => Map<String, dynamic>.from(post),
)
    .toList();
}

return [];
} catch (e) {
print('FETCH POSTS ERROR => $e');
rethrow;
}
}

// ============================================================
// CREATE POST WITH IMAGES
//
// POST /api/posts/create
//
// Multipart fields:
// userId
// name
// text
// images[]
// ============================================================

static Future<Map<String, dynamic>> createPostWithImages({
required String text,
required List<File> imageFiles,
}) async {
// ==========================================================
// GET CURRENT USER
// ==========================================================

final userId = await ApiService.getUserId();
final userName = await ApiService.getUserName();

print('======================================');
print('CREATE POST');
print('USER ID => $userId');
print('USER NAME => $userName');
print('TEXT => $text');
print('IMAGE COUNT => ${imageFiles.length}');
print('======================================');

if (userId == null || userId.isEmpty) {
throw Exception(
'Not logged in. Please login again.',
);
}

// ==========================================================
// CREATE MULTIPART REQUEST
// ==========================================================

final uri = Uri.parse(
'$_baseUrl/api/posts/create',
);

final request = http.MultipartRequest(
'POST',
uri,
);

// ==========================================================
// AUTHORIZATION
// ==========================================================

final token = await ApiService.getToken();

request.headers['Accept'] = 'application/json';

if (token != null && token.isNotEmpty) {
request.headers['Authorization'] =
'Bearer $token';
}

// ==========================================================
// FORM FIELDS
// ==========================================================

request.fields['userId'] = userId;

request.fields['name'] =
userName ?? 'Unknown';

request.fields['text'] = text;

// ==========================================================
// ADD IMAGES
// ==========================================================

for (final file in imageFiles) {
if (!await file.exists()) {
print(
'IMAGE FILE NOT FOUND => ${file.path}',
);
continue;
}

final fileName =
file.path.split(Platform.pathSeparator).last;

final mimeType =
lookupMimeType(file.path) ?? 'image/jpeg';

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

print('UPLOADING IMAGE => $fileName');
print('MIME TYPE => $mimeType');

final stream =
http.ByteStream(
file.openRead(),
);

final length =
await file.length();

final multipartFile =
http.MultipartFile(
'images',
stream,
length,
filename: fileName,
contentType: MediaType(
mainType,
subType,
),
);

request.files.add(
multipartFile,
);
}

// ==========================================================
// SEND REQUEST
// ==========================================================

http.StreamedResponse response;

try {
response = await request.send();
} catch (e) {
print(
'CREATE POST NETWORK ERROR => $e',
);

throw Exception(
'Could not connect to server.',
);
}

// ==========================================================
// READ RESPONSE
// ==========================================================

final responseBody =
await response.stream.bytesToString();

print(
'CREATE POST STATUS => ${response.statusCode}',
);

print(
'CREATE POST BODY => $responseBody',
);

// ==========================================================
// EMPTY RESPONSE
// ==========================================================

if (responseBody.isEmpty) {
throw Exception(
'Server returned an empty response.',
);
}

// ==========================================================
// PARSE JSON
// ==========================================================

dynamic decoded;

try {
decoded = jsonDecode(
responseBody,
);
} catch (e) {
throw Exception(
'Invalid server response: $responseBody',
);
}

// ==========================================================
// SUCCESS
//
// Expected:
//
// {
//   "success": true,
//   "post": {...},
//   "ai": {
//      "allowed": true,
//      "category": "pet_related"
//   }
// }
// ==========================================================

if (response.statusCode == 201 ||
response.statusCode == 200) {
if (decoded is Map<String, dynamic>) {
return decoded;
}

throw Exception(
'Invalid create post response.',
);
}

// ==========================================================
// ERROR RESPONSE
// ==========================================================

if (decoded is Map<String, dynamic>) {
final message =
decoded['message'] ??
decoded['error'] ??
'Create post failed';

throw Exception(
message.toString(),
);
}

throw Exception(
'Create post failed: $responseBody',
);
}

// ============================================================
// TOGGLE LIKE
//
// POST /api/posts/like
//
// Body:
// {
//   "postId": "...",
//   "userId": "..."
// }
// ============================================================

static Future<Map<String, dynamic>> toggleLike(
String postId,
) async {
if (currentUserId.isEmpty) {
await init();
}

if (currentUserId.isEmpty) {
throw Exception(
'User information not found. Please login again.',
);
}

final uri = Uri.parse(
'$_baseUrl/api/posts/like',
);

print('======================================');
print('TOGGLE LIKE');
print('POST ID => $postId');
print('USER ID => $currentUserId');
print('======================================');

try {
final response = await http.post(
uri,
headers: await _headers(
jsonContent: true,
),
body: jsonEncode({
'postId': postId,
'userId': currentUserId,
}),
);

print(
'TOGGLE LIKE STATUS => ${response.statusCode}',
);

print(
'TOGGLE LIKE BODY => ${response.body}',
);

if (response.statusCode != 200) {
throw Exception(
'Like failed: ${response.body}',
);
}

if (response.body.isEmpty) {
return {};
}

final decoded =
jsonDecode(response.body);

if (decoded is Map<String, dynamic>) {
return decoded;
}

return {};
} catch (e) {
print(
'TOGGLE LIKE ERROR => $e',
);
rethrow;
}
}

// ============================================================
// ADD COMMENT
//
// POST /api/posts/comment
//
// Body:
// {
//   "postId": "...",
//   "userId": "...",
//   "text": "..."
// }
// ============================================================

static Future<Map<String, dynamic>> addComment(
String postId,
String text,
) async {
if (currentUserId.isEmpty) {
await init();
}

if (currentUserId.isEmpty) {
throw Exception(
'User information not found. Please login again.',
);
}

final uri = Uri.parse(
'$_baseUrl/api/posts/comment',
);

print('======================================');
print('ADD COMMENT');
print('POST ID => $postId');
print('USER ID => $currentUserId');
print('TEXT => $text');
print('======================================');

try {
final response = await http.post(
uri,
headers: await _headers(
jsonContent: true,
),
body: jsonEncode({
'postId': postId,
'userId': currentUserId,
'text': text,
}),
);

print(
'ADD COMMENT STATUS => ${response.statusCode}',
);

print(
'ADD COMMENT BODY => ${response.body}',
);

if (response.statusCode != 200 &&
response.statusCode != 201) {
throw Exception(
'Comment failed: ${response.body}',
);
}

if (response.body.isEmpty) {
return {};
}

final decoded =
jsonDecode(response.body);

if (decoded is Map<String, dynamic>) {
return decoded;
}

return {};
} catch (e) {
print(
'ADD COMMENT ERROR => $e',
);
rethrow;
}
}
}
