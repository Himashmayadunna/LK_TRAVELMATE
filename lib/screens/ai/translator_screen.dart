import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_theme.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = '';
  bool _isLoading = false;
  bool _isRecording = false;
  String _fromLang = 'English';
  String _toLang = 'Sinhala';
  int _charCount = 0;

  static const int _maxChars = 500;

  static const List<String> _languages = [
    'English',
    'Sinhala',
    'Tamil',
  ];

  static const List<Map<String, String>> _quickPhrases = [
    {'label': 'How much is this?', 'text': 'How much is this?'},
    {'label': 'Where is the beach?', 'text': 'Where is the beach?'},
    {'label': 'Thank you', 'text': 'Thank you'},
    {'label': 'Help me please', 'text': 'Help me please'},
    {'label': 'Where is the hotel?', 'text': 'Where is the hotel?'},
    {'label': 'I need a taxi', 'text': 'I need a taxi'},
  ];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      setState(() {
        _charCount = _inputController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _fromLang;
      _fromLang = _toLang;
      _toLang = temp;
      // Also swap text content if there's a translation
      if (_translatedText.isNotEmpty) {
        final tempText = _inputController.text;
        _inputController.text = _translatedText;
        _translatedText = tempText;
        _charCount = _inputController.text.length;
      }
    });
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    // TODO:  replaces this mock with the real API call
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _translatedText = '[ Translation of "$text" from $_fromLang to $_toLang ]';
      _isLoading = false;
    });
  }

  void _copyToClipboard() {
    if (_translatedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  Future<void> _startVoiceRecording() async {
  setState(() => _isRecording = true);
  // TODO: teammate — start microphone recording here
}

  Future<void> _stopAndTranslate() async {
  setState(() => _isRecording = false);
  // TODO: teammate — stop recording, get transcript text,
  // set _inputController.text = transcript, then call _translate()
}

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _translatedText = '';
      _charCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: const Border(
              bottom: BorderSide(color: AppTheme.divider, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:  BoxDecoration(
                 color: _isRecording ? AppTheme.error : AppTheme.success,
                 shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isRecording ? 'Listening...' : 'AI Translator ready',
                  style: TextStyle(
                  fontSize: 12,
                  color: _isRecording ? AppTheme.error : AppTheme.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language selector row
                _buildLanguageSelector(),
                const SizedBox(height: 14),

                // Input box
                if (_isRecording) _buildRecordingBanner(),
                _buildInputBox(),
                const SizedBox(height: 12),

                // Output box
                _buildOutputBox(),
                const SizedBox(height: 20),

                // Quick phrases
                _buildQuickPhrases(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecordingBanner() {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppTheme.primarySurface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      border: Border.all(color: AppTheme.primarySoft, width: 1),
    ),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppTheme.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Listening... tap Stop when done',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryDark,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      child: Row(
        children: [
          Expanded(child: _buildLangDropdown(_fromLang, true)),
          GestureDetector(
            onTap: _swapLanguages,
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primarySoft, width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.swap_horiz_rounded,
                  size: 20,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          Expanded(child: _buildLangDropdown(_toLang, false)),
        ],
      ),
    );
  }

  Widget _buildLangDropdown(String value, bool isFrom) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
        dropdownColor: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        items: _languages
            .where((l) => isFrom ? l != _toLang : l != _fromLang)
            .map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                ))
            .toList(),
        onChanged: (val) {
          if (val == null) return;
          setState(() {
            if (isFrom) {
              _fromLang = val;
            } else {
              _toLang = val;
            }
            _translatedText = '';
          });
        },
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: _isRecording ? AppTheme.primary : AppTheme.divider,
          width: _isRecording ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fromLang.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '$_charCount / $_maxChars',
                  style: TextStyle(
                    fontSize: 11,
                    color: _charCount > _maxChars
                        ? AppTheme.error
                        : AppTheme.textHint,
                  ),
                ),
              ],
            ),
          ),

          // Text field
          TextField(
            controller: _inputController,
            maxLines: 5,
            minLines: 4,
            maxLength: _maxChars,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                null, // hide default counter
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
            decoration:  InputDecoration(
              hintText: _isRecording ? 'Speak now...' : 'Enter text or use mic to speak...',
              hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 15),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(14, 10, 14, 10),
            ),
          ),

          // Footer actions
          Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.divider)),
            ),
            child: Row(
              children: [
                if (_charCount > 0)
                  _buildActionChip(
                    icon: Icons.close_rounded,
                    label: 'Clear',
                    onTap: _clearAll,
                    isPrimary: false,
                  ),
                if (_charCount == 0)
                  _buildActionChip(
                    icon: _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    label: _isRecording ? 'Stop' : 'Voice',
                    onTap: _isRecording ? _stopAndTranslate : _startVoiceRecording,
                    isPrimary: _isRecording,
                  ),
                const Spacer(),
            
                _buildActionChip(
                  icon: Icons.translate_rounded,
                  label: 'Translate',
                  onTap: _charCount > 0 && !_isLoading ? _translate : null,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputBox() {
    return Container(
      decoration: BoxDecoration(
        color: _translatedText.isNotEmpty
            ? AppTheme.background
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: _translatedText.isNotEmpty
              ? AppTheme.primarySoft
              : AppTheme.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _toLang.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _translatedText.isNotEmpty
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                if (_translatedText.isNotEmpty)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _copyToClipboard,
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: _isLoading
                ? Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Translating...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                : SelectableText(
                    _translatedText.isEmpty
                        ? 'Translation will appear here...'
                        : _translatedText,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: _translatedText.isEmpty
                          ? AppTheme.textHint
                          : AppTheme.textPrimary,
                      fontStyle: _translatedText.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPhrases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common travel phrases',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickPhrases.map((phrase) {
            return GestureDetector(
              onTap: () {
                _inputController.text = phrase['text']!;
                _charCount = phrase['text']!.length;
                _translate();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  border: Border.all(color: AppTheme.primarySoft, width: 1),
                ),
                child: Text(
                  phrase['label']!,
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
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary
              ? (onTap != null ? AppTheme.primary : AppTheme.textHint)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: isPrimary
              ? null
              : Border.all(color: AppTheme.divider, width: 1),
          gradient: isPrimary && onTap != null ? AppTheme.primaryGradient : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isPrimary ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}