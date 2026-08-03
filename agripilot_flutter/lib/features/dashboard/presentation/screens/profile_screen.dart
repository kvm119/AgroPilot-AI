import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/locale_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'te':
        return 'తెలుగు (Telugu)';
      case 'en':
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final currentLocale = ref.watch(appLocaleProvider);
    final langName = _getLanguageName(currentLocale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Farmer Account',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'AgriPilot Member',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Preferred Language'),
                  subtitle: Text(langName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/language?fromSettings=true'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Dark Theme'),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state =
                          val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.landscape),
                  title: const Text('Farm Setup & Details'),
                  subtitle: const Text('Rice (BPT 5204) • 5.0 Acres'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/setup/1'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
