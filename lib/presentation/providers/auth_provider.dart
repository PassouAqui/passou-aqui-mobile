import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final ApiClient _apiClient;
  final BuildContext context;
  AuthEntity? _authEntity;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._loginUseCase, this._apiClient, this.context) {
    _apiClient.setAuthErrorCallback(_handleAuthError);
    _checkAuthStatus();
  }

  void _handleAuthError() {
    debugPrint('🔄 AuthProvider: Redirecionando para login...');
    _authEntity = null;
    notifyListeners();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  AuthEntity? get authEntity => _authEntity;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authEntity != null;

  Future<void> _checkAuthStatus() async {
    try {
      final token = await _apiClient.getAccessToken();
      if (token != null) {
        debugPrint('🔑 Token encontrado, configurando autenticação...');
        _authEntity = AuthEntity(accessToken: token, refreshToken: '');
        notifyListeners();
      } else {
        debugPrint('❌ Nenhum token encontrado');
        _authEntity = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar status de autenticação: $e');
      _authEntity = null;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔑 Iniciando login...');
      _authEntity = await _loginUseCase(email, password);
      debugPrint('✅ Login realizado com sucesso!');
    } catch (e) {
      debugPrint('❌ Erro no login: $e');
      _error = e.toString();
      _authEntity = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.clearTokens();
      _authEntity = null;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao fazer logout: $e');
      rethrow;
    }
  }
}
