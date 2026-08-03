/// Models for the Dashboard Feature
/// Decoupled domain objects with robust JSON parsing for FastAPI backend data formats.
library;

class Weather {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int rainProbability;
  final String condition;
  final String locationName;

  const Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.condition,
    required this.locationName,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? json;

    return Weather(
      temperature: (current['temperature'] as num? ?? json['temperature'] as num? ?? 28.0).toDouble(),
      humidity: (current['humidity'] as num? ?? json['humidity'] as num? ?? 65.0).toDouble(),
      windSpeed: (current['wind_speed'] as num? ?? json['wind_speed'] as num? ?? 10.0).toDouble(),
      rainProbability: (current['rain_probability'] as num? ?? json['rain_probability'] as num? ?? 30).toInt(),
      condition: json['forecast_summary'] as String? ?? current['forecast_summary'] as String? ?? 'Partly Cloudy',
      locationName: json['location'] as String? ?? 'Vijayawada, AP',
    );
  }
}

class MarketItem {
  final String cropName;
  final double currentPrice;
  final double yesterdayPrice;
  final String trend;

  const MarketItem({
    required this.cropName,
    required this.currentPrice,
    required this.yesterdayPrice,
    required this.trend,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json) {
    final curPrice = (json['current_price'] ?? json['modal_price'] ?? json['modal_price_rs'] ?? 0) as num;
    final yestPrice = (json['yesterday_price'] ?? json['min_price'] ?? json['min_price_rs'] ?? (curPrice * 0.95)) as num;

    return MarketItem(
      cropName: json['crop_name'] ?? json['commodity'] ?? json['crop'] ?? 'Crop',
      currentPrice: curPrice.toDouble(),
      yesterdayPrice: yestPrice.toDouble(),
      trend: json['weekly_trend'] ?? json['trend'] ?? 'stable',
    );
  }
}

class Recommendation {
  final String id;
  final String title;
  final String reason;
  final String suggestedAction;
  final double confidenceScore;
  final String priority;

  const Recommendation({
    required this.id,
    required this.title,
    required this.reason,
    required this.suggestedAction,
    required this.confidenceScore,
    required this.priority,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    final titleStr = json['title'] ?? json['crop_type'] ?? json['topic'] ?? 'Farm Action';
    final idStr = json['id'] as String? ?? titleStr;

    return Recommendation(
      id: idStr,
      title: titleStr,
      reason: json['reason'] ?? json['description'] ?? json['message'] ?? '',
      suggestedAction: json['suggested_action'] ?? json['action'] ?? 'Follow recommended guidelines.',
      confidenceScore: ((json['confidence'] ?? json['confidence_score'] ?? 0.85) as num).toDouble(),
      priority: json['priority'] ?? 'high',
    );
  }
}

class NotificationSummary {
  final int unreadCount;
  final String latestMessage;
  final String severity;
  final DateTime timestamp;

  const NotificationSummary({
    required this.unreadCount,
    required this.latestMessage,
    required this.severity,
    required this.timestamp,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    final notifications = json['notifications'] as List<dynamic>? ?? [];

    String message = 'No new notifications';
    String sev = 'info';
    DateTime time = DateTime.now();

    if (notifications.isNotEmpty) {
      final latest = notifications.first as Map<String, dynamic>;
      message = latest['title'] ?? latest['message'] ?? 'Notification';
      sev = latest['severity'] ?? 'info';
      if (latest['timestamp'] != null) {
        try {
          time = DateTime.parse(latest['timestamp']);
        } catch (_) {}
      }
    }

    return NotificationSummary(
      unreadCount: json['unread_count'] as int? ?? notifications.length,
      latestMessage: message,
      severity: sev,
      timestamp: time,
    );
  }
}
