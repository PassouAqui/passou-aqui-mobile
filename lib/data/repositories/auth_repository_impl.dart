import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<User> login(String username, String password) async {
    final response = await _authService.login(username, password);

    return User(
      username: username,
      accessToken: response.access,
      refreshToken: response.refresh,
    );
  }
}
