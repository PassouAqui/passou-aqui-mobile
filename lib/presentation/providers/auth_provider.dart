import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final ApiClient _apiClient;
  final BuildContext context;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthProvider(this._loginUseCase, this._apiClient, this.context) {
    _apiClient.setAuthErrorCallback(() {
      debugPrint('🔄 AuthProvider: Notificando erro de autenticação...');
      notifyListeners();
    });
    _checkAuthStatus();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _checkAuthStatus() async {
    try {
      final accessToken = await _apiClient.getAccessToken();
      _isAuthenticated = accessToken != null;
      debugPrint(
          '🔍 AuthProvider: Verificando token - ${_isAuthenticated ? 'Encontrado' : 'Não encontrado'}');
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      debugPrint(
          '❌ AuthProvider: Erro ao verificar status de autenticação: $e');
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔑 AuthProvider: Iniciando login...');
      await _loginUseCase(email, password);
      debugPrint('✅ AuthProvider: Login realizado com sucesso!');
      await _checkAuthStatus();
    } catch (e) {
      debugPrint('❌ AuthProvider: Erro no login: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.clearTokens();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ AuthProvider: Erro ao fazer logout: $e');
      rethrow;
    }
  }
}
