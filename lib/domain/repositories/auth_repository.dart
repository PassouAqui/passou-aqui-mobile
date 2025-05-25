import '../entities/auth_entity.dart';

abstract class AuthRepository {
  /// Autentica um usuário com username e senha
  /// Retorna [AuthEntity] contendo os tokens de acesso
  /// Lança [AuthException] se a autenticação falhar
  Future<AuthEntity> login(String email, String password);

  /// Faz logout do usuário atual
  /// Limpa todos os dados de autenticação
  Future<void> logout();

  /// Verifica se o usuário está autenticado
  /// Retorna true se existir um token de acesso válido
  Future<bool> isAuthenticated();
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() =>
      'AuthException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
