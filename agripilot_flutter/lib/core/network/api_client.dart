import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../offline/cache_manager.dart';
import '../offline/sync_queue.dart';
import '../offline/models/sync_task.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}

class ApiClient {
  final CacheManager? cacheManager;
  final SyncQueue? syncQueue;

  // USB Cable + ADB Reverse Port Forwarding (http://localhost:8000/api/v1)
  final String baseUrl = 'http://localhost:8000/api/v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  ApiClient({this.cacheManager, this.syncQueue});

  Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      
      debugPrint('GET $uri');
      
      final response = await _client.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      final jsonResponse = _processResponse(response);
      
      if (cacheManager != null) {
        await cacheManager!.setCache(endpoint, jsonResponse);
      }
      
      return jsonResponse;
    } catch (e) {
      debugPrint('Network Error on GET: $e');
      if (e is ApiException) rethrow;
      
      if (cacheManager != null) {
        final cached = cacheManager!.getCache(endpoint);
        if (cached != null) {
          debugPrint('Returning cached data for $endpoint');
          return cached;
        }
      }
      
      throw Exception('Network request failed: $e');
    }
  }

  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      
      debugPrint('POST $uri');
      
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } catch (e) {
      debugPrint('Network Error on POST: $e');
      if (e is ApiException) rethrow;
      
      if (syncQueue != null) {
        debugPrint('Queueing POST request to $endpoint');
        final task = SyncTask(
          uuid: const Uuid().v4(),
          type: TaskType.custom, 
          payload: jsonEncode({'endpoint': endpoint, 'body': body}),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await syncQueue!.enqueue(task);
        throw Exception('Offline: Request queued for sync.');
      }
      
      throw Exception('Network request failed: $e');
    }
  }

  Future<dynamic> uploadMultipartFile(String endpoint, String filePath, {Map<String, String>? fields}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      final token = await _storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      debugPrint('UPLOAD MULTIPART $uri file=$filePath fields=$fields');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      debugPrint('Network Error on UPLOAD: $e');
      if (e is ApiException) rethrow;
      throw Exception('Image upload failed: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid JSON response');
      }
    } else {
      String errorMessage = 'Server Error';
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson['detail'] != null) {
          errorMessage = errorJson['detail'].toString();
        }
      } catch (_) {
        // Fallback to body or standard error
      }
      throw ApiException(response.statusCode, errorMessage);
    }
  }
}
