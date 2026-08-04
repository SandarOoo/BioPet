
import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:biopet/Login_Screen.dart';
import 'package:biopet/models/post.dart';
import 'package:biopet/providers/classification_provider.dart';
import 'package:biopet/services/api_service.dart';
import 'package:biopet/services/classification_service.dart';
import 'package:biopet/services/post_api_service.dart';
import 'package:biopet/time_ago.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


// =====================================================
// DESIGN TOKENS
// =====================================================

class _T {
  static const Color bg = Color(0xFFFFF8E7); // Cream
  static const Color surface = Color(0xFFFFFFFF); // White

  static const Color primary = Color(0xFF065F46); // Emerald
  static const Color primaryLight = Color(0xFFA7F3D0); // Mint

  static const Color accent = Color(0xFF10B981); // Fresh green

  static const Color textPrimary = Color(0xFF071426); // Dark navy
  static const Color textSecondary = Color(0xFF64748B); // Soft grey

  static const Color divider = Color(0xFFDDEDE5); // Light mint divider

  static const double cardRadius = 16;
  static const double chipRadius = 24;
  static const double pagePad = 16;
}


// =====================================================
// HOME / NEWS FEED SCREEN
// =====================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final List<Post> _posts = [];

  final ScrollController _scrollController =
  ScrollController();

  int _currentPage = 1;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;

  String? _errorMessage;


// =====================================================
// INIT
// =====================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _onScroll,
    );

    _initialize();
  }


  Future<void> _initialize() async {
    try {
      await PostApiService.init();
    } catch (e) {
      debugPrint(
        'PostApiService init error: $e',
      );
    }

    if (!mounted) return;

    await _loadPosts(
      refresh: true,
    );
  }


// =====================================================
// SCROLL PAGINATION
// =====================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position =
        _scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 300 &&
        !_isLoading &&
        !_isRefreshing &&
        _hasMore) {
      _loadPosts();
    }
  }


// =====================================================
// LOAD POSTS
// =====================================================

  Future<void> _loadPosts({
    bool refresh = false,
  }) async {
    if (_isLoading) {
      return;
    }

    if (refresh) {
      _isRefreshing = true;
      _currentPage = 1;
      _hasMore = true;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Post> newPosts =
      await PostApiService.fetchPosts(
        _currentPage,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (refresh) {
          _posts.clear();
        }

        _posts.addAll(newPosts);

        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage++;

          _hasMore = newPosts.length >= 10;
        }
      });
    } catch (e) {
      debugPrint(
        'LOAD POSTS ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
        'Could not load posts. Please try again.';
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }
// =====================================================
// LIKE POST
// =====================================================

  Future<void> _handleLike(
      int index,
      ) async {
    if (index < 0 ||
        index >= _posts.length) {
      return;
    }

    final Post post =
    _posts[index];

    final String userId =
        PostApiService.currentUserId;

    if (userId.isEmpty) {
      _showSnack(
        'Please login again to like posts.',
      );
      return;
    }

    final bool alreadyLiked =
    post.likes.contains(
      userId,
    );

// Optimistic update
    setState(() {
      if (alreadyLiked) {
        post.likes.remove(
          userId,
        );
      } else {
        post.likes.add(
          userId,
        );
      }
    });

    try {
      await PostApiService.toggleLike(
        post.id,
      );
    } catch (e) {
      debugPrint(
        'LIKE ERROR: $e',
      );

// Rollback
      if (!mounted) {
        return;
      }

      setState(() {
        if (alreadyLiked) {
          if (!post.likes.contains(
            userId,
          )) {
            post.likes.add(
              userId,
            );
          }
        } else {
          post.likes.remove(
            userId,
          );
        }
      });

      _showSnack(
        'Could not update like. Try again.',
      );
    }
  }


// =====================================================
// ADD COMMENT
// =====================================================

  void _openComments(
      int index,
      ) {
    if (index < 0 ||
        index >= _posts.length) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (_) {
        return _CommentsSheet(
          post: _posts[index],
          onCommentAdded: (
              Comment comment,
              ) {
            if (!mounted) {
              return;
            }

            setState(() {
              _posts[index]
                  .comments
                  .add(
                comment,
              );
            });
          },
        );
      },
    );
  }


// =====================================================
// CREATE POST
// =====================================================

  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (_) {
        return _CreatePostSheet(
          onPostCreated: (
              Post post,
              ) {
            if (!mounted) {
              return;
            }

            setState(() {
              _posts.insert(
                0,
                post,
              );
            });

            Navigator.of(context).pop();

            _showSnack(
              'Post shared successfully! 🐾',
            );
          },
        );
      },
    );
  }


// =====================================================
// SNACKBAR
// =====================================================

  void _showSnack(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration:
        const Duration(
          seconds: 2,
        ),
      ),
    );
  }


// =====================================================
// LOGOUT
// =====================================================

  Future<void> _logout() async {
    try {
      await ApiService.logout();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      debugPrint(
        'LOGOUT ERROR: $e',
      );
    }
  }


// =====================================================
// DISPOSE
// =====================================================

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }


// =====================================================
// ITEM COUNT
// =====================================================

  int get _itemCount {
    int count =
        1 + _posts.length;

    if (_isLoading &&
        _posts.isNotEmpty) {
      count++;
    }

    if (_errorMessage != null) {
      count++;
    }

    if (!_hasMore &&
        _posts.isNotEmpty &&
        !_isLoading) {
      count++;
    }

    if (!_isLoading &&
        _posts.isEmpty &&
        _errorMessage == null) {
      count++;
    }

    return count;
  }


// =====================================================
// BUILD ITEM
// =====================================================

  Widget _buildItem(
      BuildContext context,
      int index,
      ) {
// Create post banner
    if (index == 0) {
      return _CreatePostBanner(
        onTap: _openCreatePost,
      );
    }

    final int postIndex =
        index - 1;

// Post
    if (postIndex <
        _posts.length) {
      return _PostCard(
        post: _posts[postIndex],
        currentUserId:
        PostApiService.currentUserId,
        onLike: () {
          _handleLike(
            postIndex,
          );
        },
        onComment: () {
          _openComments(
            postIndex,
          );
        },
      );
    }

// Loading
    if (_isLoading &&
        _posts.isNotEmpty) {
      return const _LoadingFooter();
    }

// Error
    if (_errorMessage != null) {
      return _ErrorFooter(
        message:
        _errorMessage!,
        onRetry: () {
          _loadPosts();
        },
      );
    }

// Empty
    if (_posts.isEmpty) {
      return const _EmptyFeed();
    }

// End
    return const _EndFooter();
  }


// =====================================================
// BUILD
// =====================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      _T.bg,

      appBar:
      _buildAppBar(),

      body:
      RefreshIndicator(
        color:
        _T.primary,

        onRefresh: () {
          return _loadPosts(
            refresh: true,
          );
        },

        child:
        ListView.builder(
          controller:
          _scrollController,

          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.only(
            bottom: 100,
          ),

          itemCount:
          _itemCount,

          itemBuilder:
          _buildItem,
        ),
      ),

      floatingActionButton:
      _buildFAB(),
    );
  }


// =====================================================
// APP BAR
// =====================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor:
      _T.surface,

      elevation: 0,

      centerTitle: false,

      title:
      Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration:
            BoxDecoration(
              color:
              _T.primary,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child:
            const Icon(
              Icons.pets,
              color:
              Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          const Text(
            'Bio Pet Feed',
            style:
            TextStyle(
              color:
              _T.textPrimary,
              fontSize:
              20,
              fontWeight:
              FontWeight.w700,
              letterSpacing:
              -0.5,
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          tooltip:
          'Logout',

          icon:
          const Icon(
            Icons.logout,
            color:
            _T.textPrimary,
          ),

          onPressed:
          _logout,
        ),

        const SizedBox(
          width: 4,
        ),
      ],

      bottom:
      PreferredSize(
        preferredSize:
        const Size.fromHeight(
          1,
        ),

        child:
        Container(
          height: 1,
          color:
          _T.divider,
        ),
      ),
    );
  }


// =====================================================
// FLOATING ACTION BUTTON
// =====================================================

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed:
      _openCreatePost,

      backgroundColor:
      _T.primary,

      icon:
      const Icon(
        Icons.add_photo_alternate_outlined,
        color:
        Colors.white,
      ),

      label:
      const Text(
        'Post',
        style:
        TextStyle(
          color:
          Colors.white,
          fontWeight:
          FontWeight.w600,
        ),
      ),

      elevation:
      4,
    );
  }
}


// =====================================================
// CREATE POST BANNER
// =====================================================

class _CreatePostBanner
    extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePostBanner({
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        _T.pagePad,
        14,
        _T.pagePad,
        6,
      ),

      child:
      GestureDetector(
        onTap:
        onTap,

        child:
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          decoration:
          BoxDecoration(
            color:
            _T.surface,

            borderRadius:
            BorderRadius.circular(
              _T.cardRadius,
            ),

            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withOpacity(
                  0.05,
                ),
                blurRadius:
                8,
                offset:
                const Offset(
                  0,
                  2,
                ),
              ),
            ],
          ),

          child:
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor:
                _T.primaryLight,
                child:
                Text(
                  '🐾',
                  style:
                  TextStyle(
                    fontSize:
                    18,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    _T.bg,

                    borderRadius:
                    BorderRadius.circular(
                      _T.chipRadius,
                    ),

                    border:
                    Border.all(
                      color:
                      _T.divider,
                    ),
                  ),

                  child:
                  const Text(
                    "What's your pet doing? 🐶",
                    style:
                    TextStyle(
                      color:
                      _T.textSecondary,
                      fontSize:
                      14,
                    ),
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


// =====================================================
// POST CARD
// =====================================================

class _PostCard
    extends StatelessWidget {
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


// =====================================================
// SAFE IMAGE DECODER
// =====================================================

  Uint8List? _decodeImage(
      String data,
      ) {
    try {
      String base64String =
      data.trim();

      if (base64String
          .contains(',')) {
        base64String =
            base64String
                .split(',')
                .last;
      }

      base64String =
          base64String
              .replaceAll(
            '\n',
            '',
          )
              .replaceAll(
            '\r',
            '',
          )
              .trim();

      return base64Decode(
        base64String,
      );
    } catch (e) {
      debugPrint(
        'IMAGE DECODE ERROR: $e',
      );

      return null;
    }
  }


  @override
  Widget build(
      BuildContext context,
      ) {
    final bool liked =
        currentUserId.isNotEmpty &&
            post.likes.contains(
              currentUserId,
            );

    final String initials =
    post.name.isNotEmpty
        ? post.name[0]
        .toUpperCase()
        : '?';


    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        _T.pagePad,
        6,
        _T.pagePad,
        6,
      ),

      child:
      Container(
        decoration:
        BoxDecoration(
          color:
          _T.surface,

          borderRadius:
          BorderRadius.circular(
            _T.cardRadius,
          ),

          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(
                0.05,
              ),
              blurRadius:
              8,
              offset:
              const Offset(
                0,
                2,
              ),
            ),
          ],
        ),

        child:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
// =========================================
// HEADER
// =========================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                14,
                14,
                14,
                0,
              ),

              child:
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                    _T.primaryLight,

                    child:
                    Text(
                      initials,
                      style:
                      const TextStyle(
                        color:
                        _T.primary,
                        fontWeight:
                        FontWeight.w700,
                        fontSize:
                        16,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          post.name,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                            fontSize:
                            15,
                            color:
                            _T.textPrimary,
                          ),
                        ),

                        const SizedBox(
                          height: 1,
                        ),

                        Text(
                          TimeAgo.format(
                            post.createdAt,
                          ),

                          style:
                          const TextStyle(
                            fontSize:
                            12,
                            color:
                            _T.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.more_horiz,
                    color:
                    _T.textSecondary,
                  ),
                ],
              ),
            ),


// =========================================
// TEXT
// =========================================

            if (post.text
                .trim()
                .isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  14,
                  12,
                  14,
                  12,
                ),

                child:
                Text(
                  post.text,

                  style:
                  const TextStyle(
                    fontSize:
                    15,
                    color:
                    _T.textPrimary,
                    height:
                    1.45,
                  ),
                ),
              ),


// =========================================
// IMAGES
// =========================================

            if (post.images.isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),

                child:
                SizedBox(
                  height: 200,

                  child:
                  ListView.separated(
                    scrollDirection:
                    Axis.horizontal,

                    itemCount:
                    post.images.length,

                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      width: 8,
                    ),

                    itemBuilder:
                        (_, index) {
                      final ImageData image =
                      post.images[index];

                      final Uint8List?
                      bytes =
                      _decodeImage(
                        image.data,
                      );

                      if (bytes == null) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration:
                          BoxDecoration(
                            color:
                            _T.bg,
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                          child:
                          const Icon(
                            Icons.broken_image_outlined,
                            color:
                            _T.textSecondary,
                            size:
                            40,
                          ),
                        );
                      }

                      return ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),

                        child:
                        Image.memory(
                          bytes,

                          width:
                          200,

                          height:
                          200,

                          fit:
                          BoxFit.cover,

                          errorBuilder:
                              (
                              context,
                              error,
                              stackTrace,
                              ) {
                            return Container(
                              width:
                              200,
                              height:
                              200,
                              color:
                              _T.bg,
                              child:
                              const Icon(
                                Icons.broken_image,
                                color:
                                _T.textSecondary,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),


// =========================================
// LIKE / COMMENT COUNTS
// =========================================

            if (post.likes.isNotEmpty ||
                post.comments.isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                ),

                child:
                Row(
                  children: [
                    if (post.likes.isNotEmpty)
                      Row(
                        children: [
                          const Text(
                            '❤️',
                            style:
                            TextStyle(
                              fontSize:
                              13,
                            ),
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          Text(
                            '${post.likes.length}',

                            style:
                            const TextStyle(
                              fontSize:
                              12,
                              color:
                              _T.textSecondary,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    if (post.comments.isNotEmpty)
                      Text(
                        '${post.comments.length} comment${post.comments.length == 1 ? '' : 's'}',

                        style:
                        const TextStyle(
                          fontSize:
                          12,
                          color:
                          _T.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),


// =========================================
// DIVIDER
// =========================================

            const Padding(
              padding:
              EdgeInsets.symmetric(
                vertical: 6,
              ),

              child:
              Divider(
                height:
                1,
                color:
                _T.divider,
              ),
            ),


// =========================================
// ACTION BUTTONS
// =========================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                4,
                2,
                4,
                10,
              ),

              child:
              Row(
                children: [
                  Expanded(
                    child:
                    _ActionButton(
                      icon:
                      liked
                          ? Icons.favorite
                          : Icons.favorite_border,

                      label:
                      liked
                          ? 'Liked'
                          : 'Like',

                      color:
                      liked
                          ? _T.accent
                          : _T.textSecondary,

                      onTap:
                      onLike,
                    ),
                  ),

                  Expanded(
                    child:
                    _ActionButton(
                      icon:
                      Icons.chat_bubble_outline,

                      label:
                      'Comment',

                      color:
                      _T.textSecondary,

                      onTap:
                      onComment,
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


// =====================================================
// ACTION BUTTON
// =====================================================

class _ActionButton
    extends StatelessWidget {
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
  Widget build(
      BuildContext context,
      ) {
    return InkWell(
      onTap:
      onTap,

      borderRadius:
      BorderRadius.circular(
        8,
      ),

      child:
      Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),

        child:
        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size:
              20,
              color:
              color,
            ),

            const SizedBox(
              width: 6,
            ),

            Text(
              label,

              style:
              TextStyle(
                color:
                color,
                fontWeight:
                FontWeight.w600,
                fontSize:
                13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// CREATE POST SHEET
// =====================================================

class _CreatePostSheet
    extends StatefulWidget {
  final void Function(Post post)
  onPostCreated;

  const _CreatePostSheet({
    required this.onPostCreated,
  });


  @override
  State<_CreatePostSheet> createState() =>
      _CreatePostSheetState();
}


class _CreatePostSheetState
    extends State<_CreatePostSheet> {
  final TextEditingController
  _controller =
  TextEditingController();

  final ImagePicker _picker =
  ImagePicker();

  List<File> _selectedImages = [];

  static const int _maxImageCount = 10;
  static const int _maxImageBytes =
      5 * 1024 * 1024;

  bool _isPosting = false;

  String? _error;


// =====================================================
// INIT
// =====================================================

  @override
  void initState() {
    super.initState();

    _controller.addListener(
      _onTextChanged,
    );
  }


  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }


// =====================================================
// PICK IMAGES
// =====================================================

  bool _isJpeg(
      Uint8List bytes,
      ) {
    return bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
  }


  bool _isPng(
      Uint8List bytes,
      ) {
    return bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }


  bool _isWebp(
      Uint8List bytes,
      ) {
    return bytes.length >= 12 &&
        String.fromCharCodes(
          bytes.sublist(0, 4),
        ) == 'RIFF' &&
        String.fromCharCodes(
          bytes.sublist(8, 12),
        ) == 'WEBP';
  }


  String? _supportedExtension(
      Uint8List bytes,
      ) {
    if (_isJpeg(bytes)) {
      return 'jpg';
    }

    if (_isPng(bytes)) {
      return 'png';
    }

    if (_isWebp(bytes)) {
      return 'webp';
    }

    return null;
  }


  Future<void> _verifyDecodable(
      Uint8List bytes,
      ) async {
    ui.Codec? codec;
    ui.FrameInfo? frame;

    try {
      codec = await ui.instantiateImageCodec(
        bytes,
      );

      frame = await codec.getNextFrame();
    } finally {
      frame?.image.dispose();
      codec?.dispose();
    }
  }


  Future<Uint8List> _convertToPng(
      Uint8List bytes, {
        required int maxDimension,
      }) async {
    ui.Codec? sourceCodec;
    ui.FrameInfo? sourceFrame;
    ui.Codec? resizedCodec;
    ui.FrameInfo? resizedFrame;

    try {
      sourceCodec = await ui.instantiateImageCodec(
        bytes,
      );

      sourceFrame =
      await sourceCodec.getNextFrame();

      final int originalWidth =
          sourceFrame.image.width;

      final int originalHeight =
          sourceFrame.image.height;

      int targetWidth = originalWidth;
      int targetHeight = originalHeight;

      if (originalWidth > maxDimension ||
          originalHeight > maxDimension) {
        if (originalWidth >= originalHeight) {
          targetWidth = maxDimension;
          targetHeight =
              (originalHeight * maxDimension /
                  originalWidth)
                  .round()
                  .clamp(1, maxDimension)
                  .toInt();
        } else {
          targetHeight = maxDimension;
          targetWidth =
              (originalWidth * maxDimension /
                  originalHeight)
                  .round()
                  .clamp(1, maxDimension)
                  .toInt();
        }
      }

      sourceFrame.image.dispose();
      sourceFrame = null;
      sourceCodec.dispose();
      sourceCodec = null;

      resizedCodec =
      await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );

      resizedFrame =
      await resizedCodec.getNextFrame();

      final ByteData? pngData =
      await resizedFrame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (pngData == null) {
        throw Exception(
          'Could not convert the selected image.',
        );
      }

      return pngData.buffer.asUint8List(
        pngData.offsetInBytes,
        pngData.lengthInBytes,
      );
    } finally {
      sourceFrame?.image.dispose();
      sourceCodec?.dispose();
      resizedFrame?.image.dispose();
      resizedCodec?.dispose();
    }
  }


  Future<File> _preparePickedImage(
      XFile image,
      int index,
      ) async {
    Uint8List bytes =
    await image.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception(
        'ပုံဖိုင်အလွတ် ဖြစ်နေပါသည်။',
      );
    }

    try {
      await _verifyDecodable(
        bytes,
      );
    } catch (_) {
      throw Exception(
        'ဒီပုံအမျိုးအစားကို ဖတ်၍မရပါ။ JPG သို့မဟုတ် PNG ပုံကို ရွေးပါ။',
      );
    }

    String? extension =
    _supportedExtension(
      bytes,
    );

    if (extension == null) {
      try {
        bytes = await _convertToPng(
          bytes,
          maxDimension: 1200,
        );

        if (bytes.length > _maxImageBytes) {
          bytes = await _convertToPng(
            await image.readAsBytes(),
            maxDimension: 900,
          );
        }

        extension = 'png';
      } catch (_) {
        throw Exception(
          'ဒီပုံကို upload တင်နိုင်သော format သို့ ပြောင်း၍မရပါ။',
        );
      }
    }

    if (bytes.length > _maxImageBytes) {
      throw Exception(
        'ပုံတစ်ပုံလျှင် 5 MB ထက် မကြီးရပါ။',
      );
    }

    final String outputPath =
        '${image.path}.biopet_${DateTime.now().microsecondsSinceEpoch}_$index.$extension';

    final File outputFile =
    File(outputPath);

    await outputFile.writeAsBytes(
      bytes,
      flush: true,
    );

    return outputFile;
  }


  Future<void> _pickImages() async {
    if (_isPosting) {
      return;
    }

    try {
      final List<XFile> pickedImages =
      await _picker.pickMultiImage(
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 82,
        limit: _maxImageCount,
        requestFullMetadata: false,
      );

      if (!mounted) {
        return;
      }

      if (pickedImages.isEmpty) {
        return;
      }

      setState(() {
        _error = null;
      });

      final List<File> preparedImages = [];
      final List<String> rejectedMessages = [];

      for (int index = 0;
      index < pickedImages.length &&
          preparedImages.length < _maxImageCount;
      index++) {
        try {
          final File prepared =
          await _preparePickedImage(
            pickedImages[index],
            index,
          );

          preparedImages.add(
            prepared,
          );
        } catch (e) {
          rejectedMessages.add(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImages = preparedImages;

        if (preparedImages.isEmpty) {
          _error = rejectedMessages.isNotEmpty
              ? rejectedMessages.first
              : 'ပုံကို ရွေး၍မရပါ။';
        } else if (rejectedMessages.isNotEmpty) {
          _error =
          'ဖတ်၍မရသောပုံ ${rejectedMessages.length} ပုံကို မထည့်ထားပါ။';
        }
      });
    } catch (e) {
      debugPrint(
        'PICK IMAGE ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            e.toString()
                .replaceFirst(
              'Exception: ',
              '',
            )
                .replaceFirst(
              'PlatformException(',
              '',
            );
      });
    }
  }

// =====================================================
// REMOVE IMAGE
// =====================================================

  void _removeImage(
      int index,
      ) {
    if (index < 0 ||
        index >=
            _selectedImages.length) {
      return;
    }

    final File removedFile =
    _selectedImages[index];

    setState(() {
      _selectedImages.removeAt(
        index,
      );
    });

    if (removedFile.path.contains(
      '.biopet_',
    )) {
      removedFile.delete().catchError(
            (_) => removedFile,
      );
    }
  }


// =====================================================
// LOCAL PET IMAGE VALIDATION
// =====================================================

  Future<void> _validateSelectedImagesLocally() async {
    if (_selectedImages.isEmpty) {
      return;
    }

    final ClassificationProvider classificationProvider =
    context.read<ClassificationProvider>();

    final List<PetImageValidationResult> results =
    await classificationProvider.validatePetImagesForPost(
      _selectedImages.map((file) => file.path),
    );

    final int rejectedIndex = results.indexWhere(
          (result) => !result.allowed,
    );

    if (rejectedIndex >= 0) {
      final PetImageValidationResult result = results[rejectedIndex];
      final int imageNumber = rejectedIndex + 1;
      final int confidence = (result.topConfidence * 100).round();

      throw Exception(
        'ပုံ $imageNumber ကို ခွေး/ကြောင်ပုံအဖြစ် မသတ်မှတ်နိုင်ပါ။\n'
            '${result.message}\n'
            'AI result: ${result.topLabel} ($confidence%)',
      );
    }
  }


// =====================================================
// CREATE POST ERROR MESSAGE
// =====================================================

  String _createPostErrorMessage(
      Object error,
      ) {
    String raw =
    error.toString().trim();

    raw = raw.replaceFirst(
      RegExp(
        r'^Exception:\s*',
        caseSensitive: false,
      ),
      '',
    );

    String? responseCode;
    String? responseMessage;

    final int jsonStart =
    raw.indexOf('{');
    final int jsonEnd =
    raw.lastIndexOf('}');

    if (jsonStart >= 0 &&
        jsonEnd > jsonStart) {
      final String possibleJson =
      raw.substring(
        jsonStart,
        jsonEnd + 1,
      );

      try {
        final dynamic decoded =
        jsonDecode(
          possibleJson,
        );

        if (decoded is Map) {
          final Map<String, dynamic> body =
          Map<String, dynamic>.from(
            decoded,
          );

          responseCode =
              body['code']?.toString();
          responseMessage =
              body['message']?.toString();

          final dynamic moderation =
          body['imageModeration'];

          if ((responseCode == null ||
              responseCode!.isEmpty) &&
              moderation is Map) {
            responseCode =
                moderation['errorCode']
                    ?.toString();
          }

          if ((responseMessage == null ||
              responseMessage!.trim().isEmpty) &&
              moderation is Map) {
            responseMessage =
                moderation['reason']
                    ?.toString();
          }
        }
      } catch (_) {
// The exception may contain non-JSON text.
      }
    }

    final String searchable =
    '${responseCode ?? ''} $raw'
        .toLowerCase();

    String? mappedMessage;

    if (searchable.contains('pet_image_required') ||
        searchable.contains('local_pet_image_rejected')) {
      mappedMessage =
      'ခွေး သို့မဟုတ် ကြောင် ရှင်းရှင်းလင်းလင်းပါသောပုံကိုသာ တင်နိုင်ပါသည်။';
    } else if (searchable.contains('classification') ||
        searchable.contains('tflite') ||
        searchable.contains('local ai') ||
        searchable.contains('tensor')) {
      mappedMessage =
      'ဖုန်းထဲက AI model ဖြင့် ပုံစစ်၍မရပါ။ App ကိုပိတ်ပြီး ပြန်ဖွင့်ကာ ထပ်စမ်းပါ။';
    } else if (searchable.contains('application failed to respond') ||
        searchable.contains('502')) {
      mappedMessage =
      'Railway backend က response မပြန်နိုင်သေးပါ။ Deployment ပြီးမှ ပြန်တင်ပါ။';
    }

    final String message =
    (mappedMessage ??
        responseMessage ??
        raw)
        .trim();

    if (message.isEmpty) {
      return 'Post တင်၍မရပါ။ ပြန်စမ်းကြည့်ပါ။';
    }

    if (responseCode != null &&
        responseCode!.trim().isNotEmpty &&
        !message.contains(responseCode!)) {
      return '$message\nCode: $responseCode';
    }

    return message;
  }


// =====================================================
// SUBMIT POST
// =====================================================

  Future<void> _submit() async {
    if (_isPosting) {
      return;
    }

    final String text =
    _controller.text.trim();

    if (text.isEmpty &&
        _selectedImages.isEmpty) {
      return;
    }

    setState(() {
      _isPosting = true;
      _error = null;
    });

    try {
      await _validateSelectedImagesLocally();

      final Map<String, dynamic> response =
      await PostApiService
          .createPostWithImages(
        text: text,
        imageFiles:
        _selectedImages,
      );

      debugPrint(
        'CREATE POST RESPONSE => $response',
      );

// ================================================
// BACKEND RESPONSE
//
// Expected:
// {
//   success: true,
//   post: {...}
// }
// ================================================

      final dynamic postJson =
      response['post'];

      if (postJson == null ||
          postJson is! Map) {
        throw Exception(
          'Post data not found in server response.',
        );
      }

      final Post post =
      Post.fromJson(
        Map<String, dynamic>.from(
          postJson,
        ),
      );

      if (!mounted) {
        return;
      }

// Parent handles:
// - Insert post
// - Close bottom sheet
// - Show success message
      widget.onPostCreated(
        post,
      );
    } catch (e) {
      debugPrint(
        'CREATE POST ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            _createPostErrorMessage(
              e,
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }


// =====================================================
// DISPOSE
// =====================================================

  @override
  void dispose() {
    _controller.removeListener(
      _onTextChanged,
    );

    _controller.dispose();

    for (final File image in
    _selectedImages) {
      if (image.path.contains(
        '.biopet_',
      )) {
        image.delete().catchError(
              (_) => image,
        );
      }
    }

    super.dispose();
  }


// =====================================================
// BUILD
// =====================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final double bottomPad =
        MediaQuery.of(
          context,
        ).viewInsets.bottom;

    final bool canPost =
        !_isPosting &&
            (
                _controller.text
                    .trim()
                    .isNotEmpty ||
                    _selectedImages.isNotEmpty
            );

    return SafeArea(
      child:
      Container(
        padding:
        EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + bottomPad,
        ),

        decoration:
        const BoxDecoration(
          color:
          _T.surface,

          borderRadius:
          BorderRadius.vertical(
            top:
            Radius.circular(
              24,
            ),
          ),
        ),

        child:
        SingleChildScrollView(
          child:
          Column(
            mainAxisSize:
            MainAxisSize.min,

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
// ========================================
// HANDLE
// ========================================

              Center(
                child:
                Container(
                  width:
                  40,
                  height:
                  4,

                  decoration:
                  BoxDecoration(
                    color:
                    _T.divider,
                    borderRadius:
                    BorderRadius.circular(
                      4,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),


// ========================================
// TITLE
// ========================================

              Row(
                children: [
                  const Text(
                    '🐾',
                    style:
                    TextStyle(
                      fontSize:
                      20,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  const Text(
                    'Share a pet moment',

                    style:
                    TextStyle(
                      fontSize:
                      18,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      _T.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 4,
              ),

              const Text(
                'You can select up to 10 images',

                style:
                TextStyle(
                  fontSize:
                  12,
                  color:
                  _T.textSecondary,
                ),
              ),

              const SizedBox(
                height: 16,
              ),


// ========================================
// TEXT FIELD
// ========================================

              TextField(
                controller:
                _controller,

                maxLines:
                4,

                autofocus:
                true,

                style:
                const TextStyle(
                  fontSize:
                  15,
                  color:
                  _T.textPrimary,
                ),

                decoration:
                InputDecoration(
                  hintText:
                  "What's your pet up to today? 🐶🐱",

                  hintStyle:
                  const TextStyle(
                    color:
                    _T.textSecondary,
                  ),

                  filled:
                  true,

                  fillColor:
                  _T.bg,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),

                    borderSide:
                    BorderSide.none,
                  ),

                  contentPadding:
                  const EdgeInsets.all(
                    14,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),


// ========================================
// PICK IMAGE BUTTON
// ========================================

              SizedBox(
                width:
                double.infinity,

                child:
                OutlinedButton.icon(
                  onPressed:
                  _isPosting
                      ? null
                      : _pickImages,

                  icon:
                  const Icon(
                    Icons.add_photo_alternate,
                  ),

                  label:
                  Text(
                    'Pick Images (${_selectedImages.length}/10)',
                  ),

                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    _T.primary,

                    side:
                    const BorderSide(
                      color:
                      _T.primary,
                    ),

                    padding:
                    const EdgeInsets.symmetric(
                      vertical:
                      12,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),


// ========================================
// IMAGE PREVIEW
// ========================================

              if (_selectedImages
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  height:
                  100,

                  child:
                  ListView.separated(
                    scrollDirection:
                    Axis.horizontal,

                    itemCount:
                    _selectedImages.length,

                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      width:
                      8,
                    ),

                    itemBuilder:
                        (_, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),

                            child:
                            Image.file(
                              _selectedImages[
                              index],

                              width:
                              100,

                              height:
                              100,

                              fit:
                              BoxFit.cover,

                              errorBuilder:
                                  (
                                  context,
                                  error,
                                  stackTrace,
                                  ) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: _T.bg,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: _T.accent,
                                    size: 32,
                                  ),
                                );
                              },
                            ),
                          ),

                          Positioned(
                            top:
                            4,

                            right:
                            4,

                            child:
                            GestureDetector(
                              onTap:
                              _isPosting
                                  ? null
                                  : () {
                                _removeImage(
                                  index,
                                );
                              },

                              child:
                              Container(
                                decoration:
                                const BoxDecoration(
                                  color:
                                  Colors.black54,

                                  shape:
                                  BoxShape.circle,
                                ),

                                padding:
                                const EdgeInsets.all(
                                  2,
                                ),

                                child:
                                const Icon(
                                  Icons.close,
                                  size:
                                  18,
                                  color:
                                  Colors.white,
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


// ========================================
// ERROR
// ========================================

              if (_error != null) ...[
                const SizedBox(
                  height: 10,
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal:
                    12,
                    vertical:
                    10,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFFEEEE,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),

                  child:
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.error_outline,
                        color:
                        Color(0xFFDC2626),
                        size:
                        18,
                      ),

                      const SizedBox(
                        width:
                        8,
                      ),

                      Expanded(
                        child:
                        Text(
                          _error!,

                          style:
                          const TextStyle(
                            color:
                            Color(0xFFDC2626),
                            fontSize:
                            13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],


              const SizedBox(
                height: 16,
              ),


// ========================================
// POST BUTTON
// ========================================

              SizedBox(
                width:
                double.infinity,

                child:
                FilledButton(
                  onPressed:
                  canPost
                      ? _submit
                      : null,

                  style:
                  FilledButton.styleFrom(
                    backgroundColor:
                    _T.primary,

                    disabledBackgroundColor:
                    _T.divider,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical:
                      14,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        _T.chipRadius,
                      ),
                    ),
                  ),

                  child:
                  _isPosting
                      ? const SizedBox(
                    width:
                    20,
                    height:
                    20,

                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth:
                      2,
                    ),
                  )
                      : const Text(
                    'Post',

                    style:
                    TextStyle(
                      fontSize:
                      16,
                      fontWeight:
                      FontWeight.w700,
                    ),
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


// =====================================================
// COMMENTS SHEET
// =====================================================

class _CommentsSheet extends StatefulWidget {
  final Post post;
  final void Function(Comment comment) onCommentAdded;

  const _CommentsSheet({
    required this.post,
    required this.onCommentAdded,
  });

  @override
  State<_CommentsSheet> createState() =>
      _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
    'https://biopet-production-e56e.up.railway.app',
  );

  final TextEditingController _controller =
  TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  final Map<String, List<_ReplyViewData>>
  _localReplies = {};

  bool _isSending = false;
  String? _replyingToCommentId;
  String? _replyingToUserName;

  bool get _isReplying =>
      _replyingToCommentId != null;

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _startReply(Comment comment) {
    final String commentId = comment.id.trim();

    if (commentId.isEmpty) {
      _showMessage(
        'ဒီ comment ကို reply လုပ်ရန် feed ကို refresh လုပ်ပါ။',
      );
      return;
    }

    final String displayName =
    comment.userName.trim().isNotEmpty
        ? comment.userName.trim()
        : 'User';

    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUserName = displayName;
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocusNode.requestFocus();
      }
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUserName = null;
      _controller.clear();
    });
  }

  List<_ReplyViewData> _repliesFor(
      Comment comment,
      ) {
    final List<_ReplyViewData> replies = [];

    try {
      final dynamic rawReplies = comment.replies;

      if (rawReplies is Iterable) {
        for (final dynamic rawReply in rawReplies) {
          final reply =
          _ReplyViewData.fromDynamic(rawReply);

          if (reply.text.trim().isNotEmpty) {
            replies.add(reply);
          }
        }
      }
    } catch (error) {
      debugPrint(
        'READ COMMENT REPLIES ERROR => $error',
      );
    }

    replies.addAll(
      _localReplies[comment.id] ??
          const <_ReplyViewData>[],
    );

    return replies;
  }

  Future<Map<String, dynamic>> _postReply({
    required String commentId,
    required String text,
  }) async {
    final String normalizedBase =
    _apiBaseUrl.endsWith('/')
        ? _apiBaseUrl.substring(
      0,
      _apiBaseUrl.length - 1,
    )
        : _apiBaseUrl;

    final Uri uri = Uri.parse(
      '$normalizedBase/api/posts/comment',
    );

    final HttpClient client = HttpClient();

    try {
      final HttpClientRequest request =
      await client.postUrl(uri).timeout(
        const Duration(seconds: 20),
      );

      request.headers.contentType =
          ContentType.json;
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      request.add(
        utf8.encode(
          jsonEncode({
            'postId': widget.post.id,
            'commentId': commentId,
            'userId':
            PostApiService.currentUserId,
            'userName': PostApiService
                .currentUserName
                .trim()
                .isNotEmpty
                ? PostApiService.currentUserName
                .trim()
                : 'Anonymous',
            'text': text,
          }),
        ),
      );

      final HttpClientResponse response =
      await request.close().timeout(
        const Duration(seconds: 30),
      );

      final String responseText =
      await response
          .transform(utf8.decoder)
          .join()
          .timeout(
        const Duration(seconds: 20),
      );

      Map<String, dynamic> data = {};

      if (responseText.trim().isNotEmpty) {
        final dynamic decoded =
        jsonDecode(responseText);

        if (decoded is Map) {
          data = Map<String, dynamic>.from(
            decoded,
          );
        }
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message']?.toString() ??
              'Reply could not be sent (${response.statusCode}).',
        );
      }

      return data;
    } on SocketException {
      throw Exception(
        'Internet connection မရှိပါ။',
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _sendCommentOrReply() async {
    if (_isSending) return;

    final String text =
    _controller.text.trim();

    if (text.isEmpty) return;

    String userId =
        PostApiService.currentUserId;

    if (userId.isEmpty) {
      await PostApiService.init();
      userId = PostApiService.currentUserId;
    }

    if (userId.isEmpty) {
      _showMessage(
        'Please login again to comment.',
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      if (_isReplying) {
        final String commentId =
        _replyingToCommentId!;

        final Map<String, dynamic> response =
        await _postReply(
          commentId: commentId,
          text: text,
        );

        final _ReplyViewData reply =
        _ReplyViewData.fromDynamic(
          response['reply'],
          fallbackUserId:
          PostApiService.currentUserId,
          fallbackUserName: PostApiService
              .currentUserName
              .trim()
              .isNotEmpty
              ? PostApiService.currentUserName
              .trim()
              : 'Anonymous',
          fallbackText: text,
        );

        if (!mounted) return;

        setState(() {
          _localReplies
              .putIfAbsent(
            commentId,
                () => <_ReplyViewData>[],
          )
              .add(reply);

          _replyingToCommentId = null;
          _replyingToUserName = null;
          _controller.clear();
        });

        return;
      }

      final Map<String, dynamic> response =
      await PostApiService.addComment(
        widget.post.id,
        text,
      );

      debugPrint(
        'ADD COMMENT RESPONSE => $response',
      );

      Comment comment;
      final dynamic commentJson =
      response['comment'];

      if (commentJson is Map) {
        comment = Comment.fromJson(
          Map<String, dynamic>.from(
            commentJson,
          ),
        );
      } else {
        comment = Comment(
          id: '',
          userId:
          PostApiService.currentUserId,
          userName: PostApiService
              .currentUserName
              .isNotEmpty
              ? PostApiService.currentUserName
              : 'Anonymous',
          text: text,
          createdAt: DateTime.now(),
          replies: [],
        );
      }

      if (!mounted) return;

      setState(() {
        _controller.clear();
      });

      widget.onCommentAdded(comment);
    } catch (error) {
      debugPrint(
        'ADD COMMENT/REPLY ERROR => $error',
      );

      _showMessage(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPad =
        MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: bottomPad,
        ),
        decoration: const BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
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
                  borderRadius:
                  BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Text(
                    '💬',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: 8),
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
            const Divider(
              height: 1,
              color: _T.divider,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                MediaQuery.of(context)
                    .size
                    .height *
                    0.46,
              ),
              child: widget.post.comments.isEmpty
                  ? const Padding(
                padding:
                EdgeInsets.symmetric(
                  vertical: 32,
                ),
                child: Center(
                  child: Text(
                    'No comments yet. Be the first! 🐾',
                    style: TextStyle(
                      color:
                      _T.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
                  : ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets
                    .symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: widget
                    .post.comments.length,
                separatorBuilder: (_, __) =>
                const SizedBox(
                  height: 12,
                ),
                itemBuilder: (_, index) {
                  final Comment comment =
                  widget.post
                      .comments[index];

                  return _CommentTile(
                    comment: comment,
                    replies:
                    _repliesFor(comment),
                    onReply: () =>
                        _startReply(comment),
                  );
                },
              ),
            ),
            const Divider(
              height: 1,
              color: _T.divider,
            ),
            if (_isReplying)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _T.primaryLight
                      .withOpacity(0.38),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply_rounded,
                      size: 18,
                      color: _T.primary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Replying to ${_replyingToUserName ?? 'User'}',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _T.primary,
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _cancelReply,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                      ),
                      color: _T.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints:
                      const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                14,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor:
                    _T.primaryLight,
                    child: Text(
                      '🐾',
                      style:
                      TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _inputFocusNode,
                      textInputAction:
                      TextInputAction.send,
                      onSubmitted: (_) {
                        _sendCommentOrReply();
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: _T.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: _isReplying
                            ? 'Write a reply…'
                            : 'Add a comment…',
                        hintStyle: const TextStyle(
                          color: _T.textSecondary,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: _T.bg,
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            _T.chipRadius,
                          ),
                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const SizedBox(
                    width: 36,
                    height: 36,
                    child:
                    CircularProgressIndicator(
                      color: _T.primary,
                      strokeWidth: 2,
                    ),
                  )
                      : IconButton(
                    onPressed:
                    _sendCommentOrReply,
                    icon: Icon(
                      _isReplying
                          ? Icons
                          .reply_rounded
                          : Icons
                          .send_rounded,
                    ),
                    color: _T.primary,
                    iconSize: 26,
                    padding:
                    EdgeInsets.zero,
                    constraints:
                    const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
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

class _ReplyViewData {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  const _ReplyViewData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory _ReplyViewData.fromDynamic(
      dynamic value, {
        String fallbackUserId = '',
        String fallbackUserName = 'Anonymous',
        String fallbackText = '',
      }) {
    String readValue(
        dynamic source,
        String key,
        ) {
      if (source is Map) {
        return source[key]?.toString() ?? '';
      }

      try {
        switch (key) {
          case '_id':
            return source.id?.toString() ?? '';
          case 'userId':
            return source.userId?.toString() ?? '';
          case 'userName':
            return source.userName?.toString() ?? '';
          case 'text':
            return source.text?.toString() ?? '';
          case 'createdAt':
            return source.createdAt?.toString() ?? '';
        }
      } catch (_) {}

      return '';
    }

    final String rawDate =
    readValue(value, 'createdAt');

    return _ReplyViewData(
      id: readValue(value, '_id'),
      userId: readValue(value, 'userId')
          .trim()
          .isNotEmpty
          ? readValue(value, 'userId').trim()
          : fallbackUserId,
      userName: readValue(value, 'userName')
          .trim()
          .isNotEmpty
          ? readValue(value, 'userName').trim()
          : fallbackUserName,
      text: readValue(value, 'text')
          .trim()
          .isNotEmpty
          ? readValue(value, 'text').trim()
          : fallbackText,
      createdAt: DateTime.tryParse(rawDate) ??
          DateTime.now(),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final List<_ReplyViewData> replies;
  final VoidCallback onReply;

  const _CommentTile({
    required this.comment,
    required this.replies,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName =
    comment.userName.trim().isNotEmpty
        ? comment.userName.trim()
        : 'User';

    final String initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _T.primaryLight,
              child: Text(
                initials,
                style: const TextStyle(
                  color: _T.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _T.bg,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                        fontSize: 12,
                        color: _T.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _T.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: onReply,
                      borderRadius:
                      BorderRadius.circular(8),
                      child: const Padding(
                        padding:
                        EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 3,
                        ),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            color: _T.primary,
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 42,
              top: 8,
            ),
            child: Column(
              children: replies
                  .map(
                    (reply) => Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 7,
                  ),
                  child: _ReplyBubble(
                    reply: reply,
                  ),
                ),
              )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final _ReplyViewData reply;

  const _ReplyBubble({
    required this.reply,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName =
    reply.userName.trim().isNotEmpty
        ? reply.userName.trim()
        : 'User';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor:
          _T.primaryLight.withOpacity(0.7),
          child: Text(
            displayName.isNotEmpty
                ? displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: _T.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: _T.primaryLight
                  .withOpacity(0.24),
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color: _T.divider,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: _T.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reply.text,
                  style: const TextStyle(
                    color: _T.textPrimary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// =====================================================
// LOADING FOOTER
// =====================================================

class _LoadingFooter
    extends StatelessWidget {
  const _LoadingFooter();


  @override
  Widget build(
      BuildContext context,
      ) {
    return const Padding(
      padding:
      EdgeInsets.symmetric(
        vertical:
        24,
      ),

      child:
      Center(
        child:
        CircularProgressIndicator(
          color:
          _T.primary,
          strokeWidth:
          2.5,
        ),
      ),
    );
  }
}


// =====================================================
// ERROR FOOTER
// =====================================================

class _ErrorFooter
    extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _ErrorFooter({
    required this.message,
    required this.onRetry,
  });


  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical:
        24,
        horizontal:
        _T.pagePad,
      ),

      child:
      Column(
        children: [
          Text(
            message,

            textAlign:
            TextAlign.center,

            style:
            const TextStyle(
              color:
              _T.textSecondary,
              fontSize:
              14,
            ),
          ),

          const SizedBox(
            height:
            10,
          ),

          OutlinedButton(
            onPressed:
            onRetry,

            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              _T.primary,

              side:
              const BorderSide(
                color:
                _T.primary,
              ),

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  _T.chipRadius,
                ),
              ),
            ),

            child:
            const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }
}


// =====================================================
// EMPTY FEED
// =====================================================

class _EmptyFeed
    extends StatelessWidget {
  const _EmptyFeed();


  @override
  Widget build(
      BuildContext context,
      ) {
    return const Padding(
      padding:
      EdgeInsets.symmetric(
        vertical:
        60,
      ),

      child:
      Center(
        child:
        Column(
          children: [
            Text(
              '🐾',
              style:
              TextStyle(
                fontSize:
                48,
              ),
            ),

            SizedBox(
              height:
              12,
            ),

            Text(
              'No posts yet',

              style:
              TextStyle(
                fontSize:
                18,
                fontWeight:
                FontWeight.w700,
                color:
                _T.textPrimary,
              ),
            ),

            SizedBox(
              height:
              6,
            ),

            Text(
              'Be the first to share a pet moment!',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                fontSize:
                14,
                color:
                _T.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// END FOOTER
// =====================================================

class _EndFooter
    extends StatelessWidget {
  const _EndFooter();


  @override
  Widget build(
      BuildContext context,
      ) {
    return const Padding(
      padding:
      EdgeInsets.symmetric(
        vertical:
        24,
      ),

      child:
      Center(
        child:
        Text(
          '🐾  You\'ve seen all posts',

          style:
          TextStyle(
            color:
            _T.textSecondary,
            fontSize:
            13,
          ),
        ),
      ),
    );
  }
}
