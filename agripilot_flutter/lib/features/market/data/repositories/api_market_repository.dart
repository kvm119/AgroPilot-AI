import '../../../../core/network/api_client.dart';
import '../../domain/models/market_analysis_models.dart';

class ApiMarketRepository {
  final ApiClient client;

  ApiMarketRepository(this.client);

  Future<MarketAnalysisData> getMarketAnalysis({
    String? category,
    String? state,
    String? search,
  }) async {
    final queryParams = <String>[];
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams.add('category=${Uri.encodeComponent(category)}');
    }
    if (state != null && state.isNotEmpty && state != 'All') {
      queryParams.add('state=${Uri.encodeComponent(state)}');
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search.trim())}');
    }

    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final response = await client.get('/market/analysis$queryString');
    
    return MarketAnalysisData.fromJson(response as Map<String, dynamic>);
  }
}
