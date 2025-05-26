import 'package:flutter/foundation.dart';
import '../api/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      debugPrint('🔍 DashboardRepository: Buscando dados do dashboard...');
      final response = await _apiClient.get('/inventory/dashboard/');
      debugPrint('✅ DashboardRepository: Dados obtidos com sucesso');
      return response.data;
    } catch (e) {
      debugPrint(
          '❌ DashboardRepository: Erro ao buscar dados do dashboard: $e');
      rethrow;
    }
  }
}
