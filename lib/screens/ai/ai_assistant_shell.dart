import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'ai_chat_screen.dart';
import 'translator_screen.dart';

class AIAssistantShell extends StatefulWidget {
  final String? initialPrompt;
  final VoidCallback? onBack;

  const AIAssistantShell({super.key, this.initialPrompt, this.onBack});

  @override
  State<AIAssistantShell> createState() => _AIAssistantShellState();
}

class _AIAssistantShellState extends State<AIAssistantShell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'AI Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.divider, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              indicatorColor: AppTheme.primary,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🌐', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 6),
                      Text('Translator'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🤖', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 6),
                      Text('Assistant'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 0: Translator (left)
          const TranslatorScreen(),
          // Tab 1: Assistant (right)
          AIChatScreenBody(initialPrompt: widget.initialPrompt),
        ],
      ),
    );
  }
}