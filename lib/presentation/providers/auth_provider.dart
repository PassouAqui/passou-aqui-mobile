import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final ApiService _apiService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._loginUseCase, this._apiService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _loginUseCase(username, password);
      if (_user != null) {
        _apiService.setAccessToken(_user!.accessToken);
        debugPrint('🔑 Login bem-sucedido para $username');
        debugPrint(
          '🔒 Token configurado: ${_user!.accessToken.substring(0, _user!.accessToken.length > 20 ? 20 : _user!.accessToken.length)}...',
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      if (e.toString().contains('Erro API:')) {
        _error = e.toString();
      } else if (e.toString().contains('401')) {
        _error = 'Usuário ou senha inválidos';
      } else {
        _error = 'Erro ao fazer login: ${e.toString()}';
      }
      debugPrint('Erro completo de login: $e');
      notifyListeners();
      return false;
    }
  }

  bool verifyToken() {
    if (_user == null || _user!.accessToken.isEmpty) {
      debugPrint('⚠️ Token não disponível');
      return false;
    }

    _apiService.setAccessToken(_user!.accessToken);
    debugPrint('✅ Token verificado e configurado');
    return true;
  }

  void logout() {
    _user = null;
    _apiService.clearToken();
    debugPrint('👋 Usuário deslogado');
    notifyListeners();
  }
}
