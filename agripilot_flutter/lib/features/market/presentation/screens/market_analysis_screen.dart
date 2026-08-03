import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/market_providers.dart';
import '../../domain/models/market_analysis_models.dart';

class MarketAnalysisScreen extends ConsumerStatefulWidget {
  const MarketAnalysisScreen({super.key});

  @override
  ConsumerState<MarketAnalysisScreen> createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends ConsumerState<MarketAnalysisScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _chartTimeframe = '1W'; // 1D, 1W, 1M, 1Y

  static const List<String> _categories = [
    'All',
    'Fruits',
    'Vegetables',
    'Cereals',
    'Pulses',
    'Oil Seeds',
    'Spices',
    'Commercial'
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        ref.read(marketSearchQueryProvider.notifier).state = val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final marketDataAsync = ref.watch(marketAnalysisProvider);
    final favorites = ref.watch(favoriteCommodityIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.show_chart_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Indian Market Intelligence'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(marketAnalysisProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Persistent Search Bar (With 350ms Debouncer)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search Rice, Tomato, Onion, Guntur Mandi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Persistent Category Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    onSelected: (selected) {
                      ref.read(selectedCategoryProvider.notifier).state = cat;
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Async Commodity List Area Only
          Expanded(
            child: marketDataAsync.when(
              data: (data) {
                final commodities = data.commodities;
                if (commodities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 12),
                        Text('No matching commodities found', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Try searching for another crop or clear your filter.', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: commodities.length,
                  itemBuilder: (context, index) {
                    final item = commodities[index];
                    final isFav = favorites.contains(item.id);
                    return _buildCommodityCard(context, item, isFav);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Failed to load Market Analysis: $err'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(marketAnalysisProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityCard(BuildContext context, CommodityDetail item, bool isFav) {
    final theme = Theme.of(context);
    final isUp = item.percentageChange >= 0;
    final changeColor = isUp ? Colors.green : Colors.red;
    final changeIcon = isUp ? Icons.trending_up : Icons.trending_down;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        key: PageStorageKey(item.id),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isUp
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.15),
          child: Icon(changeIcon, color: changeColor),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.cropName,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav ? Colors.amber : theme.colorScheme.outline,
              ),
              onPressed: () {
                final current = ref.read(favoriteCommodityIdsProvider);
                final updated = Set<String>.from(current);
                if (updated.contains(item.id)) {
                  updated.remove(item.id);
                } else {
                  updated.add(item.id);
                }
                ref.read(favoriteCommodityIdsProvider.notifier).state = updated;
              },
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.marketName}, ${item.district} (${item.state})', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '₹${item.currentPrice.toStringAsFixed(0)} / Qtl',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(changeIcon, size: 14, color: changeColor),
                      const SizedBox(width: 2),
                      Text(
                        '${isUp ? '+' : ''}${item.percentageChange.toStringAsFixed(2)}%',
                        style: TextStyle(color: changeColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                // Timeframe Selector & Chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Price Trend Graph', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: ['1D', '1W', '1M', '1Y'].map((tf) {
                        final isSel = _chartTimeframe == tf;
                        return Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _chartTimeframe = tf;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSel ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tf,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSel ? Colors.white : theme.colorScheme.onSurface,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Chart Widget
                SizedBox(
                  height: 180,
                  child: _buildPriceChart(context, item, _chartTimeframe),
                ),

                const SizedBox(height: 16),
                const Divider(),

                // Detailed Metrics Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildMetricChip(context, 'Yesterday', '₹${item.yesterdayPrice.toStringAsFixed(0)}'),
                    _buildMetricChip(context, '7D Moving Avg', '₹${item.movingAvg7d.toStringAsFixed(0)}'),
                    _buildMetricChip(context, '30D Moving Avg', '₹${item.movingAvg30d.toStringAsFixed(0)}'),
                    _buildMetricChip(context, 'Market Arrival', '${item.arrivalQtyTons.toStringAsFixed(0)} Tons'),
                    _buildMetricChip(context, 'Demand / Supply', '${item.demandLevel} / ${item.supplyLevel}'),
                    _buildMetricChip(context, 'Price Trend', item.priceTrend, color: isUp ? Colors.green : Colors.red),
                  ],
                ),

                const SizedBox(height: 16),

                // Nearby Mandis Comparison
                if (item.nearbyMarkets.isNotEmpty) ...[
                  Text('Nearby Mandi Comparison', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Column(
                    children: item.nearbyMarkets.map((m) {
                      final diff = m.price - item.currentPrice;
                      final isHigher = diff > 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${m.marketName} (${m.distanceKm.toStringAsFixed(0)} km)'),
                            Text(
                              '₹${m.price.toStringAsFixed(0)} (${isHigher ? '+' : ''}${diff.toStringAsFixed(0)})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isHigher ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // AI Recommendation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.smart_toy_rounded, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'AI Actionable Strategy',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.recommendedAction,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.aiRecommendation,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChart(BuildContext context, CommodityDetail item, String tf) {
    List<PricePoint> points;
    switch (tf) {
      case '1D':
        points = item.dailyHistory;
        break;
      case '1M':
        points = item.monthlyHistory;
        break;
      case '1Y':
        points = item.yearlyHistory;
        break;
      case '1W':
      default:
        points = item.weeklyHistory;
        break;
    }

    if (points.isEmpty) {
      return const Center(child: Text('No historical graph data'));
    }

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();

    final minY = points.map((p) => p.price).reduce((a, b) => a < b ? a : b) * 0.98;
    final maxY = points.map((p) => p.price).reduce((a, b) => a > b ? a : b) * 1.02;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < points.length) {
                  return Text(points[idx].label, style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, String label, String value, {Color? color}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
