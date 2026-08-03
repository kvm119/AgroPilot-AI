import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppColors>()!;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriPilot AI Prototype'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = 
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Material Design 3 Tokens',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Verify that all semantic tokens adapt properly to dark mode. This satisfies AGRI-101.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _TokenRow('Primary', theme.colorScheme.primary, theme.colorScheme.onPrimary),
                    const SizedBox(height: 12),
                    _TokenRow('Error (Destructive)', theme.colorScheme.error, theme.colorScheme.onError),
                    const SizedBox(height: 12),
                    _TokenRow('Success', customColors.success, customColors.onSuccess),
                    const SizedBox(height: 12),
                    _TokenRow('Warning', customColors.warning, customColors.onWarning),
                    const SizedBox(height: 12),
                    _TokenRow('Info', customColors.info, customColors.onInfo),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.mic),
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  final String name;
  final Color bg;
  final Color fg;
  
  const _TokenRow(this.name, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
          Icon(Icons.check_circle, color: fg, size: 20),
        ],
      ),
    );
  }
}
