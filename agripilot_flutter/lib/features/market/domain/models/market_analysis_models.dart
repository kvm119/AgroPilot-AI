class PricePoint {
  final String label;
  final double price;

  const PricePoint({
    required this.label,
    required this.price,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      label: json['label'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
    );
  }
}

class NearbyMarketComparison {
  final String marketName;
  final String district;
  final double price;
  final double distanceKm;

  const NearbyMarketComparison({
    required this.marketName,
    required this.district,
    required this.price,
    required this.distanceKm,
  });

  factory NearbyMarketComparison.fromJson(Map<String, dynamic> json) {
    return NearbyMarketComparison(
      marketName: json['market_name'] as String? ?? 'Mandi',
      district: json['district'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      distanceKm: (json['distance_km'] as num? ?? 0.0).toDouble(),
    );
  }
}

class CommodityDetail {
  final String id;
  final String category;
  final String cropName;
  final String state;
  final String district;
  final String marketName;
  final double currentPrice;
  final double yesterdayPrice;
  final double weeklyAvg;
  final double monthlyAvg;
  final double yearlyAvg;
  final double priceDifference;
  final double percentageChange;
  final double arrivalQtyTons;
  final String demandLevel;
  final String supplyLevel;
  final String recommendedAction;
  final double confidenceScore;
  final double movingAvg7d;
  final double movingAvg30d;
  final String priceTrend;
  final String expectedTrend;
  final String aiRecommendation;
  final bool isFavorite;
  final DateTime lastUpdated;
  final List<PricePoint> dailyHistory;
  final List<PricePoint> weeklyHistory;
  final List<PricePoint> monthlyHistory;
  final List<PricePoint> yearlyHistory;
  final List<NearbyMarketComparison> nearbyMarkets;

  const CommodityDetail({
    required this.id,
    required this.category,
    required this.cropName,
    required this.state,
    required this.district,
    required this.marketName,
    required this.currentPrice,
    required this.yesterdayPrice,
    required this.weeklyAvg,
    required this.monthlyAvg,
    required this.yearlyAvg,
    required this.priceDifference,
    required this.percentageChange,
    required this.arrivalQtyTons,
    required this.demandLevel,
    required this.supplyLevel,
    required this.recommendedAction,
    required this.confidenceScore,
    required this.movingAvg7d,
    required this.movingAvg30d,
    required this.priceTrend,
    required this.expectedTrend,
    required this.aiRecommendation,
    required this.isFavorite,
    required this.lastUpdated,
    required this.dailyHistory,
    required this.weeklyHistory,
    required this.monthlyHistory,
    required this.yearlyHistory,
    required this.nearbyMarkets,
  });

  factory CommodityDetail.fromJson(Map<String, dynamic> json) {
    return CommodityDetail(
      id: json['id'] as String? ?? 'commodity_item',
      category: json['category'] as String? ?? 'Cereals',
      cropName: json['crop_name'] as String? ?? 'Crop',
      state: json['state'] as String? ?? 'Andhra Pradesh',
      district: json['district'] as String? ?? 'Guntur',
      marketName: json['market_name'] as String? ?? 'Mandi',
      currentPrice: (json['current_price'] as num? ?? 0.0).toDouble(),
      yesterdayPrice: (json['yesterday_price'] as num? ?? 0.0).toDouble(),
      weeklyAvg: (json['weekly_avg'] as num? ?? 0.0).toDouble(),
      monthlyAvg: (json['monthly_avg'] as num? ?? 0.0).toDouble(),
      yearlyAvg: (json['yearly_avg'] as num? ?? 0.0).toDouble(),
      priceDifference: (json['price_difference'] as num? ?? 0.0).toDouble(),
      percentageChange: (json['percentage_change'] as num? ?? 0.0).toDouble(),
      arrivalQtyTons: (json['arrival_qty_tons'] as num? ?? 0.0).toDouble(),
      demandLevel: json['demand_level'] as String? ?? 'High',
      supplyLevel: json['supply_level'] as String? ?? 'Moderate',
      recommendedAction: json['recommended_action'] as String? ?? 'Hold',
      confidenceScore: (json['confidence_score'] as num? ?? 0.85).toDouble(),
      movingAvg7d: (json['moving_avg_7d'] as num? ?? 0.0).toDouble(),
      movingAvg30d: (json['moving_avg_30d'] as num? ?? 0.0).toDouble(),
      priceTrend: json['price_trend'] as String? ?? 'Bullish',
      expectedTrend: json['expected_trend'] as String? ?? 'Stable',
      aiRecommendation: json['ai_recommendation'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
      lastUpdated: DateTime.tryParse(json['last_updated'] as String? ?? '') ?? DateTime.now(),
      dailyHistory: (json['daily_history'] as List<dynamic>? ?? [])
          .map((x) => PricePoint.fromJson(x as Map<String, dynamic>))
          .toList(),
      weeklyHistory: (json['weekly_history'] as List<dynamic>? ?? [])
          .map((x) => PricePoint.fromJson(x as Map<String, dynamic>))
          .toList(),
      monthlyHistory: (json['monthly_history'] as List<dynamic>? ?? [])
          .map((x) => PricePoint.fromJson(x as Map<String, dynamic>))
          .toList(),
      yearlyHistory: (json['yearly_history'] as List<dynamic>? ?? [])
          .map((x) => PricePoint.fromJson(x as Map<String, dynamic>))
          .toList(),
      nearbyMarkets: (json['nearby_markets'] as List<dynamic>? ?? [])
          .map((x) => NearbyMarketComparison.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }

  CommodityDetail copyWith({bool? isFavorite}) {
    return CommodityDetail(
      id: id,
      category: category,
      cropName: cropName,
      state: state,
      district: district,
      marketName: marketName,
      currentPrice: currentPrice,
      yesterdayPrice: yesterdayPrice,
      weeklyAvg: weeklyAvg,
      monthlyAvg: monthlyAvg,
      yearlyAvg: yearlyAvg,
      priceDifference: priceDifference,
      percentageChange: percentageChange,
      arrivalQtyTons: arrivalQtyTons,
      demandLevel: demandLevel,
      supplyLevel: supplyLevel,
      recommendedAction: recommendedAction,
      confidenceScore: confidenceScore,
      movingAvg7d: movingAvg7d,
      movingAvg30d: movingAvg30d,
      priceTrend: priceTrend,
      expectedTrend: expectedTrend,
      aiRecommendation: aiRecommendation,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUpdated: lastUpdated,
      dailyHistory: dailyHistory,
      weeklyHistory: weeklyHistory,
      monthlyHistory: monthlyHistory,
      yearlyHistory: yearlyHistory,
      nearbyMarkets: nearbyMarkets,
    );
  }
}

class MarketAnalysisData {
  final List<String> categories;
  final List<CommodityDetail> commodities;

  const MarketAnalysisData({
    required this.categories,
    required this.commodities,
  });

  factory MarketAnalysisData.fromJson(Map<String, dynamic> json) {
    return MarketAnalysisData(
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((x) => x.toString())
          .toList(),
      commodities: (json['commodities'] as List<dynamic>? ?? [])
          .map((x) => CommodityDetail.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }
}
