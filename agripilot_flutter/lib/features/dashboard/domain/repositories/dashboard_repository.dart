import '../models/dashboard_models.dart';

/// Interface for the Dashboard Data source.
/// This ensures components are strictly isolated from implementation details.
abstract class DashboardRepository {
  Future<Weather> getWeather();
  Future<List<Recommendation>> getRecommendations();
  Future<List<MarketItem>> getMarketPrices();
  Future<NotificationSummary> getNotifications();
}
