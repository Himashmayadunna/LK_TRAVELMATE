import 'dart:async';
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
  static Future<String> _callAI(
    String systemPrompt,
    String userMessage, {
    int maxTokens = 1024,
    String? model,
  }) async {
    try {
      final useModel = model ?? _model;
      debugPrint('AIService: Calling OpenRouter API with model: $useModel ...');

      final response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('AIService: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = _extractMessageContent(data);
        // Also strip <think> blocks in case they appear in content
        return content
            .replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '')
            .trim();
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

When a user asks for recommendations, itinerary, places, or food:
- Prioritize practical suggestions for tourists.
- Include BOTH sections: "Places to Visit" and "Foods to Try".
- Match suggestions to user preferences, duration, and budget when provided.

Use this clean display format:
1) Trip Snapshot (2-3 bullet points)
2) Places to Visit (3-5 items with location, why visit, best time, approx cost/day)
3) Foods to Try (3-5 items and best area/place to try each)
4) Suggested Flow (short route order)
5) Pro Tips (2-3 concise tips)

Keep responses concise (under 260 words), helpful, and enthusiastic.
Use occasional emojis to keep it friendly.''';

    return _callAI(systemPrompt, userMessage);
  }

  // ─── TOURIST SUGGESTIONS (Places + Food) ──────────────────────────
  static Future<String> getTouristSuggestions({
    required String places,
    required String duration,
    required String food,
    required String budget,
  }) async {
    const systemPrompt = '''
You are LK TravelMate AI, an expert Sri Lanka trip advisor.
Return practical, tourist-ready recommendations in plain text only (no JSON, no markdown code fences).
Always include both place recommendations and food recommendations.
Keep tone friendly and concise.''';

    final userMessage =
        '''
Create personalized Sri Lanka suggestions for this traveler:
- Places/interests: $places
- Trip duration: $duration
- Food preference: $food
- Budget: $budget

Use exactly this output structure:
Trip Snapshot:
- ...
- ...

Places to Visit:
1. Place name (Location)
   - Why visit:
   - Best time:
   - Approx cost/day:
   - Food nearby:

Foods to Try:
1. Food name
   - Where to try:
   - Taste profile:
   - Typical price:

Suggested Flow:
- Day/stop order in one short line

Pro Tips:
- 2 to 3 practical tips for transport, crowds, and local etiquette

Give 4 place suggestions and 4 food suggestions. Match budget and preferences closely.
''';

    return _callAI(systemPrompt, userMessage, maxTokens: 1400);
  }

  // ─── GENERATE ITINERARY ─────────────────────────────────────────────
  static Future<String> generateItinerary({
    required String interest,
    required String budget,
    required String duration,
  }) async {
    const systemPrompt =
        'You are a Sri Lanka travel planning expert. Create concise, practical day-by-day itineraries.';

    final userMessage =
        '''
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

    final userMessage =
        '''
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

    final userMessage =
        '''
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

    final userMessage =
        '''
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

    final userMessage =
        '''
Suggest 5 Sri Lanka destinations for this traveler:
- Places they want to visit or are interested in: $places
- Duration of trip: $duration
- Food preferences: $food
- Total budget: $budget

Return ONLY a JSON array with these fields per object:
[{"name":"Place Name","location":"District","description":"2 sentence description","category":"Beach","budgetLevel":"mid","estimatedCostPerDay":50,"bestTimeToVisit":"Dec - Mar","highlights":["h1","h2","h3"],"insiderTip":"tip","foodRecommendations":["food1","food2"],"howToGetThere":"transport info","imageUrl":"https://...","latitude":6.0324,"longitude":80.2170}]

For imageUrl, prefer reliable Wikimedia Commons or Unsplash direct image links for the exact place.
5 objects. Match food preferences and budget. Sri Lankan places only. JSON only, no other text.''';

    final models = ['deepseek/deepseek-chat', _model];

    for (final model in models) {
      try {
        final raw = await _callAI(
          systemPrompt,
          userMessage,
          maxTokens: 4096,
          model: model,
        );
        debugPrint('AIService: Raw suggestions response length: ${raw.length}');
        debugPrint(
          'AIService: Raw response preview: ${raw.substring(0, raw.length > 300 ? 300 : raw.length)}',
        );
        if (raw.startsWith('API Error') ||
            raw.startsWith('Error') ||
            raw.startsWith('Connection error')) {
          debugPrint('AIService: API returned error: $raw');
          continue;
        }

        final parsed = _parseSuggestions(raw);
        if (parsed.isNotEmpty) {
          debugPrint(
            'AIService: Successfully parsed ${parsed.length} suggestions with $model',
          );
          return parsed;
        }

        debugPrint(
          'AIService: Parsed zero suggestions with $model, trying fallback model.',
        );
      } catch (e) {
        debugPrint('AIService: Failed to parse suggestions with $model: $e');
      }
    }

    debugPrint('AIService: Using local fallback suggestions.');
    return _localFallbackSuggestions(
      places: places,
      duration: duration,
      food: food,
      budget: budget,
    );
  }

  static String _extractMessageContent(dynamic responseData) {
    try {
      final choices = responseData['choices'];
      if (choices is! List || choices.isEmpty) return '';

      final message = choices.first['message'];
      if (message is! Map) return '';

      final content = message['content'];
      if (content is String) return content;

      // Some providers return a list of content parts.
      if (content is List) {
        final parts = content
            .whereType<Map>()
            .map((part) => part['text']?.toString() ?? '')
            .where((text) => text.trim().isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join('\n');
      }

      final reasoning = message['reasoning']?.toString() ?? '';
      if (reasoning.trim().isNotEmpty) return reasoning;
    } catch (_) {
      return '';
    }
    return '';
  }

  static List<Map<String, dynamic>> _parseSuggestions(String raw) {
    final cleaned = _stripCodeFences(raw.trim());

    final direct = _decodeSuggestionsPayload(cleaned);
    if (direct.isNotEmpty) return direct;

    final extractedArray = _extractBalancedJsonArray(cleaned);
    if (extractedArray != null) {
      final fromExtracted = _decodeSuggestionsPayload(extractedArray);
      if (fromExtracted.isNotEmpty) return fromExtracted;
    }

    final extractedObject = _extractBalancedJsonObject(cleaned);
    if (extractedObject != null) {
      return _decodeSuggestionsPayload(extractedObject);
    }

    return [];
  }

  static String _stripCodeFences(String text) {
    final fence = RegExp(
      r'^```(?:json)?\s*([\s\S]*?)\s*```$',
      multiLine: false,
    );
    final match = fence.firstMatch(text);
    if (match != null) {
      return (match.group(1) ?? text).trim();
    }
    return text;
  }

  static List<Map<String, dynamic>> _decodeSuggestionsPayload(String text) {
    try {
      final dynamic decoded = jsonDecode(text);

      if (decoded is List) {
        return _normalizeSuggestionList(decoded);
      }

      if (decoded is Map<String, dynamic>) {
        for (final key in const [
          'suggestions',
          'destinations',
          'places',
          'recommendations',
          'items',
        ]) {
          final candidate = decoded[key];
          if (candidate is List) {
            return _normalizeSuggestionList(candidate);
          }
        }
      }
    } catch (_) {
      return [];
    }

    return [];
  }

  static List<Map<String, dynamic>> _normalizeSuggestionList(
    List<dynamic> data,
  ) {
    final normalized = <Map<String, dynamic>>[];

    for (final item in data) {
      if (item is! Map) continue;

      final map = item.map((key, value) => MapEntry(key.toString(), value));
      final name = _firstNonEmptyString([
        map['name'],
        map['title'],
        map['place'],
        map['destination'],
      ], fallback: 'Sri Lanka Destination');

      final normalizedItem = <String, dynamic>{
        'name': name,
        'location': _firstNonEmptyString([
          map['location'],
          map['district'],
          map['area'],
          map['region'],
        ], fallback: 'Sri Lanka'),
        'description': _firstNonEmptyString([
          map['description'],
          map['summary'],
          map['details'],
        ], fallback: 'Beautiful location worth visiting.'),
        'category': _firstNonEmptyString([
          map['category'],
          map['type'],
          map['theme'],
        ], fallback: 'Travel'),
        'budgetLevel': _firstNonEmptyString([
          map['budgetLevel'],
          map['budget'],
        ], fallback: 'mid'),
        'estimatedCostPerDay': _parseCost([
          map['estimatedCostPerDay'],
          map['costPerDay'],
          map['estimatedCost'],
          map['budgetPerDay'],
          map['pricePerDay'],
        ], fallback: 50),
        'bestTimeToVisit': _firstNonEmptyString([
          map['bestTimeToVisit'],
          map['bestTime'],
          map['season'],
        ], fallback: 'All year'),
        'highlights': _toStringList(
          _firstAvailable([
            map['highlights'],
            map['attractions'],
            map['topThings'],
          ]),
          const ['Scenic views', 'Local culture'],
        ),
        'insiderTip': _firstNonEmptyString([
          map['insiderTip'],
          map['tip'],
          map['localTip'],
        ], fallback: 'Visit early morning for fewer crowds.'),
        'foodRecommendations': _toStringList(
          _firstAvailable([
            map['foodRecommendations'],
            map['foods'],
            map['recommendedFoods'],
          ]),
          const ['Rice and curry'],
        ),
        'howToGetThere': _firstNonEmptyString([
          map['howToGetThere'],
          map['transport'],
          map['gettingThere'],
        ], fallback: 'Travel by bus, train, or taxi from Colombo.'),
        'imageUrl': _firstNonEmptyString([
          map['imageUrl'],
          map['image'],
          map['photoUrl'],
        ], fallback: ''),
      };

      if (map['latitude'] != null) normalizedItem['latitude'] = map['latitude'];
      if (map['longitude'] != null)
        normalizedItem['longitude'] = map['longitude'];

      normalized.add(normalizedItem);
      if (normalized.length == 5) break;
    }

    return normalized;
  }

  static dynamic _firstAvailable(List<dynamic> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }

  static String _firstNonEmptyString(
    List<dynamic> values, {
    required String fallback,
  }) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static int _parseCost(List<dynamic> values, {required int fallback}) {
    for (final value in values) {
      if (value == null) continue;
      if (value is num) return value.round();

      final text = value.toString();
      final match = RegExp(r'\d+').firstMatch(text);
      if (match != null) {
        final parsed = int.tryParse(match.group(0)!);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  static List<String> _toStringList(dynamic value, List<String> fallback) {
    if (value is List) {
      final data = value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (data.isNotEmpty) return data;
    }
    return fallback;
  }

  static String? _extractBalancedJsonArray(String text) {
    return _extractBalancedJson(text, open: '[', close: ']');
  }

  static String? _extractBalancedJsonObject(String text) {
    return _extractBalancedJson(text, open: '{', close: '}');
  }

  static String? _extractBalancedJson(
    String text, {
    required String open,
    required String close,
  }) {
    final start = text.indexOf(open);
    if (start == -1) return null;

    var depth = 0;
    var inString = false;
    var escaped = false;

    for (var i = start; i < text.length; i++) {
      final ch = text[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (ch == '\\') {
        escaped = true;
        continue;
      }

      if (ch == '"') {
        inString = !inString;
        continue;
      }

      if (inString) continue;

      if (ch == open) depth++;
      if (ch == close) {
        depth--;
        if (depth == 0) {
          return text.substring(start, i + 1);
        }
      }
    }

    return null;
  }

  static List<Map<String, dynamic>> _localFallbackSuggestions({
    required String places,
    required String duration,
    required String food,
    required String budget,
  }) {
    final base = <Map<String, dynamic>>[
      {
        'name': 'Unawatuna Beach',
        'location': 'Galle',
        'description':
            'A relaxed southern beach town with golden sand, swimmable water, and lively cafes.',
        'category': 'Beach',
        'budgetLevel': 'mid',
        'estimatedCostPerDay': 60,
        'bestTimeToVisit': 'Nov - Apr',
        'highlights': ['Calm beach', 'Snorkeling', 'Sunset cafes'],
        'insiderTip': 'Visit Jungle Beach in the morning to avoid crowds.',
        'foodRecommendations': ['Seafood kottu', 'Grilled prawns'],
        'howToGetThere':
            'Train or highway bus from Colombo to Galle, then tuk-tuk.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/5/5a/Unawatuna_beach.jpg',
      },
      {
        'name': 'Mirissa',
        'location': 'Matara',
        'description':
            'Popular for whale watching, palm-lined beaches, and fresh seafood by the coast.',
        'category': 'Beach',
        'budgetLevel': 'mid',
        'estimatedCostPerDay': 65,
        'bestTimeToVisit': 'Nov - Apr',
        'highlights': [
          'Whale watching',
          'Coconut Tree Hill',
          'Beach nightlife',
        ],
        'insiderTip':
            'Book whale tours from the harbor directly for better prices.',
        'foodRecommendations': ['Devilled cuttlefish', 'Seafood rice'],
        'howToGetThere':
            'Train to Weligama/Mirissa area, then short tuk-tuk ride.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/f/f1/Coconut_Tree_Hill%2C_Mirissa.jpg',
      },
      {
        'name': 'Sigiriya',
        'location': 'Matale',
        'description':
            'Ancient rock fortress with panoramic views and world-renowned cultural heritage.',
        'category': 'Cultural',
        'budgetLevel': 'mid',
        'estimatedCostPerDay': 55,
        'bestTimeToVisit': 'Jan - Apr',
        'highlights': ['Lion Rock', 'Frescoes', 'Pidurangala sunrise'],
        'insiderTip': 'Start climbing before 7 AM to beat heat and queues.',
        'foodRecommendations': ['Village rice and curry', 'Wood-apple juice'],
        'howToGetThere':
            'Bus or taxi from Dambulla; nearest rail hub is Habarana.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/4/4c/Sigiriya_%28Lion_Rock%29%2C_Sri_Lanka.jpg',
      },
      {
        'name': 'Ella',
        'location': 'Badulla',
        'description':
            'Cool hill-country escape known for scenic train routes, tea views, and hikes.',
        'category': 'Hill Country',
        'budgetLevel': 'mid',
        'estimatedCostPerDay': 50,
        'bestTimeToVisit': 'Jan - Mar',
        'highlights': [
          'Nine Arches Bridge',
          'Little Adam\'s Peak',
          'Tea estates',
        ],
        'insiderTip':
            'See Nine Arches Bridge around train passing times for best photos.',
        'foodRecommendations': ['Hot butter cuttlefish', 'Ceylon tea'],
        'howToGetThere':
            'Scenic train from Kandy or bus routes via Bandarawela.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/a/a5/Ella_Rock_from_Little_Adam%27s_Peak.jpg',
      },
      {
        'name': 'Kandy',
        'location': 'Kandy',
        'description':
            'Historic city centered around the Temple of the Tooth and scenic lake walks.',
        'category': 'Cultural',
        'budgetLevel': 'budget',
        'estimatedCostPerDay': 45,
        'bestTimeToVisit': 'Dec - Apr',
        'highlights': [
          'Temple of the Tooth',
          'Kandy Lake',
          'Cultural dance show',
        ],
        'insiderTip':
            'Visit the temple in the evening for a more atmospheric experience.',
        'foodRecommendations': ['Kottu roti', 'Kiribath'],
        'howToGetThere': 'Frequent train and bus services from Colombo.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/c/c4/Sri_Dalada_Maligawa.jpg',
      },
      {
        'name': 'Yala National Park',
        'location': 'Hambantota',
        'description':
            'Top wildlife destination for leopard sightings, elephants, and safari landscapes.',
        'category': 'Wildlife',
        'budgetLevel': 'premium',
        'estimatedCostPerDay': 90,
        'bestTimeToVisit': 'Feb - Jul',
        'highlights': ['Safari jeeps', 'Leopard tracking', 'Birdwatching'],
        'insiderTip':
            'Choose half-day early safari for better wildlife activity.',
        'foodRecommendations': ['Rice packets', 'Grilled fish'],
        'howToGetThere': 'Bus or car to Tissamaharama, then safari transport.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/6/6b/Yala_National_Park%2C_Sri_Lanka.jpg',
      },
    ];

    final query = '$places $food'.toLowerCase();
    final scored = base.map((item) {
      var score = 0;
      final category = item['category'].toString().toLowerCase();
      final name = item['name'].toString().toLowerCase();
      if (query.contains('beach') && category.contains('beach')) score += 4;
      if (query.contains('seafood') &&
          item['foodRecommendations'].toString().toLowerCase().contains(
            'sea',
          )) {
        score += 4;
      }
      if (query.contains('wild') && category.contains('wildlife')) score += 3;
      if (query.contains('culture') && category.contains('cultural'))
        score += 3;
      if (query.contains('hill') && category.contains('hill')) score += 3;
      if (query.contains('galle') && name.contains('unawatuna')) score += 2;
      if (query.contains('ella') && name.contains('ella')) score += 2;
      return {'score': score, 'item': item};
    }).toList();

    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    final maxPerDay = _estimateDailyBudget(budget: budget, duration: duration);
    final suggestions = scored
        .map((entry) => Map<String, dynamic>.from(entry['item'] as Map))
        .where(
          (item) =>
              item['estimatedCostPerDay'] is int &&
              (item['estimatedCostPerDay'] as int) <= maxPerDay + 30,
        )
        .take(5)
        .toList();

    if (suggestions.length < 5) {
      for (final entry in scored) {
        if (suggestions.length == 5) break;
        final candidate = Map<String, dynamic>.from(entry['item'] as Map);
        if (suggestions.any((e) => e['name'] == candidate['name'])) continue;
        suggestions.add(candidate);
      }
    }

    return suggestions;
  }

  static int _estimateDailyBudget({
    required String budget,
    required String duration,
  }) {
    final total = int.tryParse(
      RegExp(r'\d+').firstMatch(budget)?.group(0) ?? '0',
    );
    final days = int.tryParse(
      RegExp(r'\d+').firstMatch(duration)?.group(0) ?? '1',
    );
    if (total != null && total > 0 && days != null && days > 0) {
      return (total / days).round();
    }

    final text = budget.toLowerCase();
    if (text.contains('low') || text.contains('budget')) return 45;
    if (text.contains('high') || text.contains('premium')) return 110;
    return 70;
  }
}
