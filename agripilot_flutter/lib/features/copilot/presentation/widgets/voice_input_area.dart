import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/copilot_providers.dart';

class VoiceInputArea extends ConsumerStatefulWidget {
  const VoiceInputArea({super.key});

  @override
  ConsumerState<VoiceInputArea> createState() => _VoiceInputAreaState();
}

class _VoiceInputAreaState extends ConsumerState<VoiceInputArea> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final activeId = ref.read(activeSessionIdProvider);
      ref.read(chatSessionsProvider.notifier).sendMessage(activeId, text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isListening = ref.watch(voiceInputProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !isOffline,
                decoration: InputDecoration(
                  hintText: isOffline ? 'Offline - Waiting for connection...' : isListening ? 'Listening...' : 'Ask AgriPilot...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isOffline
                  ? null
                  : () {
                      ref.read(voiceInputProvider.notifier).toggleListening((recognizedText) {
                        _controller.text = recognizedText;
                      });
                    },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: isListening ? Colors.red : theme.colorScheme.primary,
                child: Icon(
                  isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
              onPressed: isOffline ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
