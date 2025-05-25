import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/auth_entity.dart';
import '../api_client.dart';

class LoginApi {
  final ApiClient _client;

  LoginApi(this._client);

  Future<AuthEntity> call(String email, String password) async {
    try {
      debugPrint('🔑 LoginApi: Iniciando login com email: $email');
      debugPrint('🔑 LoginApi: Endpoint: /accounts/auth/login/');
      debugPrint('🔑 LoginApi: Dados: {email: $email, password: ****}');

      final response = await _client.post(
        '/accounts/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );

      debugPrint(
          '✅ LoginApi: Resposta recebida - Status: ${response.statusCode}');
      debugPrint('📦 LoginApi: Dados recebidos: ${response.data}');

      final accessToken = response.data['access'] as String;
      final refreshToken = response.data['refresh'] as String;

      debugPrint('🔑 LoginApi: Tokens obtidos com sucesso');
      debugPrint('🔑 LoginApi: Salvando tokens...');

      await _client.setAccessToken(accessToken);
      await _client.setRefreshToken(refreshToken);

      debugPrint('✅ LoginApi: Tokens salvos com sucesso');

      return AuthEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      debugPrint('❌ LoginApi: Erro DioException - ${e.message}');
      debugPrint('❌ LoginApi: Resposta de erro - ${e.response?.data}');
      debugPrint('❌ LoginApi: Status code - ${e.response?.statusCode}');
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
