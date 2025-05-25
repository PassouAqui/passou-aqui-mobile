import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../../domain/entities/drug.dart';
import 'package:dio/dio.dart';

class DrugRepository {
  final ApiClient _apiClient;

  DrugRepository(this._apiClient);

  Future<List<Drug>> getDrugs({bool? active}) async {
    try {
      debugPrint('🔍 DrugRepository: Buscando medicamentos...');
      final queryParams = active != null ? '?active=$active' : '';
      final response = await _apiClient.get('/inventory/drugs/$queryParams');

      debugPrint('✅ DrugRepository: Medicamentos obtidos com sucesso');
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((json) => Drug.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao buscar medicamentos: $e');
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
      final response = await _apiClient.post(
        '/inventory/drugs/',
        data: drug.toJson(),
      );
      return Drug.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ DrugRepository: Erro ao criar medicamento: $e');
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
