import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;
  final String baseUrl;

  AuthRemoteDataSource({
    required this.client,
    required this.secureStorage,
    required this.baseUrl,
  });

  Future<AuthEntity> login(String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final authEntity = AuthEntity(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );

        // Store tokens securely
        await secureStorage.write(
            key: 'access_token', value: authEntity.accessToken);
        await secureStorage.write(
            key: 'refresh_token', value: authEntity.refreshToken);

        return authEntity;
      } else {
        final error = json.decode(response.body);
        throw AuthException(
          error['detail'] ?? 'Falha na autenticação',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro de rede ocorreu');
    }
  }

  Future<AuthEntity> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/accounts/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access'];

        // Update stored access token
        await secureStorage.write(key: 'access_token', value: newAccessToken);

        // Get the stored refresh token and user data
        final storedRefreshToken =
            await secureStorage.read(key: 'refresh_token');
        if (storedRefreshToken == null) {
          throw AuthException('No refresh token found');
        }

        // For now, we'll just return the tokens
        return AuthEntity(
          accessToken: newAccessToken,
          refreshToken: storedRefreshToken,
        );
      } else {
        throw AuthException(
          'Failed to refresh token',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error occurred');
    }
  }

  Future<void> clearTokens() async {
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
  }
}
