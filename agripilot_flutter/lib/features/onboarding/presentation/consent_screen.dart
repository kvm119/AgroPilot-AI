import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                'Data Permissions',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'AgriPilot needs the following permissions to provide accurate agronomy advice:',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              
              _PermissionTile(
                icon: Icons.location_on,
                title: 'Location',
                description: 'To provide hyper-local weather and market prices.',
                theme: theme,
              ),
              const SizedBox(height: 24),
              _PermissionTile(
                icon: Icons.camera_alt,
                title: 'Camera',
                description: 'To detect crop diseases and read pesticide labels.',
                theme: theme,
              ),
              const SizedBox(height: 24),
              _PermissionTile(
                icon: Icons.mic,
                title: 'Microphone',
                description: 'To talk to the AI Copilot via voice.',
                theme: theme,
              ),
              
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text('Allow & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ThemeData theme;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
