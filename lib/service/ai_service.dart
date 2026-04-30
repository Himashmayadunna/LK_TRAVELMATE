import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // API Keys: Separate keys for Chat vs Suggestions to avoid rate limiting conflicts
  static const String _configuredApiKey =
      "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";
  static const String _baseUrl =
      "https://openrouter.ai/api/v1/chat/completions";
  static const String _model = "deepseek/deepseek-r1-0528";

  static String get _apiKey => const String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: _configuredApiKey,
  ).trim();

  // Currently both chat and suggestions use the same key; kept as a separate getter
  // so we can split keys later without touching call sites.
  static String get _suggestionsApiKey => _apiKey;

  static bool get isApiKeyConfigured {
    final key = _apiKey;
    return key.isNotEmpty && key.startsWith('sk-or-v1-');
  }

  // ─── CORE API CALL ──────────────────────────────────────────────────
  static Future<String> _callAI(
    String systemPrompt,
    String userMessage, {
    int maxTokens = 1024,
    String? model,
    bool useSuggestionsKey = false,
  }) async {
    final apiKey = useSuggestionsKey ? _suggestionsApiKey : _apiKey;
    if (apiKey.isEmpty || !apiKey.startsWith('sk-or-v1-')) {
      return 'API Error: OpenRouter API key is missing or invalid.';
    }

    try {
      final useModel = model ?? _model;
      final keyType = useSuggestionsKey ? "Suggestions" : "Chat";
      debugPrint(
        'AIService ($keyType): Calling OpenRouter API with model: $useModel ...',
      );

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              "Authorization": "Bearer $apiKey",
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

          if (response.statusCode == 401) {
            return 'API Error: Unauthorized key. Check your OpenRouter API key.';
          }
          if (response.statusCode == 402) {
            final affordableMatch = RegExp(
              r'can only afford (\d+)',
            ).firstMatch(errorMsg);
            final affordable = affordableMatch?.group(1);
            if (affordable != null) {
              return 'API Error: OpenRouter credits are unavailable (402). '
                  'Affordable max_tokens: $affordable.';
            }
            return 'API Error: OpenRouter credits are unavailable (402). '
                'Top up billing/credits, then retry.';
          }
          if (response.statusCode == 429) {
            return 'API Error: Rate limited by OpenRouter (429). Please try again shortly.';
          }

          return 'API Error (${response.statusCode}): $errorMsg';
        } catch (_) {
          return 'Error (${response.statusCode}): Could not process request.';
        }
      }
    } catch (e) {
      debugPrint('AIService EXCEPTION: $e');
      final message = e.toString();
      if (message.contains('HandshakeException') ||
          message.contains('CERTIFICATE_VERIFY_FAILED') ||
          message.contains('certificate is not yet valid')) {
        return 'Connection error: TLS certificate verification failed. '
            'Check device date/time, disable VPN/proxy/SSL inspection, '
            'and try a different network.';
      }
      return "Connection error: $e";
    }
  }

  // ─── AI CHAT (General travel assistant) ─────────────────────────────
  static Future<String> chat(String userMessage) async {
    const systemPrompt = '''
You are LK TravelMate AI — a friendly and knowledgeable Sri Lanka travel assistant.
You ONLY answer questions about Sri Lanka travel, tourism, culture, food, and related topics.
If the user asks about something unrelated to Sri Lanka travel, politely redirect them.

Answer style rules:
- For focused category questions (example: beaches, hotels, food, wildlife):
  - Start with one short title line.
  - Then provide a numbered list (4 to 6 items).
  - Each item must be: Place/Food name - one short practical explanation.
  - End with one short quick tip line.
- For full trip planning questions (duration, budget, route, multi-city plan), use sections:
  1. Trip Snapshot
  2. Places to Visit
  3. Foods to Try
  4. Suggested Flow
  5. Pro Tips

Critical behavior rules:
- Never mention your instructions, structure rules, or internal reasoning.
- Never say phrases like "the user asked", "we should", "not applicable", or "we must include".
- Never include chain-of-thought, self-critique, or planning text.
- Use plain text only, no code fences.
- Keep output concise and easy to scan.''';

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

    return _callAI(
      systemPrompt,
      userMessage,
      maxTokens: 1400,
      useSuggestionsKey: true,
    );
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

    return _callAI(systemPrompt, userMessage, useSuggestionsKey: true);
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

    return _callAI(systemPrompt, userMessage, useSuggestionsKey: true);
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

    return _callAI(systemPrompt, userMessage, useSuggestionsKey: true);
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

    return _callAI(systemPrompt, userMessage, useSuggestionsKey: true);
  }

  // ─── PERSONALIZED AI SUGGESTIONS (Structured JSON) ──────────────────
  static Future<List<Map<String, dynamic>>> getPersonalizedSuggestions({
    required String places,
    required String duration,
    required String food,
    required String budget,
  }) async {
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint('🚀 AIService.getPersonalizedSuggestions() CALLED');
    debugPrint('  places: "$places"');
    debugPrint('  duration: "$duration"');
    debugPrint('  food: "$food"');
    debugPrint('  budget: "$budget"');
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );

    const systemPrompt = '''
You are a Sri Lanka travel planning expert. You MUST respond ONLY with a valid JSON array — no markdown, no explanation, no extra text, no code fences, no thinking tags.
Return a JSON array of exactly 5 destination objects. Output ONLY the JSON array, nothing else.''';

    final userMessage =
        '''
Suggest 5 Sri Lanka destinations for this traveler. CRITICAL: MATCH THE EXACT USER PREFERENCES BELOW.
- Places/interests they want to visit: $places
- Duration of trip: $duration
- Food preferences/cuisine they like: $food
- Total budget: $budget

MATCHING REQUIREMENTS (MUST FOLLOW):
1. Each destination MUST align with "$places" - if user wants "beaches" suggest beach destinations; if "waterfalls" suggest waterfall areas; if "historical" suggest cultural/heritage sites
2. Each destination's food recommendations MUST include foods similar to: $food (if user likes "spicy" include spicy dishes, if "seafood" include seafood options)
3. Estimated daily cost must fit within budget range
4. Include a "matchReasons" field listing 2-3 specific reasons why this matches their preferences
5. Do NOT suggest generic places if user specified something specific - be precise

Return ONLY a JSON array with these fields per object:
[{"name":"Place Name","location":"District","description":"2 sentence description matching their interests","category":"Beach","budgetLevel":"mid","estimatedCostPerDay":50,"bestTimeToVisit":"Dec - Mar","highlights":["h1","h2","h3"],"matchReasons":["reason1","reason2","reason3"],"insiderTip":"tip","foodRecommendations":["food1","food2"],"howToGetThere":"transport info","imageUrl":"https://...","latitude":6.0324,"longitude":80.2170}]

For imageUrl, prefer reliable Wikimedia Commons or Unsplash direct image links for the exact place.
5 objects. PRIORITY: Match user preferences exactly, then budget fit. Sri Lankan places only. JSON only, no other text.''';

    final models = [
      'google/gemma-3-27b-it:free',
      'qwen/qwen3-coder:free',
      'openai/gpt-oss-20b:free',
      'meta-llama/llama-3.3-70b-instruct:free',
      _model,
    ];
    final tokenPlans = <int>[1200, 900, 700, 500, 350, 250];

    for (final model in models) {
      final attempts = List<int>.from(tokenPlans);
      var attemptIndex = 0;

      while (attemptIndex < attempts.length) {
        final maxTokens = attempts[attemptIndex++];

        try {
          debugPrint('📡 Trying model: $model (max_tokens=$maxTokens)');
          final raw = await _callAI(
            systemPrompt,
            userMessage,
            maxTokens: maxTokens,
            model: model,
            useSuggestionsKey: true,
          );
          debugPrint(
            'AIService: Raw suggestions response length: ${raw.length}',
          );
          debugPrint(
            'AIService: Raw response preview: ${raw.substring(0, raw.length > 300 ? 300 : raw.length)}',
          );

          if (raw.startsWith('API Error') ||
              raw.startsWith('Error') ||
              raw.startsWith('Connection error')) {
            debugPrint('❌ API returned error: $raw');

            final affordableMatch = RegExp(
              r'Affordable max_tokens: (\d+)',
            ).firstMatch(raw);
            if (affordableMatch != null) {
              final affordable = int.tryParse(affordableMatch.group(1)!);
              if (affordable != null) {
                final adjusted = affordable > 80 ? affordable - 80 : affordable;
                if (adjusted > 120 && !attempts.contains(adjusted)) {
                  attempts.add(adjusted);
                  attempts.sort((a, b) => b.compareTo(a));
                  debugPrint(
                    '↩️ Added adaptive retry with max_tokens=$adjusted for low-credit account.',
                  );
                }
              }
            }

            continue;
          }

          final parsed = _parseSuggestions(raw);
          debugPrint(
            '✅ Parsed ${parsed.length} suggestions from API with $model',
          );

          if (parsed.isNotEmpty) {
            debugPrint('📊 API Suggestions BEFORE ranking:');
            for (var i = 0; i < parsed.length; i++) {
              debugPrint(
                '  [$i] ${parsed[i]['name']} - ${parsed[i]['category']}',
              );
            }

            final ranked = _rankSuggestionsByPreferences(
              parsed,
              places: places,
              food: food,
              duration: duration,
              budget: budget,
            );

            debugPrint('📊 Suggestions AFTER ranking and enrichment:');
            for (var i = 0; i < ranked.length; i++) {
              final reasons = ranked[i]['matchReasons'] as List? ?? [];
              debugPrint(
                '  [$i] ${ranked[i]['name']} - ${ranked[i]['category']}',
              );
              debugPrint('       Reasons: ${reasons.join(" | ")}');
            }

            debugPrint(
              '✨ Successfully returning ${ranked.length} ranked suggestions with $model',
            );
            return ranked;
          }

          debugPrint(
            '⚠️  Parsed zero suggestions with $model (max_tokens=$maxTokens), trying next attempt.',
          );
        } catch (e) {
          debugPrint(
            '❌ Failed to parse suggestions with $model (max_tokens=$maxTokens): $e',
          );
        }
      }
    }

    debugPrint('⚠️  All API models failed, using LOCAL FALLBACK suggestions');
    final fallbackSuggestions = _localFallbackSuggestions(
      places: places,
      duration: duration,
      food: food,
      budget: budget,
    );

    debugPrint('📊 Fallback suggestions returned:');
    for (var i = 0; i < fallbackSuggestions.length; i++) {
      final reasons = fallbackSuggestions[i]['matchReasons'] as List? ?? [];
      debugPrint(
        '  [$i] ${fallbackSuggestions[i]['name']} - ${fallbackSuggestions[i]['category']}',
      );
      debugPrint('       Reasons: ${reasons.join(" | ")}');
    }

    return fallbackSuggestions;
  }

  // ─── HOTEL SUGGESTIONS (Structured JSON) ───────────────────────────
  static Future<List<Map<String, dynamic>>> getHotelSuggestions({
    required String place,
    required String details,
    required String notes,
  }) async {
    const systemPrompt = '''
You are a Sri Lanka hotel advisor. You MUST respond ONLY with a valid JSON array - no markdown, no explanation, no extra text, no code fences, no thinking tags.
Return a JSON array of exactly 5 hotel objects. Output ONLY the JSON array, nothing else.''';

    final userMessage = '''
Recommend 5 hotels or hotel areas in Sri Lanka for this traveller.
- Place they want to stay near: $place
- Important place details or preferences: $details
- Extra notes: $notes

MATCHING REQUIREMENTS (MUST FOLLOW):
1. Prioritize hotels near the chosen place or in the best nearby area
2. Match the notes closely, including family, budget, romantic, business, beach, or nature stays
3. Keep the price realistic for Sri Lanka and set estimatedCostPerDay as an approximate nightly rate in USD
4. Include a matchReasons field listing 2-3 specific reasons why this stay matches the input
5. Use Sri Lankan hotels or hotel areas only

Return ONLY a JSON array with these fields per object:
[{"name":"Hotel Name","location":"Area or district","description":"2 sentence description","category":"Hotel","estimatedCostPerDay":120,"bestTimeToVisit":"All year","highlights":["pool","breakfast","sea view"],"matchReasons":["reason1","reason2"],"insiderTip":"booking tip","foodRecommendations":["nearby option 1","nearby option 2"],"howToGetThere":"transport info","imageUrl":"https://..."}]

Give 5 hotel suggestions. Return JSON only.
''';

    final models = [
      'google/gemma-3-27b-it:free',
      'qwen/qwen3-coder:free',
      'openai/gpt-oss-20b:free',
      _model,
    ];

    for (final model in models) {
      try {
        final raw = await _callAI(
          systemPrompt,
          userMessage,
          maxTokens: 1200,
          model: model,
          useSuggestionsKey: true,
        );

        if (raw.startsWith('API Error') ||
            raw.startsWith('Error') ||
            raw.startsWith('Connection error')) {
          continue;
        }

        final parsed = _parseSuggestions(raw);
        if (parsed.isNotEmpty) {
          return parsed;
        }
      } catch (_) {
        continue;
      }
    }

    return _localHotelFallbackSuggestions(
      place: place,
      details: details,
      notes: notes,
    );
  }

  static List<Map<String, dynamic>> _localHotelFallbackSuggestions({
    required String place,
    required String details,
    required String notes,
  }) {
    final query =
        '${place.toLowerCase()} ${details.toLowerCase()} ${notes.toLowerCase()}';

    if (query.contains('ella')) {
      return [
        {
          'name': '98 Acres Resort & Spa',
          'location': 'Ella',
          'description':
              'A signature hill-country stay with dramatic views, relaxed luxury, and easy access to Ella highlights.',
          'category': 'Hotel',
          'estimatedCostPerDay': 180,
          'bestTimeToVisit': 'Jan - Mar',
          'highlights': ['Tea views', 'Spa', 'Scenic pool'],
          'matchReasons': [
            'Perfect for an Ella stay',
            'Great for scenic and romantic trips',
            'Close to hiking spots',
          ],
          'insiderTip': 'Book sunrise-facing rooms early for the best views.',
          'foodRecommendations': [
            'Local hill-country rice and curry',
            'Tea-infused desserts',
          ],
          'howToGetThere':
              'Taxi or tuk-tuk from Ella town; roughly 10 to 15 minutes.',
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/d/d2/SL_Ella_asv2020-01_img22_View_from_Little_Adams_Peak.jpg',
        },
        {
          'name': 'EKHO Ella',
          'location': 'Ella',
          'description':
              'A calm boutique stay that works well for travelers who want comfort, views, and a central base.',
          'category': 'Hotel',
          'estimatedCostPerDay': 140,
          'bestTimeToVisit': 'Jan - Mar',
          'highlights': ['Boutique vibe', 'Hill views', 'Central location'],
          'matchReasons': [
            'Balanced comfort and value',
            'Easy access to Ella town',
            'Good for flexible itineraries',
          ],
          'insiderTip':
              'Choose higher-floor rooms for quieter nights and broader views.',
          'foodRecommendations': ['Hoppers', 'Kottu with local vegetables'],
          'howToGetThere':
              'Short transfer from Ella Railway Station or town center.',
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/d/d2/SL_Ella_asv2020-01_img22_View_from_Little_Adams_Peak.jpg',
        },
      ];
    }

    if (query.contains('galle') ||
        query.contains('beach') ||
        query.contains('mirissa')) {
      return [
        {
          'name': 'Jetwing Lighthouse',
          'location': 'Galle',
          'description':
              'A polished seaside hotel with easy access to Galle Fort and coastal experiences.',
          'category': 'Hotel',
          'estimatedCostPerDay': 170,
          'bestTimeToVisit': 'Nov - Apr',
          'highlights': ['Sea view', 'Pool', 'Great location'],
          'matchReasons': [
            'Ideal for a coast-focused stay',
            'Great base for Galle and nearby beaches',
            'Comfortable for couples and families',
          ],
          'insiderTip':
              'Reserve sunset hours for a relaxed drink by the coast.',
          'foodRecommendations': ['Seafood platters', 'Coconut-based curries'],
          'howToGetThere': 'About 15 minutes by taxi from Galle Fort.',
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/5/5a/Unawatuna_beach.jpg',
        },
        {
          'name': 'Cinnamon Bey Beruwala',
          'location': 'Beruwala',
          'description':
              'A large beach resort that suits travelers who want a relaxed seaside stay with plenty of amenities.',
          'category': 'Hotel',
          'estimatedCostPerDay': 155,
          'bestTimeToVisit': 'Nov - Apr',
          'highlights': ['Beachfront', 'Large pool', 'Family friendly'],
          'matchReasons': [
            'Strong value for a beach holiday',
            'Easy access to water activities',
            'Good for longer stays',
          ],
          'insiderTip':
              'Ask for a room facing the quieter side of the property.',
          'foodRecommendations': [
            'Fresh grilled fish',
            'Sri Lankan breakfast hoppers',
          ],
          'howToGetThere':
              'Drive south from Colombo along the coastal highway.',
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/f/f1/Coconut_Tree_Hill%2C_Mirissa.jpg',
        },
      ];
    }

    if (query.contains('sigiriya') ||
        query.contains('dambulla') ||
        query.contains('heritage') ||
        query.contains('history')) {
      return [
        {
          'name': 'Heritance Kandalama',
          'location': 'Kandalama',
          'description':
              'An iconic eco-luxury stay close to Sigiriya and Dambulla, with a strong nature-first feel.',
          'category': 'Hotel',
          'estimatedCostPerDay': 190,
          'bestTimeToVisit': 'Jan - Apr',
          'highlights': ['Eco design', 'Lake views', 'Luxury stay'],
          'matchReasons': [
            'Great for cultural sightseeing',
            'Close to Sigiriya and Dambulla',
            'Strong fit for premium travelers',
          ],
          'insiderTip':
              'Plan early-morning departures for the fortress and caves.',
          'foodRecommendations': ['Village rice and curry', 'Local fruit juices'],
          'howToGetThere':
              'Taxi from Dambulla or Sigiriya; around 30 minutes depending on traffic.',
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/1/1f/Sigiriya_Luftbild_%2829781064900%29.jpg',
        },
        {
          'name': 'Aliya Resort & Spa',
          'location': 'Sigiriya',
          'description':
              'A relaxed resort near the rock fortress, popular with travelers who want space and convenience.',
          'category': 'Hotel',
          'estimatedCostPerDay': 145,
          'bestTimeToVisit': 'Jan - Apr',
          'highlights': ['Pool', 'Family friendly', 'Near Sigiriya'],
          'matchReasons': [
            'Ideal for sightseeing logistics',
            'Comfortable for families',
            'Good value near heritage sites',
          ],
          'insiderTip':
              'Start excursions before the midday heat builds up.',
          'foodRecommendations': ['Buffet rice and curry', 'Fresh lime juice'],
          'howToGetThere': 'Short transfer from Sigiriya or Dambulla.',
          'imageUrl':
              'https://upload.wikimedia.org/wikipedia/commons/1/1f/Sigiriya_Luftbild_%2829781064900%29.jpg',
        },
      ];
    }

    return [
      {
        'name': 'Marino Beach Colombo',
        'location': 'Colombo',
        'description':
            'A modern city hotel that works well for business trips, short stopovers, and easy access to Colombo attractions.',
        'category': 'Hotel',
        'estimatedCostPerDay': 160,
        'bestTimeToVisit': 'All year',
        'highlights': ['Rooftop pool', 'Central location', 'City views'],
        'matchReasons': [
          'Strong all-round city option',
          'Good for short stays and transfers',
          'Fits both business and leisure trips',
        ],
        'insiderTip':
            'Book early for weekend stays if you want a sea-facing room.',
        'foodRecommendations': ['Seafood rice', 'Short-eats and bakery items'],
        'howToGetThere':
            'Easy taxi ride from Colombo Fort or Bandaranaike Airport transfer routes.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/1/14/Colombo_skyline.jpg',
      },
      {
        'name': 'The Grand Hotel',
        'location': 'Nuwara Eliya',
        'description':
            'A classic hill-country stay that suits travelers who want cooler weather and an old-world atmosphere.',
        'category': 'Hotel',
        'estimatedCostPerDay': 150,
        'bestTimeToVisit': 'Feb - Apr',
        'highlights': ['Cool climate', 'Historic charm', 'Tea country base'],
        'matchReasons': [
          'Good fit for a scenic hill stay',
          'Matches relaxed or romantic trips',
          'Convenient for tea country sightseeing',
        ],
        'insiderTip': 'Carry a light jacket even during the day.',
        'foodRecommendations': [
          'Fresh scones and tea',
          'Hill-country vegetable curries',
        ],
        'howToGetThere': 'Drive or taxi from Nanu Oya station into town.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/7/7a/Tea_plantations_in_Nuwara_Eliya.jpg',
      },
      {
        'name': '98 Acres Resort & Spa',
        'location': 'Ella',
        'description':
            'A signature hill-country stay with dramatic views, relaxed luxury, and easy access to Ella highlights.',
        'category': 'Hotel',
        'estimatedCostPerDay': 180,
        'bestTimeToVisit': 'Jan - Mar',
        'highlights': ['Tea views', 'Spa', 'Scenic pool'],
        'matchReasons': [
          'Perfect for scenic and romantic trips',
          'Close to hiking spots',
          'Popular with nature-focused travelers',
        ],
        'insiderTip': 'Book sunrise-facing rooms early for the best views.',
        'foodRecommendations': [
          'Local hill-country rice and curry',
          'Tea-infused desserts',
        ],
        'howToGetThere':
            'Taxi or tuk-tuk from Ella town; roughly 10 to 15 minutes.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/d/d2/SL_Ella_asv2020-01_img22_View_from_Little_Adams_Peak.jpg',
      },
    ];
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
        'matchReasons': _toStringList(
          _firstAvailable([
            map['matchReasons'],
            map['matchReason'],
            map['reasons'],
          ]),
          const ['Recommended for you', 'Great value'],
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

      if (map['latitude'] != null) {
        normalizedItem['latitude'] = map['latitude'];
      }
      if (map['longitude'] != null) {
        normalizedItem['longitude'] = map['longitude'];
      }

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
            'Iconic beach with calm waters, perfect for snorkeling and sunset watching.',
        'category': 'Beach',
        'budgetLevel': 'budget',
        'estimatedCostPerDay': 55,
        'bestTimeToVisit': 'Nov - Apr',
        'highlights': ['Calm beach', 'Snorkeling', 'Sunset cafes'],
        'insiderTip': 'Visit Jungle Beach in the morning to avoid crowds.',
        'foodRecommendations': ['Seafood kottu', 'Grilled prawns'],
        'matchReasons': [],
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
        'matchReasons': [],
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
        'matchReasons': [],
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
        'matchReasons': [],
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
        'matchReasons': [],
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
        'matchReasons': [],
        'howToGetThere': 'Bus or car to Tissamaharama, then safari transport.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/6/6b/Yala_National_Park%2C_Sri_Lanka.jpg',
      },
      {
        'name': 'Diyaluma Falls',
        'location': 'Badulla',
        'description':
            'Second tallest waterfall in Sri Lanka with natural pools and dramatic views.',
        'category': 'Waterfall',
        'budgetLevel': 'mid',
        'estimatedCostPerDay': 42,
        'bestTimeToVisit': 'Jan - Apr',
        'highlights': ['Upper pools', 'Scenic hike', 'Sunrise views'],
        'insiderTip':
            'Start early and carry water shoes for slippery rock sections.',
        'foodRecommendations': ['Parippu curry', 'Egg roti'],
        'matchReasons': [],
        'howToGetThere':
            'Bus or taxi to Koslanda, then a short tuk-tuk and hike.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/3/35/Diyaluma_Falls_01.jpg',
      },
      {
        'name': 'Bambarakanda Falls',
        'location': 'Badulla',
        'description':
            'Sri Lanka\'s tallest waterfall surrounded by pine forest and cool mountain air.',
        'category': 'Waterfall',
        'budgetLevel': 'budget',
        'estimatedCostPerDay': 38,
        'bestTimeToVisit': 'Dec - Apr',
        'highlights': ['Forest trail', 'Photo viewpoints', 'Cool climate'],
        'insiderTip':
            'Visit on weekdays to avoid local holiday crowds at the entrance.',
        'foodRecommendations': ['String hoppers', 'Lunu miris'],
        'matchReasons': [],
        'howToGetThere':
            'Travel via Belihuloya and continue by tuk-tuk to the falls.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/a/a9/Bambarakanda_Falls.jpg',
      },
      {
        'name': 'Dunhinda Falls',
        'location': 'Badulla',
        'description':
            'A misty waterfall reached by a scenic walk through thick greenery.',
        'category': 'Waterfall',
        'budgetLevel': 'budget',
        'estimatedCostPerDay': 35,
        'bestTimeToVisit': 'Nov - Mar',
        'highlights': ['Mist cloud', 'Nature trail', 'Bird calls'],
        'insiderTip':
            'Carry a light rain jacket because spray near the base is strong.',
        'foodRecommendations': ['Lamprais', 'Wade and tea'],
        'matchReasons': [],
        'howToGetThere':
            'Take a bus to Badulla and tuk-tuk to the Dunhinda entrance.',
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/2/2c/Dunhinda_Falls_Sri_Lanka.jpg',
      },
    ];

    final query = '$places $food'.toLowerCase();
    final primaryIntent = _detectPrimaryIntent(places);

    final scored = base.map((item) {
      var score = _scoreForPreferences(item, places: places, food: food);
      if (query.contains('sri lanka')) {
        score += 1;
      }
      return {'score': score, 'item': item};
    }).toList();

    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    final maxPerDay = _estimateDailyBudget(budget: budget, duration: duration);

    // STRICT INTENT FILTERING: Only return suggestions matching user's primary intent
    final suggestions = <Map<String, dynamic>>[];
    final seenNames = <String>{};

    if (primaryIntent != null) {
      debugPrint('[FALLBACK-INTENT] Filtering for: $primaryIntent');
      // FIRST: Add only suggestions that match the primary intent
      for (final entry in scored) {
        if (suggestions.length >= 5) break;
        final item = Map<String, dynamic>.from(entry['item'] as Map);
        final name = item['name'].toString();
        if (seenNames.contains(name)) continue;

        if (_matchesPrimaryIntent(item, primaryIntent)) {
          final cost = item['estimatedCostPerDay'] as int? ?? 50;
          if (cost <= maxPerDay + 30) {
            suggestions.add(item);
            seenNames.add(name);
          }
        }
      }
    }

    // FALLBACK: If not enough matching, add non-blocking suggestions
    if (suggestions.length < 5) {
      for (final entry in scored) {
        if (suggestions.length >= 5) break;
        final item = Map<String, dynamic>.from(entry['item'] as Map);
        final name = item['name'].toString();
        if (seenNames.contains(name)) continue;

        // Skip if it blocks the primary intent
        if (primaryIntent != null &&
            _blocksPrimaryIntent(item, primaryIntent)) {
          continue;
        }

        final cost = item['estimatedCostPerDay'] as int? ?? 50;
        if (cost <= maxPerDay + 30) {
          suggestions.add(item);
          seenNames.add(name);
        }
      }
    }

    return _enrichWithMatchReasons(
      suggestions,
      places: places,
      food: food,
      duration: duration,
      budget: budget,
    );
  }

  static List<Map<String, dynamic>> _rankSuggestionsByPreferences(
    List<Map<String, dynamic>> suggestions, {
    required String places,
    required String food,
    required String duration,
    required String budget,
  }) {
    if (suggestions.isEmpty) return suggestions;

    final maxPerDay = _estimateDailyBudget(budget: budget, duration: duration);
    final primaryIntent = _detectPrimaryIntent(places);
    final scored = suggestions.map((item) {
      var score = _scoreForPreferences(item, places: places, food: food);
      final estimated = _parseCost([
        item['estimatedCostPerDay'],
        item['budgetPerDay'],
        item['estimatedCost'],
      ], fallback: maxPerDay);

      // Strongly prefer suggestions inside the requested price band.
      final diff = (estimated - maxPerDay).abs();
      if (diff <= 20) {
        score += 3;
      } else if (estimated > maxPerDay + 45) {
        score -= 5;
      }

      // STRONGLY boost matching primary intent
      if (primaryIntent != null && _matchesPrimaryIntent(item, primaryIntent)) {
        score += 20; // Major boost for intent matching
      }

      // HEAVILY penalize conflicting primary intent
      if (primaryIntent != null && _blocksPrimaryIntent(item, primaryIntent)) {
        score -= 15;
      }

      return {'score': score, 'item': item};
    }).toList();

    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    final ranked = <Map<String, dynamic>>[];
    final seenNames = <String>{};

    void addFromScored(Iterable<Map<String, dynamic>> items) {
      for (final entry in items) {
        final item = Map<String, dynamic>.from(entry['item'] as Map);
        final name = item['name'].toString();
        if (seenNames.contains(name)) continue;
        ranked.add(item);
        seenNames.add(name);
        if (ranked.length == 5) return;
      }
    }

    if (primaryIntent != null) {
      addFromScored(
        scored.where(
          (entry) => _matchesPrimaryIntent(
            Map<String, dynamic>.from(entry['item'] as Map),
            primaryIntent,
          ),
        ),
      );

      if (ranked.length < 5) {
        addFromScored(
          scored.where(
            (entry) => !_blocksPrimaryIntent(
              Map<String, dynamic>.from(entry['item'] as Map),
              primaryIntent,
            ),
          ),
        );
      }
    } else {
      addFromScored(scored);
    }

    if (ranked.length >= 5) {
      return _enrichWithMatchReasons(
        ranked.take(5).toList(),
        places: places,
        food: food,
        duration: duration,
        budget: budget,
      );
    }

    // FALLBACK: Use local suggestions to fill remaining spots
    debugPrint(
      'AIService: Using fallback suggestions (${5 - ranked.length} more needed)',
    );
    final fallback = _localFallbackSuggestions(
      places: places,
      duration: duration,
      food: food,
      budget: budget,
    );

    // If we have an intent, try to fill with matching fallback items first!
    if (primaryIntent != null) {
      for (final item in fallback) {
        if (ranked.length == 5) break;
        if (seenNames.contains(item['name'].toString())) continue;

        if (_matchesPrimaryIntent(item, primaryIntent)) {
          debugPrint(
            'AIService: Adding fallback suggestion (matches intent): ${item['name']}',
          );
          ranked.add(item);
          seenNames.add(item['name'].toString());
        }
      }

      // If STILL short, add non-blocking from API
      if (ranked.length < 5) {
        final nonBlocking = scored.where(
          (entry) => !_blocksPrimaryIntent(
            Map<String, dynamic>.from(entry['item'] as Map),
            primaryIntent,
          ),
        );
        addFromScored(nonBlocking);
      }
    }

    // Add remaining fallback items if still needed
    for (final item in fallback) {
      if (ranked.length == 5) break;
      if (ranked.any((e) => e['name'] == item['name'])) continue;
      if (primaryIntent != null &&
          !_matchesPrimaryIntent(item, primaryIntent) &&
          _blocksPrimaryIntent(item, primaryIntent)) {
        continue;
      }
      ranked.add(item);
      seenNames.add(item['name'].toString());
    }

    return _enrichWithMatchReasons(
      ranked,
      places: places,
      food: food,
      duration: duration,
      budget: budget,
    );
  }

  static List<Map<String, dynamic>> _enrichWithMatchReasons(
    List<Map<String, dynamic>> suggestions, {
    required String places,
    required String food,
    required String duration,
    required String budget,
  }) {
    return suggestions.map((item) {
      final reasons = _generateMatchReasons(
        item: item,
        places: places,
        food: food,
        duration: duration,
        budget: budget,
      );

      final enriched = Map<String, dynamic>.from(item);
      enriched['matchReasons'] = reasons;
      return enriched;
    }).toList();
  }

  static List<String> _generateMatchReasons({
    required Map<String, dynamic> item,
    required String places,
    required String food,
    required String duration,
    required String budget,
  }) {
    final reasons = <String>[];

    final itemName = item['name']?.toString().toLowerCase() ?? '';
    final itemCategory = item['category']?.toString().toLowerCase() ?? '';
    final itemDesc = item['description']?.toString().toLowerCase() ?? '';
    final itemFood =
        (item['foodRecommendations'] as List?)
            ?.map((f) => f.toString().toLowerCase())
            .join(' ') ??
        '';
    final itemHighlights =
        (item['highlights'] as List?)
            ?.map((h) => h.toString().toLowerCase())
            .join(' ') ??
        '';
    final combinedItem = '$itemName $itemCategory $itemDesc $itemHighlights'
        .toLowerCase();

    final placesNorm = places.toLowerCase();
    final foodNorm = food.toLowerCase();
    final budgetNum = _extractBudgetNumber(budget);
    final costPerDay = _parseCost([item['estimatedCostPerDay']], fallback: 50);

    debugPrint('🔍 _generateMatchReasons for "${item['name']}"');
    debugPrint('   Budget parsed: \${budgetNum}');
    debugPrint('   Max per day: \${maxPerDay}');

    // === PRIORITY 1: Check place/category matching ===

    // BEACHES
    if (_containsAny(placesNorm, const ['beach', 'coast', 'shore'])) {
      debugPrint('   ✓ User wants BEACHES');
      if (_containsAny(combinedItem, const [
        'beach',
        'coast',
        'shore',
        'unawatuna',
        'mirissa',
        'arugambe',
      ])) {
        reasons.add('Perfect beach destination matching your request');
        debugPrint('     ✅ Item matches beach');
      } else {
        debugPrint(
          '     ❌ Item does NOT match beach (combined: "$combinedItem")',
        );
      }
    }
    // WATERFALLS
    else if (_containsAny(placesNorm, const [
      'waterfall',
      'falls',
      'cascade',
    ])) {
      debugPrint('   ✓ User wants WATERFALLS');
      if (_containsAny(combinedItem, const [
        'waterfall',
        'falls',
        'cascade',
        'diyaluma',
        'bambarakanda',
        'dunhinda',
      ])) {
        reasons.add('Excellent waterfall destination matching your request');
        debugPrint('     ✅ Item matches waterfall');
      } else {
        debugPrint('     ❌ Item does NOT match waterfall');
      }
    }
    // HIKING/MOUNTAINS
    else if (_containsAny(placesNorm, const [
      'mountain',
      'hiking',
      'trek',
      'hill',
      'peak',
      'climb',
    ])) {
      debugPrint('   ✓ User wants HIKING');
      if (_containsAny(combinedItem, const [
        'hiking',
        'trek',
        'mountain',
        'hill',
        'peak',
        'ella',
        'climb',
        'trail',
      ])) {
        reasons.add('Great hiking and mountain destination for you');
        debugPrint('     ✅ Item matches hiking');
      } else {
        debugPrint('     ❌ Item does NOT match hiking');
      }
    }
    // CULTURAL/HERITAGE
    else if (_containsAny(placesNorm, const [
      'cultural',
      'heritage',
      'temple',
      'history',
      'ancient',
      'historic',
    ])) {
      debugPrint('   ✓ User wants CULTURAL');
      if (_containsAny(combinedItem, const [
        'temple',
        'heritage',
        'cultural',
        'historic',
        'ancient',
        'sigiriya',
        'kandy',
      ])) {
        reasons.add('Rich cultural heritage site matching your interests');
        debugPrint('     ✅ Item matches cultural');
      } else {
        debugPrint('     ❌ Item does NOT match cultural');
      }
    }
    // WILDLIFE/SAFARI
    else if (_containsAny(placesNorm, const [
      'wildlife',
      'safari',
      'animal',
      'leopard',
      'elephant',
      'park',
    ])) {
      debugPrint('   ✓ User wants WILDLIFE');
      if (_containsAny(combinedItem, const [
        'wildlife',
        'safari',
        'leopard',
        'elephant',
        'yala',
        'park',
      ])) {
        reasons.add('Premier wildlife and safari destination for you');
        debugPrint('     ✅ Item matches wildlife');
      } else {
        debugPrint('     ❌ Item does NOT match wildlife');
      }
    }
    // If no specific category matched but user requested specific type, still provide relevant reason
    else if (placesNorm.isNotEmpty && placesNorm.length > 2) {
      debugPrint('   ! User has preferences but no category match found');
      reasons.add('Popular Sri Lanka destination');
    }

    // === PRIORITY 2: Check food matching ===
    if (foodNorm.isNotEmpty &&
        !_containsAny(foodNorm, const [
          'any',
          'anything',
          'n/a',
          'none',
          'no preference',
        ])) {
      if (_containsAny(foodNorm, const ['spicy', 'curry', 'hot', 'chilli']) &&
          _containsAny(itemFood + itemDesc, const [
            'curry',
            'devilled',
            'kottu',
            'spicy',
            'chilli',
          ])) {
        reasons.add('Serves spicy Sri Lankan curries you\'ll enjoy');
        debugPrint('     ✅ Food: Spicy match');
      } else if (_containsAny(foodNorm, const [
            'seafood',
            'fish',
            'prawn',
            'shrimp',
          ]) &&
          _containsAny(itemFood, const [
            'seafood',
            'fish',
            'prawn',
            'shrimp',
            'cuttlefish',
            'crab',
          ])) {
        reasons.add('Offers fresh local seafood specialties');
        debugPrint('     ✅ Food: Seafood match');
      } else if (_containsAny(foodNorm, const ['vegetarian', 'vegan']) &&
          (_containsAny(itemFood, const ['curry', 'rice', 'vegetable']) ||
              itemFood.contains('curry'))) {
        reasons.add('Has great vegetarian and plant-based options');
        debugPrint('     ✅ Food: Vegetarian match');
      }
    }

    // === PRIORITY 3: Check budget matching ===
    if (budgetNum > 0) {
      if (costPerDay <= budgetNum * 0.5) {
        reasons.add('Excellent value - just \$$costPerDay/day');
        debugPrint('     ✅ Budget: Excellent value');
      } else if (costPerDay <= budgetNum * 0.8) {
        reasons.add('Great value at \$$costPerDay/day');
        debugPrint('     ✅ Budget: Great value');
      } else if (costPerDay <= budgetNum) {
        reasons.add('Fits perfectly within your \$$budgetNum budget');
        debugPrint('     ✅ Budget: Fits budget');
      }
    }

    // === FINAL FALLBACK: If still no reasons, generate generic ones ===
    if (reasons.isEmpty) {
      reasons.add('Highly recommended Sri Lanka destination');
      if (costPerDay > 0) {
        reasons.add('Affordable at \$$costPerDay per day');
      }
      debugPrint('     ⚠️  NO MATCH - Using generic fallback reasons');
    }

    debugPrint('   Final reasons: ${reasons.take(3).toList().join(" | ")}');

    // Return top 2-3 reasons
    return reasons.take(3).toList();
  }

  static int _extractBudgetNumber(String budget) {
    final match = RegExp(r'\d+').firstMatch(budget);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 0;
    }
    return 0;
  }

  static String? _detectPrimaryIntent(String places) {
    final normalized = _normalizeForMatch(places);
    if (_containsAny(normalized, const ['waterfall', 'waterfalls', 'falls'])) {
      return 'waterfall';
    }
    if (_containsAny(normalized, const ['beach', 'coast'])) return 'beach';
    if (_containsAny(normalized, const ['hiking', 'trek', 'mountain'])) {
      return 'hiking';
    }
    if (_containsAny(normalized, const ['temple', 'heritage', 'cultural'])) {
      return 'cultural';
    }
    if (_containsAny(normalized, const ['wildlife', 'safari'])) {
      return 'wildlife';
    }
    return null;
  }

  static bool _matchesPrimaryIntent(Map<String, dynamic> item, String intent) {
    final text = _normalizeForMatch(
      [
        item['name'],
        item['location'],
        item['category'],
        item['description'],
        item['highlights'],
      ].join(' '),
    );

    switch (intent) {
      case 'waterfall':
        return _containsAny(text, const ['waterfall', 'falls']);
      case 'beach':
        return _containsAny(text, const ['beach', 'coast']);
      case 'hiking':
        return _containsAny(text, const [
          'hiking',
          'trail',
          'hill',
          'mountain',
        ]);
      case 'cultural':
        return _containsAny(text, const ['temple', 'heritage', 'cultural']);
      case 'wildlife':
        return _containsAny(text, const ['wildlife', 'safari', 'park']);
      default:
        return false;
    }
  }

  static bool _blocksPrimaryIntent(Map<String, dynamic> item, String intent) {
    final text = _normalizeForMatch(
      [
        item['name'],
        item['location'],
        item['category'],
        item['description'],
        item['highlights'],
      ].join(' '),
    );

    switch (intent) {
      case 'waterfall':
        return _containsAny(text, const ['beach', 'coast']);
      case 'beach':
        return _containsAny(text, const ['waterfall', 'falls']);
      case 'cultural':
        return _containsAny(text, const [
          'beach',
          'coast',
          'waterfall',
          'falls',
        ]);
      case 'hiking':
        return _containsAny(text, const [
          'beach',
          'coast',
          'temple',
          'heritage',
          'cultural',
        ]);
      case 'wildlife':
        return _containsAny(text, const [
          'beach',
          'coast',
          'temple',
          'heritage',
          'cultural',
        ]);
      default:
        return false;
    }
  }

  static int _scoreForPreferences(
    Map<String, dynamic> item, {
    required String places,
    required String food,
  }) {
    final text = _normalizeForMatch(
      [
        item['name'],
        item['location'],
        item['category'],
        item['description'],
        item['highlights'],
      ].join(' '),
    );

    final userPlaces = _normalizeForMatch(places);
    final userFood = _normalizeForMatch(food);
    var score = 0;

    final wantsWaterfall = _containsAny(userPlaces, const [
      'waterfall',
      'waterfalls',
      'falls',
    ]);
    final wantsBeach = _containsAny(userPlaces, const ['beach', 'coast']);
    final wantsHiking = _containsAny(userPlaces, const [
      'hiking',
      'trek',
      'mountain',
    ]);
    final wantsCultural = _containsAny(userPlaces, const [
      'temple',
      'heritage',
      'cultural',
    ]);
    final wantsWildlife = _containsAny(userPlaces, const [
      'wildlife',
      'safari',
    ]);

    if (userPlaces.isNotEmpty) {
      final isWaterfall = _containsAny(text, const ['waterfall', 'falls']);
      final isBeach = _containsAny(text, const ['beach', 'coast']);
      final isHiking = _containsAny(text, const [
        'hiking',
        'trail',
        'hill',
        'mountain',
      ]);
      final isCultural = _containsAny(text, const [
        'temple',
        'heritage',
        'cultural',
      ]);
      final isWildlife = _containsAny(text, const [
        'wildlife',
        'safari',
        'park',
      ]);

      if (wantsWaterfall) {
        score += isWaterfall ? 14 : -6;
      }
      if (wantsBeach) {
        score += isBeach ? 10 : -4;
      }
      if (wantsHiking) {
        score += isHiking ? 8 : -3;
      }
      if (wantsCultural) {
        score += isCultural ? 8 : -3;
      }
      if (wantsWildlife) {
        score += isWildlife ? 8 : -3;
      }
    }

    if (userFood.isNotEmpty && userFood != 'any local food') {
      final itemFood = _normalizeForMatch(
        [
          item['foodRecommendations'],
          item['description'],
          item['category'],
        ].join(' '),
      );
      if (_containsAny(userFood, const ['seafood', 'fish', 'prawn', 'crab']) &&
          _containsAny(itemFood, const ['seafood', 'fish', 'prawn', 'crab'])) {
        score += 6;
      }
      if (_containsAny(userFood, const ['spicy', 'curry']) &&
          _containsAny(itemFood, const ['spicy', 'curry'])) {
        score += 3;
      }
      if (_containsAny(userFood, const ['street', 'kottu']) &&
          _containsAny(itemFood, const ['street', 'kottu'])) {
        score += 3;
      }
    }

    if (_containsAny(userPlaces, const ['galle']) && text.contains('galle')) {
      score += 2;
    }
    if (_containsAny(userPlaces, const ['ella']) && text.contains('ella')) {
      score += 2;
    }

    return score;
  }

  static String _normalizeForMatch(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  static bool _containsAny(String text, List<String> tokens) {
    for (final token in tokens) {
      if (text.contains(token)) return true;
    }
    return false;
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
