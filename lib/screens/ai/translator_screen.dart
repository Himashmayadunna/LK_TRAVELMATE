import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../service/translator_api.dart';
import '../../utils/app_theme.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  static const MethodChannel _mlKitSpeechChannel = MethodChannel(
    'lk_travelmate/mlkit_speech',
  );
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _mlKitStateMonitorTimer;
  bool _speechReady = false;
  bool _isSpeaking = false;
  bool _isStoppingMlKit = false;
  bool? _isOnline;
  String _translatedText = '';
  bool _isLoading = false;
  bool _isRecording = false;
  String _fromLang = 'English';
  String _toLang = 'Sinhala';
  int _charCount = 0;

  static const int _maxChars = 500;

  static const Map<String, String> _speechLocaleMap = {
    'English': 'en_US',
    'Sinhala': 'si_LK',
    'Tamil': 'ta_LK',
    'Russian': 'ru_RU',
    'French': 'fr_FR',
    'German': 'de_DE',
    'Spanish': 'es_ES',
    'Italian': 'it_IT',
    'Portuguese': 'pt_PT',
    'Dutch': 'nl_NL',
    'Arabic': 'ar_SA',
    'Hindi': 'hi_IN',
    'Urdu': 'ur_PK',
    'Chinese': 'zh_CN',
    'Japanese': 'ja_JP',
    'Korean': 'ko_KR',
    'Thai': 'th_TH',
    'Malay': 'ms_MY',
    'Indonesian': 'id_ID',
    'Turkish': 'tr_TR',
    'Polish': 'pl_PL',
    'Ukrainian': 'uk_UA',
    'Greek': 'el_GR',
    'Hebrew': 'he_IL',
    'Swedish': 'sv_SE',
    'Norwegian': 'nb_NO',
    'Danish': 'da_DK',
    'Finnish': 'fi_FI',
  };

  static const Map<String, String> _ttsLanguageMap = {
    'English': 'en-US',
    'Sinhala': 'si-LK',
    'Tamil': 'ta-LK',
    'Russian': 'ru-RU',
    'French': 'fr-FR',
    'German': 'de-DE',
    'Spanish': 'es-ES',
    'Italian': 'it-IT',
    'Portuguese': 'pt-PT',
    'Dutch': 'nl-NL',
    'Arabic': 'ar-SA',
    'Hindi': 'hi-IN',
    'Urdu': 'ur-PK',
    'Chinese': 'zh-CN',
    'Japanese': 'ja-JP',
    'Korean': 'ko-KR',
    'Thai': 'th-TH',
    'Malay': 'ms-MY',
    'Indonesian': 'id-ID',
    'Turkish': 'tr-TR',
    'Polish': 'pl-PL',
    'Ukrainian': 'uk-UA',
    'Greek': 'el-GR',
    'Hebrew': 'he-IL',
    'Swedish': 'sv-SE',
    'Norwegian': 'nb-NO',
    'Danish': 'da-DK',
    'Finnish': 'fi-FI',
  };

  static const List<String> _languages = [
    'English',
    'Sinhala',
    'Tamil',
    'Russian',
    'French',
    'German',
    'Spanish',
    'Italian',
    'Portuguese',
    'Dutch',
    'Arabic',
    'Hindi',
    'Urdu',
    'Chinese',
    'Japanese',
    'Korean',
    'Thai',
    'Malay',
    'Indonesian',
    'Turkish',
    'Polish',
    'Ukrainian',
    'Greek',
    'Hebrew',
    'Swedish',
    'Norwegian',
    'Danish',
    'Finnish',
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
    _mlKitSpeechChannel.setMethodCallHandler(_handleMlKitCallback);
    _initSpeech();
    _initTts();
    _initConnectivityStatus();
    _inputController.addListener(() {
      if (!mounted) return;
      setState(() {
        _charCount = _inputController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _mlKitStateMonitorTimer?.cancel();
    _mlKitSpeechChannel.setMethodCallHandler(null);
    unawaited(_mlKitSpeechChannel.invokeMethod<void>('stopListening'));
    _speechToText.stop();
    _flutterTts.stop();
    _connectivitySubscription?.cancel();
    _inputController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _initConnectivityStatus() async {
    final List<ConnectivityResult> initialResult = await _connectivity
        .checkConnectivity();
    if (!mounted) return;

    setState(() {
      _isOnline = _hasInternet(initialResult);
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (!mounted) return;
      setState(() {
        _isOnline = _hasInternet(result);
      });
    });
  }

  bool _hasInternet(List<ConnectivityResult> result) {
    return result.any((ConnectivityResult status) {
      return status != ConnectivityResult.none;
    });
  }

  bool _isIgnorableSpeechError(String message) {
    final String value = message.toLowerCase();
    return value.contains('error_no_match') ||
        value.contains('error_speech_timeout') ||
        value.contains('no match') ||
        value.contains('speech timeout');
  }

  bool _useMlKitForCurrentLanguage() {
    return Platform.isAndroid &&
        (_fromLang == 'Sinhala' || _fromLang == 'Tamil');
  }

  Future<void> _handleMlKitCallback(MethodCall call) async {
    if (!mounted || !_useMlKitForCurrentLanguage()) {
      return;
    }

    if (call.method != 'onPartialResult' && call.method != 'onFinalResult') {
      return;
    }

    final dynamic args = call.arguments;
    if (args is! Map) {
      return;
    }

    final String text = (args['text'] as String? ?? '').trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _inputController.text = text;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
    });
  }

  Future<void> _runWithRetry(
    Future<void> Function() action, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 350),
  }) async {
    Duration backoff = initialDelay;
    Object? lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await action();
        return;
      } catch (e) {
        lastError = e;
        if (attempt == maxAttempts) {
          rethrow;
        }
        await Future.delayed(backoff);
        backoff *= 2;
      }
    }

    throw lastError ?? Exception('Speech start failed.');
  }

  void _startMlKitStateMonitor() {
    _mlKitStateMonitorTimer?.cancel();
    _mlKitStateMonitorTimer = Timer.periodic(const Duration(seconds: 1), (
      _,
    ) async {
      if (!mounted || !_isRecording || !_useMlKitForCurrentLanguage()) {
        return;
      }
      if (_isStoppingMlKit) {
        return;
      }

      try {
        final bool isListening =
            await _mlKitSpeechChannel.invokeMethod<bool>('isListening') ??
            false;

        if (!isListening) {
          await _stopMlKitRecording(showNoSpeechMessage: false);
          if (!mounted) return;
          setState(() => _isRecording = false);
        }
      } catch (_) {
        // Keep monitor silent; transient platform issues should not spam UI.
      }
    });
  }

  Future<void> _initSpeech() async {
    final bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening' || status == 'done') {
          setState(() => _isRecording = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isRecording = false);

        if (_isIgnorableSpeechError(error.errorMsg)) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice input error: ${error.errorMsg}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() => _speechReady = available);
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
      }
    });
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_fromLang == _toLang) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose different source and target languages.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String translated = await TranslationService.translate(
        text,
        _fromLang,
        _toLang,
      );

      if (!mounted) return;
      setState(() {
        _translatedText = translated;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _speakTranslatedText() async {
    if (_translatedText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No translated text to speak.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String language = _ttsLanguageMap[_toLang] ?? 'en-US';
    await _flutterTts.setLanguage(language);

    if (_isSpeaking) {
      await _flutterTts.stop();
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      return;
    }

    await _flutterTts.speak(_translatedText);
  }

  Future<void> _startVoiceRecording() async {
    if (_isRecording) return;

    if (_useMlKitForCurrentLanguage()) {
      await _startMlKitRecording();
      return;
    }

    await _startSystemSpeechRecording();
  }

  Future<void> _startSystemSpeechRecording() async {
    if (_isRecording) return;

    if (!_speechReady) {
      await _initSpeech();
    }

    if (!_speechReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech service unavailable. Check mic permission and Google voice service.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String preferredLocale = _speechLocaleMap[_fromLang] ?? 'en_US';
    final List<stt.LocaleName> locales = await _speechToText.locales();
    final bool hasPreferred = locales.any((l) => l.localeId == preferredLocale);
    final String? localeId = hasPreferred ? preferredLocale : null;

    if (!hasPreferred && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_fromLang voice locale is unavailable on this device. Using default locale.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => _isRecording = true);

    await _speechToText.listen(
      localeId: localeId,
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(minutes: 1),
      onResult: (result) {
        if (!mounted) return;
        final String spokenText = result.recognizedWords.trim();
        if (spokenText.isEmpty) return;

        setState(() {
          _inputController.text = spokenText;
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: _inputController.text.length),
          );
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _isRecording = _speechToText.isListening;
    });
  }

  Future<void> _startMlKitRecording() async {
    if (_isRecording) return;

    try {
      final String localeTag = _fromLang == 'Sinhala' ? 'si-LK' : 'ta-LK';

      if (!mounted) return;
      setState(() => _isRecording = true);

      await _runWithRetry(() async {
        await _mlKitSpeechChannel.invokeMethod<void>('startListening', {
          'locale': localeTag,
          'language': _fromLang,
        });
      });

      _startMlKitStateMonitor();
    } on MissingPluginException {
      if (!mounted) return;
      setState(() => _isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ML speech bridge is unavailable. Do a full app restart (not hot reload). Using default speech service now.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _startSystemSpeechRecording();
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ML Kit speech error: ${e.message ?? e.code}'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ML Kit speech failed: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _stopAndTranslate() async {
    _mlKitStateMonitorTimer?.cancel();

    if (_useMlKitForCurrentLanguage()) {
      await _stopMlKitRecording();
    } else {
      await _speechToText.stop();
    }

    if (!mounted) return;
    setState(() => _isRecording = false);

    if (_inputController.text.trim().isNotEmpty) {
      await _translate();
    }
  }

  Future<void> _stopMlKitRecording({bool showNoSpeechMessage = true}) async {
    if (_isStoppingMlKit) return;
    _isStoppingMlKit = true;

    try {
      final String? recognizedText = await _mlKitSpeechChannel
          .invokeMethod<String>('stopListening');

      if (!mounted) return;

      final String text = (recognizedText ?? '').trim();
      if (text.isEmpty) {
        if (showNoSpeechMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No speech captured. Please try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      setState(() {
        _inputController.text = text;
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputController.text.length),
        );
      });
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ML speech bridge is unavailable. Do a full app restart (not hot reload).',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ML Kit speech error: ${e.message ?? e.code}'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ML Kit speech failed: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _isStoppingMlKit = false;
    }
  }

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _translatedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _isRecording
        ? AppTheme.error
        : (_isOnline == false ? Colors.orange : AppTheme.success);
    final String statusText = _isRecording
        ? 'Listening...'
        : (_isOnline == false
              ? 'Offline mode (translation may fail)'
              : 'AI Translator ready');

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
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
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
          Expanded(child: _buildLangPickerButton(_fromLang, true)),
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
          Expanded(child: _buildLangPickerButton(_toLang, false)),
        ],
      ),
    );
  }

  Widget _buildLangPickerButton(String value, bool isFrom) {
    return GestureDetector(
      onTap: () async {
        final String? selected = await _showLanguagePicker(
          current: value,
          blocked: isFrom ? _toLang : _fromLang,
          title: isFrom ? 'Select source language' : 'Select target language',
        );

        if (!mounted || selected == null) return;

        setState(() {
          if (isFrom) {
            _fromLang = selected;
          } else {
            _toLang = selected;
          }
          _translatedText = '';
        });
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showLanguagePicker({
    required String current,
    required String blocked,
    required String title,
  }) async {
    _searchController.clear();

    final String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final List<String> filtered = _languages
                .where((lang) => lang != blocked)
                .where(
                  (lang) =>
                      searchQuery.isEmpty ||
                      lang.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 14,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setModalState(() {
                          searchQuery = value.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search language...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: AppTheme.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          borderSide: const BorderSide(color: AppTheme.primary),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No languages found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: AppTheme.divider,
                              ),
                              itemBuilder: (context, index) {
                                final String language = filtered[index];
                                final bool isCurrent = language == current;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  title: Text(
                                    language,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isCurrent
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  trailing: isCurrent
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: AppTheme.primary,
                                          size: 18,
                                        )
                                      : null,
                                  onTap: () =>
                                      Navigator.of(context).pop(language),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return result;
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
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    null, // hide default counter
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _isRecording
                  ? 'Speak now...'
                  : 'Enter text or use mic to speak...',
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
                    onTap: _isRecording
                        ? _stopAndTranslate
                        : _startVoiceRecording,
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
          if (_translatedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  _buildActionChip(
                    icon: _isSpeaking
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_rounded,
                    label: _isSpeaking ? 'Stop' : 'Speak',
                    onTap: _speakTranslatedText,
                    isPrimary: true,
                  ),
                ],
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
          gradient: isPrimary && onTap != null
              ? AppTheme.primaryGradient
              : null,
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
