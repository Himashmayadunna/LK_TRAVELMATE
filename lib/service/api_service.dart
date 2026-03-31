import 'dart:convert';

import 'package:http/http.dart' as http;

class AiTravelApiService {
  AiTravelApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _geminiModel = 'gemini-1.5-flash';

  Future<String> getTravelSuggestion({required String userPrompt}) async {
    final apiKey = const String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      return _fallback(userPrompt);
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$apiKey',
    );

    final systemInstruction =
        'You are LK TravelMate AI. Give practical Sri Lanka travel advice. '
        'Always include place ideas, estimated budget ranges (LKR), and '
        'transport tips when relevant. Keep answers concise, clear, and friendly.';

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': systemInstruction},
              ],
            },
            'contents': [
              {
                'parts': [
                  {'text': userPrompt},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 700,
            },
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return _fallback(userPrompt);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = (data['candidates'] as List<dynamic>?);
    if (candidates == null || candidates.isEmpty) {
      return _fallback(userPrompt);
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return _fallback(userPrompt);
    }

    final text = parts
        .whereType<Map<String, dynamic>>()
        .map((part) => part['text'])
        .whereType<String>()
        .join('\n')
        .trim();

    return text.isEmpty ? _fallback(userPrompt) : text;
  }

  String _fallback(String userPrompt) {
    final lower = userPrompt.toLowerCase();

    if (lower.contains('budget') || lower.contains('cheap')) {
      return 'Budget-friendly Sri Lanka plan:\n\n'
          '• Stay in hostels/guesthouses: LKR 5,000-9,000 per night\n'
          '• Local meals: LKR 800-2,000 per day\n'
          '• Bus/train transport: LKR 500-2,500 per route\n'
          '• Daily backpacker budget: LKR 8,000-16,000\n\n'
          'Top value places: Ella, Kandy, Sigiriya, Mirissa.';
    }

    return 'Try this Sri Lanka starter itinerary:\n\n'
        '• Cultural: Sigiriya + Dambulla\n'
        '• Scenic: Kandy to Ella train ride\n'
        '• Beach: Mirissa or Unawatuna\n'
        '• Wildlife: Yala or Udawalawe safari\n\n'
        'Estimated mid-range budget: LKR 18,000-35,000 per day (stay, food, transport, activities).';
  }

  void dispose() {
    _client.close();
  }
}