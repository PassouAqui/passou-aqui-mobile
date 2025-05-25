import 'package:dio/dio.dart';
import '../../../domain/entities/drug.dart';
import '../../../domain/entities/paginated_response.dart';
import '../api_client.dart';

class GetDrugsApi {
  final ApiClient _client;

  GetDrugsApi(this._client);

  Future<PaginatedResponse<Drug>> call({String? nextUrl}) async {
    try {
      final response = await _client.get(
        nextUrl ?? '/inventory/drugs/',
      );

      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => Drug.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['detail'] ?? 'Erro ao buscar medicamentos');
    } catch (e) {
      throw Exception('Erro ao buscar medicamentos');
    }
  }
}
