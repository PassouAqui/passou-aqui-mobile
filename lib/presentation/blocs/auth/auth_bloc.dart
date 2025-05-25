import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/api/api_client.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;
  final ApiClient _apiClient;

  AuthBloc(this._authRepository, this._apiClient) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    // Verifica autenticação ao iniciar
    add(AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔍 AuthBloc: Verificando autenticação...');
      final token = await _apiClient.getAccessToken();
      final isAuthenticated = token != null;
      debugPrint('🔍 AuthBloc: Status de autenticação: $isAuthenticated');

      if (isAuthenticated) {
        debugPrint('🔑 AuthBloc: Usuário autenticado');
        emit(AuthAuthenticated());
      } else {
        debugPrint('❌ AuthBloc: Usuário não autenticado');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro ao verificar autenticação: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await _authRepository.login(event.email, event.password);
      debugPrint('✅ AuthBloc: Login realizado com sucesso!');
      emit(AuthAuthenticated());
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro no login: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await _authRepository.logout();
      debugPrint('✅ AuthBloc: Logout realizado com sucesso');
      emit(AuthUnauthenticated());
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro no logout: $e');
      emit(AuthError(e.toString()));
    }
  }
}
