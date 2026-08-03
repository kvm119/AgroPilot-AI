import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/farm_setup_provider.dart';

class FarmSetup1 extends ConsumerStatefulWidget {
  const FarmSetup1({super.key});

  @override
  ConsumerState<FarmSetup1> createState() => _FarmSetup1State();
}

class _FarmSetup1State extends ConsumerState<FarmSetup1> {
  bool _isLoading = false;
  bool _locationFound = false;

  void _detectLocation() async {
    setState(() => _isLoading = true);
    
    // Simulate location detection
    await Future.delayed(const Duration(seconds: 2));
    
    ref.read(farmSetupProvider.notifier).setLocation(16.5, 80.6); // Vijayawada coords

    setState(() {
      _isLoading = false;
      _locationFound = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                'Where is your farm?',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'We use your location to provide accurate weather forecasts and market prices.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)
                ),
              ),
              const SizedBox(height: 32),
              
              if (!_locationFound)
                ElevatedButton.icon(
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
                  label: Text(_isLoading ? 'Detecting...' : 'Use Current Location'),
                  onPressed: _isLoading ? null : _detectLocation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location Detected', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Krishna District, Andhra Pradesh'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
              const Spacer(),
              ElevatedButton(
                onPressed: _locationFound ? () => context.push('/setup/2') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
