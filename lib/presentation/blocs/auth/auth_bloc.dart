import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;

  AuthBloc(this._authRepository) : super(AuthUnauthenticated()) {
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
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        debugPrint('🔑 Token encontrado, configurando autenticação...');
        emit(AuthAuthenticated());
      } else {
        debugPrint('❌ Nenhum token encontrado, usuário não autenticado');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar autenticação: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await _authRepository.login(event.email, event.password);
      debugPrint('✅ Login realizado com sucesso!');
      emit(AuthAuthenticated());
    } catch (e) {
      debugPrint('❌ Erro no login: $e');
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
      debugPrint('✅ Logout realizado com sucesso');
      emit(AuthUnauthenticated());
    } catch (e) {
      debugPrint('❌ Erro no logout: $e');
      emit(AuthError(e.toString()));
    }
  }
}
