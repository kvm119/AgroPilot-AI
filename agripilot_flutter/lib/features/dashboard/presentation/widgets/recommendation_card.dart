import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_models.dart';
import 'skeleton_loader.dart';

final acceptedRecommendationIdsProvider = StateProvider<Set<String>>((ref) => {});
final ignoredRecommendationIdsProvider = StateProvider<Set<String>>((ref) => {});

class RecommendationCard extends ConsumerWidget {
  final AsyncValue<List<Recommendation>> recommendationsState;

  const RecommendationCard({super.key, required this.recommendationsState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final acceptedIds = ref.watch(acceptedRecommendationIdsProvider);
    final ignoredIds = ref.watch(ignoredRecommendationIdsProvider);

    return CardStateWrapper<List<Recommendation>>(
      state: recommendationsState,
      cardTitle: 'AI Recommendations',
      loadingBuilder: _buildLoading(),
      dataBuilder: (recommendations) {
        // Recommendation Memory Pipeline Filtering
        final visible = recommendations.where((r) => !acceptedIds.contains(r.id)).toList();

        // Sort: Non-ignored first, ignored at bottom
        visible.sort((a, b) {
          final aIgnored = ignoredIds.contains(a.id);
          final bIgnored = ignoredIds.contains(b.id);
          if (aIgnored && !bIgnored) return 1;
          if (!aIgnored && bIgnored) return -1;
          return 0;
        });

        if (visible.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'All recommendations completed for today! Great job.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Agronomic Intelligence',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...visible.map((rec) => _buildRecommendationItem(context, ref, rec, theme, ignoredIds.contains(rec.id))),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationItem(BuildContext context, WidgetRef ref, Recommendation rec, ThemeData theme, bool isIgnored) {
    final isHighPriority = rec.priority == 'high';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isIgnored
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : isHighPriority
                ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
                : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rec.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isIgnored ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (isHighPriority && !isIgnored)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'URGENT',
                    style: TextStyle(color: theme.colorScheme.onError, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(rec.reason, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.suggestedAction,
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Action Buttons: Accept / Ignore Memory Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  final currentIgnored = ref.read(ignoredRecommendationIdsProvider);
                  ref.read(ignoredRecommendationIdsProvider.notifier).state = {...currentIgnored, rec.id};
                },
                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                label: const Text('Ignore', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  final currentAccepted = ref.read(acceptedRecommendationIdsProvider);
                  ref.read(acceptedRecommendationIdsProvider.notifier).state = {...currentAccepted, rec.id};
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Accepted: ${rec.title}')),
                  );
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Accept & Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 180, height: 24),
        const SizedBox(height: 16),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const SkeletonLoader(width: double.infinity, height: double.infinity),
        ),
      ],
    );
  }
}
