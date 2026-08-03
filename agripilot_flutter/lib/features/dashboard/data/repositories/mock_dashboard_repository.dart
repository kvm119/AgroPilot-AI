import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/models/dashboard_models.dart';

/// Mock implementation of the Dashboard Repository.
/// Simulates network latency and returns dummy data for UI testing.
class MockDashboardRepository implements DashboardRepository {
  @override
  Future<Weather> getWeather() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return const Weather(
      temperature: 28.5,
      humidity: 65.0,
      windSpeed: 12.0,
      rainProbability: 20,
      condition: 'Partly Cloudy',
      locationName: 'Vijayawada, AP',
    );
  }

  @override
  Future<List<Recommendation>> getRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    return [
      const Recommendation(
        id: 'rec_1',
        title: 'Apply NPK Fertilizer',
        reason: 'Soil moisture is optimal and rain probability is low for next 48 hrs.',
        suggestedAction: 'Apply 50kg/acre of 19:19:19',
        confidenceScore: 0.92,
        priority: 'high',
      ),
      const Recommendation(
        id: 'rec_2',
        title: 'Fungicide Spray',
        reason: 'High humidity increases risk of blast disease in rice.',
        suggestedAction: 'Prophylactic spray of Tricyclazole',
        confidenceScore: 0.78,
        priority: 'medium',
      ),
    ];
  }

  @override
  Future<List<MarketItem>> getMarketPrices() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return [
      const MarketItem(
        cropName: 'Paddy (Common)',
        currentPrice: 2183.0,
        yesterdayPrice: 2150.0,
        trend: 'up',
      ),
      const MarketItem(
        cropName: 'Cotton',
        currentPrice: 7020.0,
        yesterdayPrice: 7100.0,
        trend: 'down',
      ),
      const MarketItem(
        cropName: 'Red Chilli',
        currentPrice: 18500.0,
        yesterdayPrice: 18500.0,
        trend: 'stable',
      ),
    ];
  }

  @override
  Future<NotificationSummary> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return NotificationSummary(
      unreadCount: 3,
      latestMessage: 'Heavy rainfall expected in Guntur district tomorrow.',
      severity: 'warning',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    );
  }
}
