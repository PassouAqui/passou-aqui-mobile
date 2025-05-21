import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_response_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final String _defaultBaseUrl = "http://10.0.2.2:8000/api/v1/";

  AuthService(this._apiService);

  Future<AuthResponseModel> login(String username, String password) async {
    String baseUrl;
    try {
      baseUrl = dotenv.env['API_BASE_URL'] ?? _defaultBaseUrl;
    } catch (e) {
      debugPrint("Erro ao acessar variáveis de ambiente: $e");
      baseUrl = _defaultBaseUrl;
    }

    debugPrint('🔐 Tentando login para usuário: $username');
    debugPrint('🌐 URL de login: ${baseUrl}accounts/login/');

    final response = await _apiService.post('accounts/login/', {
      'username': username,
      'password': password,
    });

    debugPrint('✅ Login bem-sucedido! Tokens recebidos.');

    return AuthResponseModel.fromJson(response);
  }
}
