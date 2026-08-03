import '../../domain/models/dashboard_models.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/network/api_client.dart';

class ApiDashboardRepository implements DashboardRepository {
  final ApiClient _client;

  ApiDashboardRepository(this._client);

  @override
  Future<Weather> getWeather() async {
    final response = await _client.get('/weather');
    return Weather.fromJson(response);
  }

  @override
  Future<List<Recommendation>> getRecommendations() async {
    final response = await _client.get('/recommendations');
    final items = response['recommendations'] as List<dynamic>;
    return items.map((e) => Recommendation.fromJson(e)).toList();
  }

  @override
  Future<List<MarketItem>> getMarketPrices() async {
    final response = await _client.get('/market');
    final items = response['items'] as List<dynamic>;
    return items.map((e) => MarketItem.fromJson(e)).toList();
  }

  @override
  Future<NotificationSummary> getNotifications() async {
    final response = await _client.get('/notifications');
    return NotificationSummary.fromJson(response);
  }
}
