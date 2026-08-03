import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_models.dart';
import 'skeleton_loader.dart';

class NotificationSummaryCard extends StatelessWidget {
  final AsyncValue<NotificationSummary> notificationState;

  const NotificationSummaryCard({super.key, required this.notificationState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return notificationState.when(
      data: (data) {
        if (data.unreadCount == 0) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_active, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.unreadCount} New Alerts',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      data.latestMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onPrimaryContainer),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SkeletonLoader(width: double.infinity, height: 72, borderRadius: 16),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
