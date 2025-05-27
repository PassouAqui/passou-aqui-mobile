abstract class AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  RegisterRequested({
    required this.username,
    required this.email,
    required this.password,
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
