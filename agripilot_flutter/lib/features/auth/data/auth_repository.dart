import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ApiClient(),
    const FlutterSecureStorage(),
  );
});

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  /// Register a new user with name, email, and password.
  Future<String> register(String name, String email, String password) async {
    final response = await _apiClient.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    return response['message'] ?? 'Registration successful';
  }

  /// Login with email and password. Stores JWT tokens securely.
  Future<void> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    final accessToken = response['access_token'];
    final refreshToken = response['refresh_token'];

    await _storage.write(key: 'jwt_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Check if the user is already logged in (has a stored JWT token).
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }

  /// Logout: clear all stored tokens.
  Future<void> signOut() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
  }
}
