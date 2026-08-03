import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/copilot_providers.dart';

class SuggestedQuestions extends ConsumerWidget {
  final List<String> questions;

  const SuggestedQuestions({super.key, required this.questions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(q),
              onPressed: () {
                final activeId = ref.read(activeSessionIdProvider);
                ref.read(chatSessionsProvider.notifier).sendMessage(activeId, q);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }
}
