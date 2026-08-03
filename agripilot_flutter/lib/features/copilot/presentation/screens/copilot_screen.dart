import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/copilot_providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/voice_input_area.dart';
import '../widgets/suggested_questions.dart';
import '../widgets/copilot_history_drawer.dart';

class CopilotScreen extends ConsumerStatefulWidget {
  const CopilotScreen({super.key});

  @override
  ConsumerState<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends ConsumerState<CopilotScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(currentSessionMessagesProvider);
    final isOffline = ref.watch(isOfflineProvider);
    final theme = Theme.of(context);

    ref.listen(currentSessionMessagesProvider, (_, _) => _scrollToBottom());

    List<String> currentSuggestions = [];
    if (messages.isNotEmpty) {
      currentSuggestions = [
        'What fertilizer for Rice?',
        'When should I irrigate?',
        'Show Indian market prices',
        'Eligible government schemes'
      ];
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CopilotHistoryDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text('AgriPilot AI Copilot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'New Chat',
            onPressed: () {
              final newId = ref.read(chatSessionsProvider.notifier).createNewSession();
              ref.read(activeSessionIdProvider.notifier).state = newId;
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isOffline)
            Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No Internet Connection - Offline Mode',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: messages[index]);
              },
            ),
          ),
          if (!isOffline && currentSuggestions.isNotEmpty)
            SuggestedQuestions(questions: currentSuggestions),
          const VoiceInputArea(),
        ],
      ),
    );
  }
}
