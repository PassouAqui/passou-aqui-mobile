import 'package:flutter/foundation.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository _repository;

  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._repository);

  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _repository.getDashboardData();
      debugPrint('✅ DashboardProvider: Dados carregados com sucesso');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ DashboardProvider: Erro ao carregar dados: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
