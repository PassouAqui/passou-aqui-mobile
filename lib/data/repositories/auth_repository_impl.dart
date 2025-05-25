import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({
    required AuthService authService,
  }) : _authService = authService;

  @override
  Future<AuthEntity> login(String email, String password) async {
    try {
      return await _authService.login(email, password);
    } catch (e) {
      throw AuthException(
        e is AuthException ? e.message : 'Failed to login',
        statusCode: e is AuthException ? e.statusCode : null,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _authService.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
