import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({required this.data, required this.timestamp, required this.ttl});

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'ttl_seconds': ttl.inSeconds,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      ttl: Duration(seconds: json['ttl_seconds']),
    );
  }
}

class CacheManager {
  late Box<String> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>('api_cache');
  }

  Future<void> setCache(String key, dynamic data, {Duration ttl = const Duration(hours: 1)}) async {
    final entry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
    await _cacheBox.put(key, jsonEncode(entry.toJson()));
  }

  dynamic getCache(String key) {
    final str = _cacheBox.get(key);
    if (str == null) return null;

    try {
      final entry = CacheEntry.fromJson(jsonDecode(str));
      if (entry.isExpired) {
        _cacheBox.delete(key);
        return null;
      }
      return entry.data;
    } catch (e) {
      return null;
    }
  }

  Future<void> invalidateCache(String key) async {
    await _cacheBox.delete(key);
  }
}
