import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_models.dart';
import '../../../onboarding/presentation/widgets/farm_location_selector.dart';
import 'skeleton_loader.dart';

class WeatherCard extends ConsumerWidget {
  final AsyncValue<Weather> weatherState;

  const WeatherCard({super.key, required this.weatherState});

  void _openLocationSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FarmLocationSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final location = ref.watch(farmLocationProvider);

    // If farm location coordinates are unselected / zero
    if (location.latitude == 0 && location.longitude == 0) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.location_off_rounded, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              Text(
                'Farm Location Required',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set your farm location to unlock hyper-local weather forecasting and agronomic advice.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openLocationSelector(context),
                icon: const Icon(Icons.pin_drop_rounded),
                label: const Text('Set Farm Location', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CardStateWrapper<Weather>(
      state: weatherState,
      cardTitle: 'Weather Forecast',
      loadingBuilder: _buildLoading(),
      dataBuilder: (weather) {
        final now = DateTime.now();
        final formattedTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${location.village}, ${location.district}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text('Updated $formattedTime', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(weather.condition, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.water_drop, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 2),
                              Text('${weather.rainProbability}% Rain', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.air, size: 14, color: theme.colorScheme.secondary),
                              const SizedBox(width: 2),
                              Text('${weather.windSpeed} km/h', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              const Text('UV 4 (Moderate)', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoader(width: 120, height: 20),
        SizedBox(height: 16),
        Row(
          children: [
            SkeletonLoader(width: 80, height: 50),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 100, height: 20),
                SizedBox(height: 8),
                SkeletonLoader(width: 150, height: 16),
              ],
            )
          ],
        )
      ],
    );
  }
}
