import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  // ✅ OpenAI API key (sk-... နဲ့စတယ်)
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<String> sendMessage(String userText) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('❌ API Key not found. Please add OPENAI_API_KEY to .env file');
      }

      final url = Uri.parse(baseUrl);

      print('📡 Sending request to OpenAI API...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": userText}
          ]
        }),
      );
      print('📥 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        try {
          // ✅ OpenAI response က ဒီလိုယူတယ်
          final text = data['choices'][0]['message']['content'];
          return text.trim();
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['error']?['message'] ?? 'Unknown error';
        throw Exception('API Error: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('❌ ChatService Error: $e');
      throw Exception('Network Error: $e');
    }
  }
}