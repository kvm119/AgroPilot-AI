import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/api_market_repository.dart';
import '../../domain/models/market_analysis_models.dart';

final marketApiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final apiMarketRepositoryProvider = Provider<ApiMarketRepository>((ref) {
  final client = ref.watch(marketApiClientProvider);
  return ApiMarketRepository(client);
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final selectedStateFilterProvider = StateProvider<String>((ref) => 'All');
final marketSearchQueryProvider = StateProvider<String>((ref) => '');
final favoriteCommodityIdsProvider = StateProvider<Set<String>>((ref) => {});

final marketAnalysisProvider = FutureProvider.autoDispose<MarketAnalysisData>((ref) async {
  final repo = ref.watch(apiMarketRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final stateFilter = ref.watch(selectedStateFilterProvider);
  final searchQuery = ref.watch(marketSearchQueryProvider);

  return repo.getMarketAnalysis(
    category: category,
    state: stateFilter,
    search: searchQuery,
  );
});
