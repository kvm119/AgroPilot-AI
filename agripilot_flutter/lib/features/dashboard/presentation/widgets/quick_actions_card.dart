import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../camera/presentation/screens/in_app_camera_screen.dart';

class QuickActionsCard extends ConsumerWidget {
  const QuickActionsCard({super.key});

  void _openInAppCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const InAppCameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                context,
                Icons.camera_alt_rounded,
                'Scan Crop',
                theme.colorScheme.primaryContainer,
                theme.colorScheme.onPrimaryContainer,
                onTap: () => _openInAppCamera(context),
              ),
              _buildActionItem(
                context,
                Icons.calculate_rounded,
                'Dosage',
                theme.colorScheme.secondaryContainer,
                theme.colorScheme.onSecondaryContainer,
                onTap: () => context.push('/dosage'),
              ),
              _buildActionItem(
                context,
                Icons.history_rounded,
                'Logs',
                theme.colorScheme.tertiaryContainer,
                theme.colorScheme.onTertiaryContainer,
                onTap: () => context.push('/logs'),
              ),
              _buildActionItem(
                context,
                Icons.support_agent_rounded,
                'Expert',
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.onSurfaceVariant,
                onTap: () => context.push('/expert'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color bgColor, Color iconColor, {required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
