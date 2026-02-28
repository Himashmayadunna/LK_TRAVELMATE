import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey =
      "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";
  static const String _baseUrl =
      "https://openrouter.ai/api/v1/chat/completions";
  static const String _model = "deepseek/deepseek-r1-0528";

  // ─── CORE API CALL ──────────────────────────────────────────────────
  static Future<String> _callAI(String systemPrompt, String userMessage,
      {int maxTokens = 1024, String? model}) async {
    try {
      final useModel = model ?? _model;
      debugPrint('AIService: Calling OpenRouter API with model: $useModel ...');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://lk-travelmate.app",
          "X-Title": "LK TravelMate",
        },
        body: jsonEncode({
          "model": useModel,
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userMessage},
          ],
          "max_tokens": maxTokens,
          "temperature": 0.7,
        }),
      );

      debugPrint('AIService: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // OpenRouter puts content in 'content' and reasoning separately
        final content =
            (data['choices'][0]['message']['content'] as String?) ?? '';
        // Also strip <think> blocks in case they appear in content
        return content.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '').trim();
      } else {
        debugPrint('AIService ERROR: ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
          return "API Error: $errorMsg";
        } catch (_) {
          return "Error (${response.statusCode}): Could not process request.";
        }
      }
    } catch (e) {
      debugPrint('AIService EXCEPTION: $e');
      return "Connection error: $e";
    }
  }

  // ─── AI CHAT (General travel assistant) ─────────────────────────────
  static Future<String> chat(String userMessage) async {
    const systemPrompt = '''
You are LK TravelMate AI — a friendly and knowledgeable Sri Lanka travel assistant.
You ONLY answer questions about Sri Lanka travel, tourism, culture, food, and related topics.
If the user asks about something unrelated to Sri Lanka travel, politely redirect them.

Keep responses concise (under 200 words), helpful, and enthusiastic.
Use occasional emojis to keep it friendly.''';

    return _callAI(systemPrompt, userMessage);
  }

  // ─── GENERATE ITINERARY ─────────────────────────────────────────────
  static Future<String> generateItinerary({
    required String interest,
    required String budget,
    required String duration,
  }) async {
    const systemPrompt =
        'You are a Sri Lanka travel planning expert. Create concise, practical day-by-day itineraries.';

    final userMessage = '''
Create a travel itinerary with these preferences:
- Interest: $interest
- Budget Level: $budget
- Duration: $duration

Include:
- Day-by-day plan with specific places in Sri Lanka
- Estimated costs in USD
- Travel tips for each day
- Best time to visit each location

Format it cleanly with day headers and bullet points. Keep it under 500 words.''';

    return _callAI(systemPrompt, userMessage);
  }

  // ─── DESTINATION RECOMMENDATION ─────────────────────────────────────
  static Future<String> getRecommendation({
    String? category,
    String? budget,
  }) async {
    const systemPrompt =
        'You are a Sri Lanka travel expert who gives concise, practical destination recommendations.';

    final userMessage = '''
Recommend the top 3 must-visit destinations in Sri Lanka.
${category != null ? 'Category preference: $category' : ''}
${budget != null ? 'Budget level: $budget' : ''}

For each destination provide:
- Name and location
- Why it's special (1-2 sentences)
- Best time to visit
- Budget tip

Use emojis for visual appeal.''';

    return _callAI(systemPrompt, userMessage);
  }

  // ─── DESTINATION DETAILS ────────────────────────────────────────────
  static Future<String> getDestinationDetails(String destinationName) async {
    const systemPrompt =
        'You are a Sri Lanka travel expert who provides detailed, practical travel information.';

    final userMessage = '''
Provide detailed travel info about "$destinationName" in Sri Lanka.

Include:
- Brief description (2-3 sentences)
- Top 3 things to do there
- How to get there from Colombo
- Estimated budget (budget/mid-range/premium) per day in USD
- Best time to visit
- One insider tip

Keep it under 200 words.''';

    return _callAI(systemPrompt, userMessage);
  }

  // ─── TRAVEL TIPS ────────────────────────────────────────────────────
  static Future<String> getTravelTips(String topic) async {
    const systemPrompt =
        'You are a Sri Lanka travel expert who gives practical, actionable travel tips with local insights.';

    final userMessage = '''
Give practical travel tips about: "$topic" in Sri Lanka.

Provide 5 concise, actionable tips. Include local insights that most tourists miss.
Keep each tip to 1-2 sentences. Use emojis for visual appeal.''';

    return _callAI(systemPrompt, userMessage);
  }

  // ─── PERSONALIZED AI SUGGESTIONS (Structured JSON) ──────────────────
  static Future<List<Map<String, dynamic>>> getPersonalizedSuggestions({
    required String places,
    required String duration,
    required String food,
    required String budget,
  }) async {
    const systemPrompt = '''
You are a Sri Lanka travel planning expert. You MUST respond ONLY with a valid JSON array — no markdown, no explanation, no extra text, no code fences, no thinking tags.
Return a JSON array of exactly 5 destination objects. Output ONLY the JSON array, nothing else.''';

    final userMessage = '''
Suggest 5 Sri Lanka destinations for this traveler:
- Places they want to visit or are interested in: $places
- Duration of trip: $duration
- Food preferences: $food
- Total budget: $budget

Return ONLY a JSON array with these fields per object:
[{"name":"Place Name","location":"District","description":"2 sentence description","category":"Beach","budgetLevel":"mid","estimatedCostPerDay":50,"bestTimeToVisit":"Dec - Mar","highlights":["h1","h2","h3"],"insiderTip":"tip","foodRecommendations":["food1","food2"],"howToGetThere":"transport info","latitude":6.0324,"longitude":80.2170}]

5 objects. Match food preferences and budget. Sri Lankan places only. JSON only, no other text.''';

    try {
      final raw = await _callAI(systemPrompt, userMessage,
          maxTokens: 4096, model: 'deepseek/deepseek-chat');
      debugPrint('AIService: Raw suggestions response length: ${raw.length}');
      debugPrint('AIService: Raw response preview: ${raw.substring(0, raw.length > 300 ? 300 : raw.length)}');

      // Check if the response is an error message
      if (raw.startsWith('API Error') ||
          raw.startsWith('Error') ||
          raw.startsWith('Connection error')) {
        debugPrint('AIService: API returned error: $raw');
        return [];
      }

      final jsonStr = _extractJson(raw);
      final List<dynamic> parsed = jsonDecode(jsonStr);
      debugPrint('AIService: Successfully parsed ${parsed.length} suggestions');
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('AIService: Failed to parse suggestions: $e');
      return [];
    }
  }

  /// Extracts the first JSON array found in a string
  static String _extractJson(String text) {
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    throw const FormatException('No JSON array found in response');
  }
}