import '../../domain/entities/auth_entity.dart';
import '../api/auth/login.dart';
import '../api/api_client.dart';

class AuthService {
  final LoginApi _loginApi;
  final ApiClient _apiClient;

  AuthService(this._loginApi, this._apiClient);

  Future<AuthEntity> login(String email, String password) async {
    return await _loginApi(email, password);
  }

  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  Future<String?> getAccessToken() async {
    return await _apiClient.getAccessToken();
  }
}
