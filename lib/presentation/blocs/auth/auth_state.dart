abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final Map<String, dynamic> user;

  AuthAuthenticated({
    required this.token,
    required this.user,
  });
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthUnauthenticated extends AuthState {}
