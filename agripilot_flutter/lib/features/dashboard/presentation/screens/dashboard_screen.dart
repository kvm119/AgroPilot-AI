import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/weather_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/market_price_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/notification_summary_card.dart';
import '../widgets/dashboard_bottom_nav.dart';
import 'profile_screen.dart';
import '../../../market/presentation/screens/market_analysis_screen.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../../community/presentation/screens/community_screen.dart';
import '../../../copilot/presentation/widgets/global_copilot_fab.dart';
import '../../../onboarding/presentation/widgets/farm_location_selector.dart';

final activeDashboardTabProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

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
    final activeTab = ref.watch(activeDashboardTabProvider);
    final farmLocation = ref.watch(farmLocationProvider);

    final weatherState = ref.watch(weatherProvider);
    final recommendationsState = ref.watch(recommendationsProvider);
    final marketState = ref.watch(marketPricesProvider);
    final notificationState = ref.watch(notificationsProvider);

    // 5-Tab Navigation Mapping: 0 = Home, 1 = Market, 2 = Products, 3 = Community, 4 = Profile
    Widget bodyContent;
    switch (activeTab) {
      case 1:
        bodyContent = const MarketAnalysisScreen();
        break;
      case 2:
        bodyContent = const ProductsScreen();
        break;
      case 3:
        bodyContent = const CommunityScreen();
        break;
      case 4:
        bodyContent = const ProfileScreen();
        break;
      case 0:
      default:
        bodyContent = RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(weatherProvider);
            ref.invalidate(recommendationsProvider);
            ref.invalidate(marketPricesProvider);
            ref.invalidate(notificationsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Banner Bar
                    InkWell(
                      onTap: () => _openLocationSelector(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${farmLocation.village}, ${farmLocation.district} (${farmLocation.country})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const Text('Change Location', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                            const Icon(Icons.chevron_right, size: 18, color: Colors.green),
                          ],
                        ),
                      ),
                    ),

                    NotificationSummaryCard(notificationState: notificationState),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: WeatherCard(weatherState: weatherState),
                    ),
                    const SizedBox(height: 20),
                    const QuickActionsCard(),
                    const SizedBox(height: 20),

                    // Government Schemes Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.account_balance_rounded, color: Colors.white),
                          ),
                          title: const Text('Government Schemes & Subsidies', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Check PM-KISAN, Fasal Bima, and AP Drip subsidies'),
                          trailing: ElevatedButton(
                            onPressed: () => context.push('/schemes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('View All'),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: RecommendationCard(recommendationsState: recommendationsState)),
                                const SizedBox(width: 16),
                                Expanded(child: MarketPriceCard(marketState: marketState)),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                RecommendationCard(recommendationsState: recommendationsState),
                                const SizedBox(height: 16),
                                MarketPriceCard(marketState: marketState),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
    }

    return Scaffold(
      appBar: activeTab == 0
          ? AppBar(
              title: const Row(
                children: [
                  Icon(Icons.agriculture_rounded, color: Colors.green),
                  SizedBox(width: 8),
                  Text('AgriPilot AI'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () {
                    ref.read(activeDashboardTabProvider.notifier).state = 4;
                  },
                ),
              ],
            )
          : null,
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: activeTab,
        onDestinationSelected: (index) {
          ref.read(activeDashboardTabProvider.notifier).state = index;
        },
      ),
      floatingActionButton: const GlobalCopilotFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
