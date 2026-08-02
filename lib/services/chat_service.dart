import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatServiceException implements Exception {
  const ChatServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChatService {
  ChatService._();

  static String get _apiBaseUrl {
    final configuredUrl = dotenv.env['API_BASE_URL']?.trim();

    if (configuredUrl == null || configuredUrl.isEmpty) {
      throw const ChatServiceException(
        'API_BASE_URL ကို .env ဖိုင်ထဲမှာ ထည့်ပေးပါ။',
      );
    }

    final withoutTrailingSlash = configuredUrl.endsWith('/')
        ? configuredUrl.substring(0, configuredUrl.length - 1)
        : configuredUrl;

    return withoutTrailingSlash.endsWith('/api')
        ? withoutTrailingSlash
        : '$withoutTrailingSlash/api';
  }

  static Future<String> sendMessage(String userText) async {
    final message = userText.trim();

    if (message.isEmpty) {
      throw const ChatServiceException('မေးခွန်းတစ်ခု ရေးပေးပါ။');
    }

    final uri = Uri.parse('$_apiBaseUrl/pet-chat');

    try {
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint('BioPet chat status: ${response.statusCode}');
        debugPrint('BioPet chat response: ${response.body}');
      }

      final dynamic decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (decodedBody is! Map<String, dynamic>) {
        throw const ChatServiceException(
          'Backend response format မမှန်ပါ။',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final serverMessage = decodedBody['message']?.toString().trim();
        throw ChatServiceException(
          serverMessage == null || serverMessage.isEmpty
              ? 'BioPet server error ဖြစ်နေပါတယ်။'
              : serverMessage,
        );
      }

      final reply = decodedBody['reply']?.toString().trim();

      if (reply == null || reply.isEmpty) {
        throw const ChatServiceException(
          'BioPet AI ဆီက အဖြေမရရှိပါ။',
        );
      }

      return reply;
    } on TimeoutException {
      throw const ChatServiceException(
        'Server အဖြေပြန်ချိန်ကြာနေပါတယ်။ ခဏနေရင် ပြန်စမ်းပါ။',
      );
    } on FormatException {
      throw const ChatServiceException(
        'Backend က JSON response မှန်မှန်မပို့ပါ။',
      );
    } on http.ClientException {
      throw const ChatServiceException(
        'BioPet backend နဲ့ ဆက်သွယ်မရပါ။ Internet connection ကို စစ်ပါ။',
      );
    } on ChatServiceException {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ChatService error: $error');
      }

      throw const ChatServiceException(
        'မမျှော်လင့်ထားတဲ့ error ဖြစ်နေပါတယ်။',
      );
    }
  }
}
