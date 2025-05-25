import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/auth_entity.dart';
import '../api_client.dart';

class LoginApi {
  final ApiClient _client;

  LoginApi(this._client);

  Future<AuthEntity> call(String email, String password) async {
    try {
      debugPrint('🔑 LoginApi: Iniciando login...');

      final response = await _client.post(
        '/accounts/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['access'] as String;
        final refreshToken = data['refresh'] as String;

        debugPrint('🔑 LoginApi: Tokens obtidos, salvando...');
        await _client.setAccessToken(accessToken);
        await _client.setRefreshToken(refreshToken);
        debugPrint('✅ LoginApi: Tokens salvos com sucesso');

        return AuthEntity(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } else {
        throw Exception('Falha na autenticação: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ LoginApi: Erro DioException - ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Email ou senha inválidos');
      }
      throw Exception('Erro ao fazer login: ${e.message}');
    } catch (e) {
      debugPrint('❌ LoginApi: Erro inesperado - $e');
      throw Exception('Erro ao fazer login: $e');
    }
  }
}
