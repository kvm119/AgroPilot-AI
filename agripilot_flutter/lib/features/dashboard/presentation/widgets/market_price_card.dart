import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_models.dart';
import 'skeleton_loader.dart';

class MarketPriceCard extends StatelessWidget {
  final AsyncValue<List<MarketItem>> marketState;

  const MarketPriceCard({super.key, required this.marketState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardStateWrapper<List<MarketItem>>(
      state: marketState,
      cardTitle: 'Market Prices',
      loadingBuilder: _buildLoading(),
      dataBuilder: (prices) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storefront, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Local Mandi Prices',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...prices.map((item) => _buildMarketRow(item, theme)),
          ],
        );
      },
    );
  }

  Widget _buildMarketRow(MarketItem item, ThemeData theme) {
    final isUp = item.trend == 'up';
    final isDown = item.trend == 'down';
    
    IconData trendIcon = Icons.remove;
    Color trendColor = theme.colorScheme.onSurfaceVariant;
    
    if (isUp) {
      trendIcon = Icons.trending_up;
      trendColor = Colors.green;
    } else if (isDown) {
      trendIcon = Icons.trending_down;
      trendColor = theme.colorScheme.error;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.cropName, style: theme.textTheme.bodyLarge),
          Row(
            children: [
              Text(
                '₹${item.currentPrice}/q',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(trendIcon, color: trendColor, size: 18),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoader(width: 150, height: 24),
        SizedBox(height: 16),
        SkeletonLoader(width: double.infinity, height: 20),
        SizedBox(height: 12),
        SkeletonLoader(width: double.infinity, height: 20),
      ],
    );
  }
}
