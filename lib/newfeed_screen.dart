import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

class Comment {
  final String userId;
  final String text;

  Comment({required this.userId, required this.text});

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    userId: json['userId'] ?? '',
    text: json['text'] ?? '',
  );
}

class ImageData {
  final String data;
  final String contentType;
  final String filename;

  ImageData({
    required this.data,
    required this.contentType,
    required this.filename,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(
    data: json['data'] ?? '',
    contentType: json['contentType'] ?? '',
    filename: json['filename'] ?? '',
  );
}

class Post {
  final String id;
  final String name;
  final String text;
  List<String> likes;
  List<Comment> comments;
  final List<ImageData> images;

  Post({
    required this.id,
    required this.name,
    required this.text,
    required this.likes,
    required this.comments,
    required this.images,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'] ?? 'Anonymous',
    text: json['text'] ?? '',
    likes: List<String>.from(json['likes'] ?? []),
    comments: (json['comments'] as List<dynamic>? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
    images: (json['images'] as List<dynamic>? ?? [])
        .map((i) => ImageData.fromJson(i))
        .toList(),
  );
}

// ─────────────────────────────────────────────
// API SERVICE
// ─────────────────────────────────────────────

class PostApiService {
  // TODO: Replace with your actual base URL (use your computer's IP for phone testing)
  static const String _baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String _baseUrl = 'http://192.168.x.x:3000'; // real device

  static const String _currentUserId = 'user_001';
  static const String _currentUserName = 'Pet Lover';

  static Future<List<Post>> fetchPosts(int page) async {
    final uri = Uri.parse('$_baseUrl/api/posts?page=$page&limit=10');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Post.fromJson(e)).toList();
    }
    throw Exception('Failed to load posts (${response.statusCode})');
  }

  static Future<Post> createPostWithImages({
    required String text,
    required List<File> imageFiles,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/posts/create');

    var request = http.MultipartRequest('POST', uri);

    request.fields['userId'] = _currentUserId;
    request.fields['name'] = _currentUserName;
    request.fields['text'] = text;

    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'images',
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      final Map<String, dynamic> json = jsonDecode(responseBody);
      return Post.fromJson(json['post']);
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }

  static Future<void> toggleLike(String postId) async {
    final uri = Uri.parse('$_baseUrl/api/posts/like');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'postId': postId, 'userId': _currentUserId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to toggle like');
    }
  }

  static Future<void> addComment(String postId, String text) async {
    final uri = Uri.parse('$_baseUrl/api/posts/comment');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'postId': postId,
        'userId': _currentUserId,
        'text': text,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to post comment');
    }
  }

  static String get currentUserId => _currentUserId;
}

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────

class _T {
  static const Color bg = Color(0xFFF4FAF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF3A8C5C);
  static const Color primaryLight = Color(0xFFD6EDDF);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE8F0EA);
  static const double cardRadius = 16;
  static const double chipRadius = 24;
  static const double pagePad = 16;
}

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Post> _posts = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    try {
      final newPosts = await PostApiService.fetchPosts(_currentPage);
      setState(() {
        if (refresh) _posts.clear();
        _posts.addAll(newPosts);
        _currentPage++;
        _hasMore = newPosts.length >= 10;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Could not load posts. Pull to refresh.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLike(int index) async {
    final post = _posts[index];
    final userId = PostApiService.currentUserId;
    final alreadyLiked = post.likes.contains(userId);

    setState(() {
      if (alreadyLiked) {
        post.likes.remove(userId);
      } else {
        post.likes.add(userId);
      }
    });

    try {
      await PostApiService.toggleLike(post.id);
    } catch (_) {
      setState(() {
        if (alreadyLiked) {
          post.likes.add(userId);
        } else {
          post.likes.remove(userId);
        }
      });
      _showSnack('Could not update like. Try again.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(
        onPostCreated: (post) {
          setState(() => _posts.insert(0, post));
          Navigator.pop(context);
          _showSnack('Post shared! 🐾');
        },
      ),
    );
  }

  void _openComments(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        post: _posts[index],
        onCommentAdded: (comment) {
          setState(() => _posts[index].comments.add(comment));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: _T.primary,
        onRefresh: () => _loadPosts(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: _itemCount,
          itemBuilder: _buildItem,
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  int get _itemCount {
    int count = 1 + _posts.length;
    if (_isLoading || _errorMessage != null || !_hasMore) count++;
    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == 0) return _CreatePostBanner(onTap: _openCreatePost);

    final postIndex = index - 1;
    if (postIndex < _posts.length) {
      return _PostCard(
        post: _posts[postIndex],
        currentUserId: PostApiService.currentUserId,
        onLike: () => _handleLike(postIndex),
        onComment: () => _openComments(postIndex),
      );
    }

    if (_isLoading) return const _LoadingFooter();
    if (_errorMessage != null) return _ErrorFooter(message: _errorMessage!, onRetry: _loadPosts);
    return const _EndFooter();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _T.surface,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _T.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Bio Pet Feed',
            style: TextStyle(
              color: _T.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Badge(
            backgroundColor: _T.accent,
            child: const Icon(Icons.notifications_outlined, color: _T.textPrimary),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _T.divider),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _openCreatePost,
      backgroundColor: _T.primary,
      icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
      label: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      elevation: 4,
    );
  }
}

// ─────────────────────────────────────────────
// CREATE POST BANNER
// ─────────────────────────────────────────────

class _CreatePostBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CreatePostBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_T.pagePad, 14, _T.pagePad, 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(_T.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _T.primaryLight,
                child: const Text('🐾', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _T.bg,
                    borderRadius: BorderRadius.circular(_T.chipRadius),
                    border: Border.all(color: _T.divider),
                  ),
                  child: Text(
                    "What's your pet doing? 🐶",
                    style: TextStyle(color: _T.textSecondary, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// POST CARD
// ─────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final Post post;
  final String currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final liked = post.likes.contains(currentUserId);
    final initials = post.name.isNotEmpty ? post.name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(_T.pagePad, 6, _T.pagePad, 6),
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _T.primaryLight,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: _T.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _T.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Just now',
                          style: TextStyle(fontSize: 12, color: _T.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: _T.textSecondary),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Text(
                post.text,
                style: const TextStyle(
                  fontSize: 15,
                  color: _T.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
            // IMAGES GALLERY (NEW)
            if (post.images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final image = post.images[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(image.data.split(',').last),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (post.likes.isNotEmpty || post.comments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    if (post.likes.isNotEmpty)
                      Row(
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 3),
                          Text(
                            '${post.likes.length}',
                            style: TextStyle(fontSize: 12, color: _T.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    const Spacer(),
                    if (post.comments.isNotEmpty)
                      Text(
                        '${post.comments.length} comment${post.comments.length == 1 ? '' : 's'}',
                        style: TextStyle(fontSize: 12, color: _T.textSecondary),
                      ),
                  ],
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: _T.divider),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: liked ? Icons.favorite : Icons.favorite_border,
                      label: liked ? 'Liked' : 'Like',
                      color: liked ? _T.accent : _T.textSecondary,
                      onTap: onLike,
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: 'Comment',
                      color: _T.textSecondary,
                      onTap: onComment,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CREATE POST SHEET (WITH IMAGE PICKER)
// ─────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  final void Function(Post post) onPostCreated;
  const _CreatePostSheet({required this.onPostCreated});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isPosting = false;
  String? _error;

  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage(limit: 10);
    if (pickedImages != null && pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages = pickedImages.map((x) => File(x.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;

    setState(() {
      _isPosting = true;
      _error = null;
    });

    try {
      final post = await PostApiService.createPostWithImages(
        text: text,
        imageFiles: _selectedImages,
      );
      if (mounted) {
        widget.onPostCreated(post);
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      decoration: const BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _T.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('🐾', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Share a pet moment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _T.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'You can select up to 10 images',
            style: TextStyle(fontSize: 12, color: _T.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            autofocus: true,
            style: const TextStyle(fontSize: 15, color: _T.textPrimary),
            decoration: InputDecoration(
              hintText: "What's your pet up to today? 🐶🐱",
              hintStyle: TextStyle(color: _T.textSecondary),
              filled: true,
              fillColor: _T.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text('Pick Images (${_selectedImages.length}/10)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _T.primaryLight,
              foregroundColor: _T.primary,
            ),
          ),
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: _T.accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: _T.accent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_isPosting || (_controller.text.trim().isEmpty && _selectedImages.isEmpty))
                  ? null
                  : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: _T.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_T.chipRadius),
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                'Post',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMMENTS SHEET
// ─────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final Post post;
  final void Function(Comment comment) onCommentAdded;

  const _CommentsSheet({required this.post, required this.onCommentAdded});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await PostApiService.addComment(widget.post.id, text);
      final comment = Comment(userId: PostApiService.currentUserId, text: text);
      widget.onCommentAdded(comment);
      setState(() => widget.post.comments.add(comment));
      _controller.clear();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send comment.')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: const BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _T.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _T.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _T.divider),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: widget.post.comments.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No comments yet. Be the first! 🐾',
                    style: TextStyle(color: _T.textSecondary, fontSize: 14)),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: widget.post.comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = widget.post.comments[i];
                return _CommentTile(comment: c);
              },
            ),
          ),
          const Divider(height: 1, color: _T.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: _T.primaryLight,
                  child: Text('🐾', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendComment(),
                    style: const TextStyle(fontSize: 14, color: _T.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add a comment…',
                      hintStyle: TextStyle(color: _T.textSecondary, fontSize: 14),
                      filled: true,
                      fillColor: _T.bg,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_T.chipRadius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(color: _T.primary, strokeWidth: 2),
                )
                    : IconButton(
                  onPressed: _sendComment,
                  icon: const Icon(Icons.send_rounded),
                  color: _T.primary,
                  iconSize: 26,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final initials = comment.userId.isNotEmpty ? comment.userId[0].toUpperCase() : '?';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: _T.primaryLight,
          child: Text(
            initials,
            style: TextStyle(
              color: _T.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _T.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 13, color: _T.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FOOTER WIDGETS
// ─────────────────────────────────────────────

class _LoadingFooter extends StatelessWidget {
  const _LoadingFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(color: _T.primary, strokeWidth: 2.5),
      ),
    );
  }
}

class _ErrorFooter extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorFooter({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: _T.pagePad),
      child: Column(
        children: [
          Text(message, style: TextStyle(color: _T.textSecondary, fontSize: 14)),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: _T.primary,
              side: const BorderSide(color: _T.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_T.chipRadius),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EndFooter extends StatelessWidget {
  const _EndFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          '🐾  You\'ve seen all posts',
          style: TextStyle(color: _T.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}