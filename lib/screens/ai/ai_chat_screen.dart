import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../service/ai_service.dart';

// ─────────────────────────────────────────────
// Shared loading notifier (file-level, not private to any class)
// ─────────────────────────────────────────────
final ValueNotifier<bool> _chatLoadingNotifier = ValueNotifier(false);

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

// ─────────────────────────────────────────────
// Full-screen version (with Scaffold + AppBar)
// ─────────────────────────────────────────────
class AIChatScreen extends StatelessWidget {
  final String? initialPrompt;
  const AIChatScreen({super.key, this.initialPrompt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ValueListenableBuilder<bool>(
          valueListenable: _chatLoadingNotifier,
          builder: (context, isLoading, _) {
            return Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: const Center(
                    child: Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Travel Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      isLoading ? 'Thinking...' : 'Online',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLoading ? AppTheme.gold : AppTheme.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: AIChatScreenBody(initialPrompt: initialPrompt),
    );
  }
}

// ─────────────────────────────────────────────
// Body-only version (can be embedded in tabs)
// ─────────────────────────────────────────────
class AIChatScreenBody extends StatefulWidget {
  final String? initialPrompt;
  const AIChatScreenBody({super.key, this.initialPrompt});

  @override
  State<AIChatScreenBody> createState() => _AIChatScreenBodyState();
}

class _AIChatScreenBodyState extends State<AIChatScreenBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const List<Map<String, String>> _suggestions = [
    {'label': 'Best beaches', 'prompt': 'What are the best beaches to visit in Sri Lanka?', 'icon': 'beach_access'},
    {'label': 'Hiking trails', 'prompt': 'Recommend top hiking trails in Sri Lanka', 'icon': 'terrain'},
    {'label': 'Local food', 'prompt': 'What are must-try Sri Lankan foods and where to find them?', 'icon': 'restaurant'},
    {'label': 'Budget tips', 'prompt': 'How can I travel Sri Lanka on a tight budget?', 'icon': 'payments'},
    {'label': '7-day plan', 'prompt': 'Create a 7-day Sri Lanka itinerary for a first-time visitor', 'icon': 'event_note'},
    {'label': 'Wildlife', 'prompt': 'Best places for wildlife safari in Sri Lanka?', 'icon': 'parks'},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: "Hello! I'm your LK TravelMate AI assistant.\n\n"
          "I can help you with:\n"
          "• Destination recommendations\n"
          "• Trip itineraries\n"
          "• Budget planning\n"
          "• Food and culture tips\n\n"
          "Ask me anything about Sri Lanka travel!",
      isUser: false,
    ));

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _chatLoadingNotifier.value = false;
    super.dispose();
  }

  Future<String> _getAIResponse(String prompt) async {
    try {
      final response = await GeminiService.chat(prompt);
      if (response.trim().isEmpty) {
        return _buildOfflineTravelResponse(prompt);
      }
      if (response.startsWith('API Error:') ||
          response.startsWith('Error (') ||
          response.startsWith('Connection error:')) {
        return _buildOfflineTravelResponse(prompt);
      }
      if (_isMetaOrLowQualityResponse(response)) {
        return _buildOfflineTravelResponse(prompt);
      }
      return response;
    } catch (e) {
      return _buildOfflineTravelResponse(prompt);
    }
  }

  bool _isMetaOrLowQualityResponse(String response) {
    final text = response.toLowerCase();
    final badSignals = <String>[
      'the user asked',
      'we should',
      'we can adapt',
      'not applicable for this query',
      'our structure requires',
      'we must include',
      'how to structure for this query',
      're-read instruction',
      'actually, we are',
      'instead, we can',
    ];

    for (final signal in badSignals) {
      if (text.contains(signal)) {
        return true;
      }
    }

    return false;
  }

  String _buildOfflineTravelResponse(String prompt) {
    final query = prompt.toLowerCase();

    if (query.contains('hotel') || query.contains('stay') || query.contains('accommodation')) {
      return '''Best Hotels in Sri Lanka

1. Colombo - best for city access, business stays, and easy transport.
2. Kandy - best for culture, lake views, and mid-range comfort.
3. Ella - best for scenic hill-country views and cozy boutique stays.
4. Mirissa - best for beach resorts, sunsets, and relaxed coastal trips.

Quick tip: choose Colombo for convenience, Kandy for culture, Ella for views, and Mirissa for beach holidays.''';
    }

    if (query.contains('food') || query.contains('eat') || query.contains('restaurant')) {
      return '''Must-Try Sri Lankan Foods

1. Kottu Roti - street food favorite with chopped roti, vegetables, egg, or meat.
2. Hoppers (Appa) - bowl-shaped breakfast item, crispy on the edges and soft in the middle.
3. Rice and Curry - the classic daily meal with many vegetable and meat options.
4. Lamprais - rice, meat, sambol, and curry wrapped in banana leaf.

Quick tip: try kottu in Colombo, hoppers in local breakfast spots, and rice and curry in small family restaurants.''';
    }

    if (query.contains('beach')) {
      return '''Best Beaches in Sri Lanka

1. Mirissa - best for whale watching and sunset beach cafes.
2. Unawatuna - best for calm swimming and snorkeling.
3. Hiriketiya - best for surfing and a small scenic bay.
4. Bentota - best for family-friendly beach resorts and water sports.

Quick tip: Mirissa for vibe, Unawatuna for swimming, Hiriketiya for surfing, Bentota for resort stays.''';
    }

    if (query.contains('wildlife') || query.contains('safari')) {
      return '''Best Wildlife Spots in Sri Lanka

1. Yala National Park - best for leopard sightings and jeep safaris.
2. Udawalawe - best for elephants and easy safari trips.
3. Wilpattu - best for quieter safaris and large park landscapes.
4. Minneriya - best for the elephant gathering season.

Quick tip: choose Yala for leopards, Udawalawe for elephants, and Wilpattu for a quieter experience.''';
    }

    return '''Sri Lanka Travel Suggestions

1. Colombo - best for arrival, shopping, and city convenience.
2. Kandy - best for culture and central travel access.
3. Ella - best for hills, train rides, and cool weather.
4. Mirissa - best for beaches, whale watching, and sunsets.

Tell me if you want beaches, hotels, food, wildlife, or a full itinerary and I’ll break it down more clearly.''';
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _isLoading = true;
      _chatLoadingNotifier.value = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await _getAIResponse(text.trim());

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: response, isUser: false));
      _isLoading = false;
      _chatLoadingNotifier.value = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? AppTheme.primary : AppTheme.surface,
          gradient: message.isUser ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppTheme.radiusLarge),
            topRight: const Radius.circular(AppTheme.radiusLarge),
            bottomLeft: Radius.circular(message.isUser ? AppTheme.radiusLarge : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : AppTheme.radiusLarge),
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.auto_awesome, size: 11, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Assistant',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            message.isUser
                ? SelectableText(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  )
                : _buildStructuredAssistantMessage(message.text),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredAssistantMessage(String text) {
    final blocks = _parseAssistantResponse(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        switch (block.type) {
          case _AssistantBlockType.title:
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _normalizeAssistantText(block.text),
                style: AppTheme.labelBold.copyWith(
                  fontSize: 16,
                  height: 1.25,
                  color: AppTheme.textPrimary,
                ),
              ),
            );
          case _AssistantBlockType.heading:
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _normalizeAssistantText(block.text),
                      style: AppTheme.labelBold.copyWith(
                        fontSize: 15,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            );
          case _AssistantBlockType.numbered:
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.divider, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      block.indexLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(text: _normalizeAssistantText(block.text)),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          case _AssistantBlockType.bullet:
            return Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(text: _normalizeAssistantText(block.text)),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          case _AssistantBlockType.body:
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text.rich(
                TextSpan(text: _normalizeAssistantText(block.text)),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppTheme.textPrimary,
                ),
              ),
            );
        }
      }).toList(),
    );
  }

  List<_AssistantBlock> _parseAssistantResponse(String text) {
    final lines = text.replaceAll('\r\n', '\n').split('\n');
    final blocks = <_AssistantBlock>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      final headingMatch = RegExp(r'^(#{1,3})\s*(.+)$').firstMatch(line);
      if (headingMatch != null) {
        final heading = _stripMarkdownMarkers(headingMatch.group(2)!.trim());
        blocks.add(_AssistantBlock.heading(heading));
        continue;
      }

      final numberMatch = RegExp(r'^(\d+)\.\s*(.+)$').firstMatch(line);
      if (numberMatch != null) {
        final label = numberMatch.group(1)!;
        final content = _stripMarkdownMarkers(numberMatch.group(2)!.trim());
        blocks.add(_AssistantBlock.numbered(indexLabel: label, text: content));
        continue;
      }

      final bulletMatch = RegExp(r'^[-*•]\s*(.+)$').firstMatch(line);
      if (bulletMatch != null) {
        blocks.add(_AssistantBlock.bullet(_stripMarkdownMarkers(bulletMatch.group(1)!.trim())));
        continue;
      }

      final cleaned = _stripMarkdownMarkers(line);
      final isTitle = blocks.isEmpty && cleaned.length <= 80;
      blocks.add(isTitle ? _AssistantBlock.title(cleaned) : _AssistantBlock.body(cleaned));
    }

    return blocks;
  }

  String _stripMarkdownMarkers(String input) {
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    final italicPattern = RegExp(r'\*(.+?)\*');

    var output = input;
    output = output.replaceAllMapped(boldPattern, (match) => match.group(1) ?? '');
    output = output.replaceAllMapped(italicPattern, (match) => match.group(1) ?? '');
    output = output.replaceAll(RegExp(r'^\$\d+\s*'), '');
    output = output.replaceAll(RegExp(r'\s+'), ' ').trim();
    output = output.replaceAll(RegExp(r'\s+([,.;:!?])'), r'$1');
    return output;
  }

  String _normalizeAssistantText(String text) {
    var output = _stripMarkdownMarkers(text)
        .replaceAll(RegExp(r'\s*\*\s*'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    output = output.replaceAllMapped(
      RegExp(r'\s+([,.;:!?])'),
      (match) => match.group(1) ?? '',
    );

    return output.trim();
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BouncingDot(delay: Duration.zero),
            SizedBox(width: 4),
            _BouncingDot(delay: Duration(milliseconds: 200)),
            SizedBox(width: 4),
            _BouncingDot(delay: Duration(milliseconds: 400)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestions.map((s) {
          return GestureDetector(
            onTap: () => _sendMessage(s['prompt']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                border: Border.all(color: AppTheme.primarySoft, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_suggestionIconFor(s['icon']), size: 14, color: AppTheme.primaryDark),
                  const SizedBox(width: 6),
                  Text(
                    s['label']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _suggestionIconFor(String? iconName) {
    switch (iconName) {
      case 'beach_access':
        return Icons.beach_access_rounded;
      case 'terrain':
        return Icons.terrain_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'event_note':
        return Icons.event_note_rounded;
      case 'parks':
        return Icons.pets_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                border: Border.all(color: AppTheme.divider, width: 1),
              ),
              child: TextField(
                controller: _controller,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: InputDecoration(
                  hintText: 'Ask about Sri Lanka travel...',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isLoading ? null : () => _sendMessage(_controller.text),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: _isLoading ? null : AppTheme.primaryGradient,
                color: _isLoading ? AppTheme.textHint : null,
                shape: BoxShape.circle,
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: const Center(
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isLoading) {
                return _buildTypingIndicator();
              }
              return _buildMessageBubble(_messages[index]);
            },
          ),
        ),
        if (_messages.length <= 2) _buildSuggestions(),
        _buildInputBar(),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Looping bouncing dot for typing indicator
// ─────────────────────────────────────────────
class _BouncingDot extends StatefulWidget {
  final Duration delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: child,
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

enum _AssistantBlockType { title, heading, numbered, bullet, body }

class _AssistantBlock {
  final _AssistantBlockType type;
  final String text;
  final String indexLabel;

  const _AssistantBlock._(
  this.type,
  this.text, {
  this.indexLabel = '',
  });

  factory _AssistantBlock.title(String text) =>
    _AssistantBlock._(_AssistantBlockType.title, text);

  factory _AssistantBlock.heading(String text) =>
    _AssistantBlock._(_AssistantBlockType.heading, text);

  factory _AssistantBlock.numbered({required String indexLabel, required String text}) =>
    _AssistantBlock._(_AssistantBlockType.numbered, text, indexLabel: indexLabel);

  factory _AssistantBlock.bullet(String text) =>
    _AssistantBlock._(_AssistantBlockType.bullet, text);

  factory _AssistantBlock.body(String text) =>
    _AssistantBlock._(_AssistantBlockType.body, text);
}