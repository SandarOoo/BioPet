import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Chat service မှာ ဖြစ်လာတဲ့ error message တွေကို
/// Flutter chat screen ဆီ ပို့ပေးဖို့ အသုံးပြုပါတယ်။
class ChatServiceException implements Exception {
  const ChatServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChatService {
  ChatService._();

  /// .env ထဲက BASE_URL ကိုဖတ်ပြီး
  /// နောက်ဆုံး chatbot endpoint URL တည်ဆောက်ပေးပါတယ်။
  static Uri get _chatEndpoint {
    final configuredUrl =
    (dotenv.env['BASE_URL'] ?? dotenv.env['API_BASE_URL'])?.trim();

    if (configuredUrl == null || configuredUrl.isEmpty) {
      throw const ChatServiceException(
        'BASE_URL ကို .env ဖိုင်ထဲမှာ ထည့်ပေးပါ။',
      );
    }

    // နောက်ဆုံးမှာပါနေတဲ့ "/" တွေကို ဖယ်မယ်။
    String normalizedUrl = configuredUrl.replaceAll(
      RegExp(r'/+$'),
      '',
    );

    // BASE_URL မှာ endpoint အပြည့်အစုံပါပြီးသားဆို
    // ထပ်မပေါင်းတော့ပါ။
    if (normalizedUrl.endsWith('/api/pet-chat')) {
      return _validateUrl(normalizedUrl);
    }

    // BASE_URL က /api နဲ့ဆုံးရင် /pet-chat ပဲပေါင်းမယ်။
    if (normalizedUrl.endsWith('/api')) {
      normalizedUrl = '$normalizedUrl/pet-chat';
      return _validateUrl(normalizedUrl);
    }

    // Domain သီးသန့်ပဲရှိရင် /api/pet-chat ပေါင်းမယ်။
    normalizedUrl = '$normalizedUrl/api/pet-chat';

    return _validateUrl(normalizedUrl);
  }

  /// URL format မှန်မမှန် စစ်ပေးပါတယ်။
  static Uri _validateUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const ChatServiceException(
        'BASE_URL ပုံစံမမှန်ပါ။ Railway URL ကို ပြန်စစ်ပါ။',
      );
    }

    return uri;
  }

  /// User ရဲ့မေးခွန်းကို BioPet backend ဆီပို့ပြီး
  /// မြန်မာအဖြေကို ပြန်ယူပါတယ်။
  static Future<String> sendMessage(String userText) async {
    final message = userText.trim();

    if (message.isEmpty) {
      throw const ChatServiceException(
        'မေးခွန်းတစ်ခု ရေးပေးပါ။',
      );
    }

    if (message.length > 1000) {
      throw const ChatServiceException(
        'မေးခွန်းက ရှည်လွန်းပါတယ်။ တိုတိုရှင်းရှင်း ပြန်ရေးပေးပါ။',
      );
    }

    final uri = _chatEndpoint;

    if (kDebugMode) {
      debugPrint('BioPet request URL: $uri');
      debugPrint('BioPet user message: $message');
    }

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
          .timeout(const Duration(seconds: 30));

      final responseText = utf8.decode(
        response.bodyBytes,
        allowMalformed: true,
      );

      if (kDebugMode) {
        debugPrint('BioPet response status: ${response.statusCode}');
        debugPrint('BioPet response body: $responseText');
      }

      Map<String, dynamic>? responseData;

      try {
        final dynamic decoded = jsonDecode(responseText);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        } else if (decoded is Map) {
          responseData = Map<String, dynamic>.from(decoded);
        }
      } on FormatException {
        responseData = null;
      }

      // JSON မဟုတ်တဲ့ response ပြန်လာရင်
      if (responseData == null) {
        if (response.statusCode == 404) {
          throw ChatServiceException(
            'Chat route မတွေ့ပါ။ ခေါ်နေတဲ့ URL ကို ပြန်စစ်ပါ။\n'
                'Current URL: $uri',
          );
        }

        if (response.statusCode >= 500) {
          throw const ChatServiceException(
            'Backend server မှာ error ဖြစ်နေပါတယ်။',
          );
        }

        throw const ChatServiceException(
          'Backend က JSON response မှန်မှန်မပို့ပါ။',
        );
      }

      // HTTP status 200–299 မဟုတ်ရင် backend error ကိုပြမယ်။
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _extractErrorMessage(responseData);

        throw ChatServiceException(
          errorMessage ??
              'BioPet server error ဖြစ်နေပါတယ်။ '
                  '(Status: ${response.statusCode})',
        );
      }

      final success = responseData['success'];

      if (success == false) {
        throw ChatServiceException(
          _extractErrorMessage(responseData) ??
              'BioPet AI request မအောင်မြင်ပါ။',
        );
      }

      final reply = responseData['reply']?.toString().trim();

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
    } on ChatServiceException {
      rethrow;
    } on http.ClientException catch (error) {
      if (kDebugMode) {
        debugPrint('BioPet HTTP ClientException: $error');
      }

      throw const ChatServiceException(
        'BioPet backend နဲ့ ဆက်သွယ်မရပါ။ '
            'Internet connection နဲ့ Railway server ကို စစ်ပါ။',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BioPet ChatService error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw const ChatServiceException(
        'မမျှော်လင့်ထားတဲ့ error ဖြစ်နေပါတယ်။',
      );
    }
  }

  /// Backend က ပို့လာနိုင်တဲ့ error field အမျိုးမျိုးကို စစ်ပေးပါတယ်။
  static String? _extractErrorMessage(
      Map<String, dynamic> responseData,
      ) {
    final possibleMessages = [
      responseData['message'],
      responseData['error'],
      responseData['reply'],
    ];

    for (final value in possibleMessages) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }

      if (value is Map) {
        final nestedMessage = value['message']?.toString().trim();

        if (nestedMessage != null && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    return null;
  }
}