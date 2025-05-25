import 'package:dio/dio.dart';
import '../../../domain/entities/profile.dart';
import '../api_client.dart';

class UpdateProfileApi {
  final ApiClient _client;

  UpdateProfileApi(this._client);

  Future<Profile> call(Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        '/accounts/profile/',
        data: data,
      );
      return Profile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }
      throw Exception('Erro ao atualizar perfil');
    }
  }
}
