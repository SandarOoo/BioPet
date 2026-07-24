import 'package:flutter/material.dart';
import '../services/post_api_service.dart';
import 'dart:io';

class PostProvider extends ChangeNotifier {
  bool isLoading = false;

  String? error;
  Map<String, dynamic>? aiResult;

  Future<void> createPost({
    required String text,
    required List<File> images,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await PostApiService.createPostWithImages(
        text: text,
        imageFiles: images,
      );

      aiResult = res['ai'];

      // OPTIONAL: if needed store post
      final post = res['post'];

    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }}