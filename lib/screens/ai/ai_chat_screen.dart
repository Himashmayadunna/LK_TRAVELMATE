import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

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
                    child: Text('🤖', style: TextStyle(fontSize: 18)),
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
    {'label': '🏖️ Best beaches', 'prompt': 'What are the best beaches to visit in Sri Lanka?'},
    {'label': '🥾 Hiking trails', 'prompt': 'Recommend top hiking trails in Sri Lanka'},
    {'label': '🍛 Local food',    'prompt': 'What are must-try Sri Lankan foods and where to find them?'},
    {'label': '💰 Budget tips',   'prompt': 'How can I travel Sri Lanka on a tight budget?'},
    {'label': '📅 7-day plan',    'prompt': 'Create a 7-day Sri Lanka itinerary for a first-time visitor'},
    {'label': '🐘 Wildlife',      'prompt': 'Best places for wildlife safari in Sri Lanka?'},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: "Hello! 👋 I'm your LK TravelMate AI assistant.\n\n"
          "I can help you with:\n"
          "• 🗺️ Destination recommendations\n"
          "• 📅 Trip itineraries\n"
          "• 💰 Budget planning\n"
          "• 🍛 Food & culture tips\n\n"
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

  Future<String> _mockResponse(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return 'Great question about Sri Lanka! 🌴\n\n'
        'Sri Lanka offers incredible experiences for every traveler. '
        'From the ancient rock fortress of Sigiriya to the pristine beaches of Mirissa, '
        "and the misty tea plantations of Ella — there's something for everyone.\n\n"
        'Popular highlights include:\n'
        '• 🏛️ Sigiriya Rock Fortress\n'
        '• 🏖️ Mirissa & Unawatuna Beaches\n'
        '• 🚂 Kandy to Ella Train Ride\n'
        '• 🦁 Yala National Park Safari\n'
        '• 🛕 Temple of the Tooth, Kandy\n\n'
        'Would you like more details on any of these?';
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

    final response = await _mockResponse(text.trim());

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
                    Icon(Icons.auto_awesome, size: 12, color: AppTheme.gold),
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
            SelectableText(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: message.isUser ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
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
              child: Text(
                s['label']!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
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