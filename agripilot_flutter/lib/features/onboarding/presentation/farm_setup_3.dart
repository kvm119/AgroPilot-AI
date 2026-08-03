import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/farm_setup_provider.dart';

class FarmSetup3 extends ConsumerStatefulWidget {
  const FarmSetup3({super.key});

  @override
  ConsumerState<FarmSetup3> createState() => _FarmSetup3State();
}

class _FarmSetup3State extends ConsumerState<FarmSetup3> {
  final _sizes = [
    {'value': 1.0, 'label': '0-2 Acres'},
    {'value': 3.5, 'label': '2-5 Acres'},
    {'value': 7.5, 'label': '5-10 Acres'},
    {'value': 15.0, 'label': '10+ Acres'},
  ];

  void _completeSetup() async {
    final success = await ref.read(farmSetupProvider.notifier).saveFarm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm Setup Complete! Welcome to AgriPilot AI.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(farmSetupProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Farm Size',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us calculate exact pesticide and fertilizer dosages.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)
                ),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: ListView.separated(
                  itemCount: _sizes.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final size = _sizes[index];
                    final isSelected = state.sizeAcres == size['value'];
                    
                    return InkWell(
                      onTap: () => ref.read(farmSetupProvider.notifier).setSize(size['value'] as double),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                size['label'] as String, 
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: isSelected ? theme.colorScheme.primary : null,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
                
              ElevatedButton(
                onPressed: state.sizeAcres > 0 && !state.isSaving ? _completeSetup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: state.isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Complete Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
