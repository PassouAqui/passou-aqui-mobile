import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../../domain/entities/drug.dart';
import '../../domain/entities/paginated_response.dart';
import 'package:dio/dio.dart';

class DrugRepository {
  final ApiClient _apiClient;

  DrugRepository(this._apiClient);

  Future<PaginatedResponse<Drug>> getDrugs({
    bool? active,
    int? page,
    String? search,
    Tarja? tarja,
  }) async {
    try {
      debugPrint('🔍 DrugRepository: Buscando medicamentos...');
      debugPrint(
          '🔍 DrugRepository: Parâmetros: active=$active, page=$page, search=$search, tarja=${tarja?.code}');

      final queryParams = [
        if (active != null) 'active=$active',
        if (page != null) 'page=$page',
        if (search != null && search.isNotEmpty) 'search=$search',
        if (tarja != null) 'tarja=${tarja.code}',
      ].where((p) => p.isNotEmpty).join('&');

      final url =
          '/inventory/drugs/${queryParams.isNotEmpty ? '?$queryParams' : ''}';
      debugPrint('🔍 DrugRepository: URL: $url');

      final response = await _apiClient.get(url);
      debugPrint('📥 DrugRepository: Resposta: ${response.data}');

      debugPrint('✅ DrugRepository: Medicamentos obtidos com sucesso');
      return PaginatedResponse.fromJson(
        response.data,
        (json) => Drug.fromJson(json),
      );
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao buscar medicamentos: $e');
      if (e is DioException && e.response?.data != null) {
        debugPrint('📋 DrugRepository: Detalhes do erro: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<Drug> getDrug(String id) async {
    try {
      final response = await _apiClient.get('/inventory/drugs/$id/');
      return Drug.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao buscar medicamento: $e');
      rethrow;
    }
  }

  Future<Drug> createDrug(Drug drug) async {
    try {
      final data = {
        "nome": drug.nome,
        "descricao": drug.descricao,
        "tag_uid": drug.tagUid,
        "lote": drug.lote,
        "validade":
            "${drug.validade.year}-${drug.validade.month.toString().padLeft(2, '0')}-${drug.validade.day.toString().padLeft(2, '0')}",
        "ativo": drug.ativo,
        "tarja": drug.tarja.code
      };

      final jsonData = data;
      debugPrint('📤 DrugRepository: Dados sendo enviados: $jsonData');

      final response = await _apiClient.post(
        '/inventory/drugs/',
        data: jsonData,
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao criar medicamento: $e');
      if (e is DioException && e.response?.data != null) {
        debugPrint('📋 DrugRepository: Detalhes do erro: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<Drug> updateDrug(String id, Drug drug) async {
    try {
      // Remove campos que não devem ser editados
      final data = drug.toJson();
      data.remove('nome'); // Nome não pode ser alterado
      data.remove('lote'); // Lote não pode ser alterado
      data.remove('id'); // ID não deve ser enviado
      data.remove('validade'); // Data de validade não pode ser alterada

      debugPrint('📤 DrugRepository: Atualizando medicamento $id');
      debugPrint('📤 DrugRepository: Campos a serem atualizados: $data');
      debugPrint(
          '📤 DrugRepository: Tarja sendo enviada: ${drug.tarja.code} (${drug.tarja.label})');

      final response = await _apiClient.patch(
        '/inventory/drugs/$id/',
        data: data,
      );

      debugPrint('✅ DrugRepository: Medicamento atualizado com sucesso');
      debugPrint('📥 DrugRepository: Resposta do servidor: ${response.data}');
      return Drug.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao atualizar medicamento: $e');
      if (e is DioException && e.response?.data != null) {
        debugPrint('📋 DrugRepository: Detalhes do erro: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<void> deleteDrug(String id) async {
    try {
      await _apiClient.delete('/inventory/drugs/$id/');
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao excluir medicamento: $e');
      rethrow;
    }
  }

  Future<void> deactivateDrug(String id) async {
    try {
      await _apiClient.post('/inventory/drugs/$id/deactivate/');
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao desativar medicamento: $e');
      rethrow;
    }
  }

  Future<void> activateDrug(String id) async {
    try {
      await _apiClient.post('/inventory/drugs/$id/activate/');
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao ativar medicamento: $e');
      rethrow;
    }
  }
}
