import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TranslationService {
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';
  static const String _contactEmail = 'YourEmail@gmail.com';

  // Map full language names used in UI to ISO language codes.
  static const Map<String, String> languageCodes = {
    'English': 'en',
    'Sinhala': 'si',
    'Tamil': 'ta',
    'Russian': 'ru',
    'French': 'fr',
    'German': 'de',
    'Spanish': 'es',
    'Italian': 'it',
    'Portuguese': 'pt',
    'Dutch': 'nl',
    'Arabic': 'ar',
    'Hindi': 'hi',
    'Urdu': 'ur',
    'Chinese': 'zh-CN',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Thai': 'th',
    'Malay': 'ms',
    'Indonesian': 'id',
    'Turkish': 'tr',
    'Polish': 'pl',
    'Ukrainian': 'uk',
    'Greek': 'el',
    'Hebrew': 'he',
    'Swedish': 'sv',
    'Norwegian': 'no',
    'Danish': 'da',
    'Finnish': 'fi',
  };

  static Future<String> translate(String text, String from, String to) async {
    final String cleanedText = text.trim();
    if (cleanedText.isEmpty) {
      throw Exception('Please enter text to translate.');
    }

    final String fromCode = languageCodes[from] ?? from.toLowerCase();
    final String toCode = languageCodes[to] ?? to.toLowerCase();

    final Uri uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'q': cleanedText,
        'langpair': '$fromCode|$toCode',
        'de': _contactEmail,
      },
    );

    try {
      final http.Response response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Translation API failed: HTTP ${response.statusCode}.');
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic>? responseData =
          data['responseData'] as Map<String, dynamic>?;

      if (responseData == null) {
        throw Exception('Invalid response from translation service.');
      }

      final String translated =
          (responseData['translatedText'] as String? ?? '').trim();

      if (translated.isEmpty) {
        throw Exception('No translation returned from the API.');
      }

      return translated;
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FormatException {
      throw Exception('Unexpected response format from translation service.');
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }
}
