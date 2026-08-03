import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/locale_provider.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  final bool fromSettings;

  const LanguageScreen({super.key, this.fromSettings = false});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  late String _selectedLanguage;

  final _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = ref.read(appLocaleProvider).languageCode;
  }

  void _applyLanguage() {
    ref.read(appLocaleProvider.notifier).setLanguage(_selectedLanguage);

    if (widget.fromSettings || GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/consent');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.fromSettings
          ? AppBar(
              title: const Text('Change Language'),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.fromSettings) const SizedBox(height: 32),
              Text(
                'Choose Language',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your preferred language for AgriPilot AI',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 32),
              ..._languages.map((lang) {
                final isSelected = _selectedLanguage == lang['code'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang['code']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['name']!,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? theme.colorScheme.primary : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lang['native']!,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 28),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              ElevatedButton(
                onPressed: _applyLanguage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  widget.fromSettings ? 'Save Language' : 'Continue',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
