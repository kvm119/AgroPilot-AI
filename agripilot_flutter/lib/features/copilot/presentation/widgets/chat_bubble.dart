import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/copilot_models.dart';
import '../providers/copilot_providers.dart';

class ChatBubble extends ConsumerWidget {
  final MessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    final isTtsActive = ref.watch(ttsProvider);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? theme.colorScheme.primaryContainer 
              : message.isError 
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser ? null : Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isPending)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text('Analyzing farm data...', style: theme.textTheme.bodyMedium),
                ],
              )
            else if (isUser)
              Text(
                message.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyLarge?.copyWith(color: message.isError ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!message.isError)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isTtsActive ? Icons.stop_circle : Icons.volume_up, 
                                size: 20, 
                                color: theme.colorScheme.primary
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                if (isTtsActive) {
                                  ref.read(ttsProvider.notifier).stop();
                                } else {
                                  ref.read(ttsProvider.notifier).speak(message.text);
                                }
                              },
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.copy, size: 18, color: theme.colorScheme.onSurfaceVariant),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: message.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied to clipboard')),
                                );
                              },
                            ),
                          ],
                        ),
                        if (message.confidence != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: theme.colorScheme.onSecondaryContainer),
                                const SizedBox(width: 4),
                                Text(
                                  '${(message.confidence! * 100).toInt()}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
