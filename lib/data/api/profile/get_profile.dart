import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/profile.dart';
import '../api_client.dart';

class GetProfileApi {
  final ApiClient _client;

  GetProfileApi(this._client);

  Future<Profile> call() async {
    try {
      debugPrint('🌐 GetProfileApi: Iniciando chamada para /accounts/profile/');
      final token = await _client.getAccessToken();
      debugPrint('🔑 GetProfileApi: Token disponível: ${token != null}');

      final response = await _client.get('/accounts/profile/');
      debugPrint(
          '✅ GetProfileApi: Resposta recebida - Status: ${response.statusCode}');
      debugPrint('📦 GetProfileApi: Dados recebidos: ${response.data}');

      final profile = Profile.fromJson(response.data);
      debugPrint('✅ GetProfileApi: Perfil convertido com sucesso');
      return profile;
    } on DioException catch (e) {
      debugPrint('❌ GetProfileApi: Erro DioException - ${e.message}');
      debugPrint('❌ GetProfileApi: Resposta de erro - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }
      throw Exception('Erro ao carregar perfil: ${e.message}');
    } catch (e) {
      debugPrint('❌ GetProfileApi: Erro inesperado - $e');
      throw Exception('Erro ao carregar perfil: $e');
    }
  }
}
