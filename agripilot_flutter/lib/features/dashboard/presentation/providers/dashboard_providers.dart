import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_models.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/api_dashboard_repository.dart';
import '../../../../core/network/api_client.dart';

/// Provides the ApiClient instance
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provides the singleton instance of the repository mapped to the live API
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ApiDashboardRepository(client);
});

/// Individual providers for each card to ensure independent loading/re-fetching
final weatherProvider = FutureProvider.autoDispose<Weather>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getWeather();
});

final recommendationsProvider = FutureProvider.autoDispose<List<Recommendation>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getRecommendations();
});

final marketPricesProvider = FutureProvider.autoDispose<List<MarketItem>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getMarketPrices();
});

final notificationsProvider = FutureProvider.autoDispose<NotificationSummary>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getNotifications();
});
