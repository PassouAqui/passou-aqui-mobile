import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:passou_aqui_mobile/data/api/api_client.dart';
import 'package:passou_aqui_mobile/data/api/auth/login.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences _prefs;
  final ApiClient _apiClient;
  final LoginApi _loginApi;
  static const String _userKey = 'user_data';
  static const String _authStateKey = 'auth_state';

  AuthBloc({
    required SharedPreferences prefs,
    required ApiClient apiClient,
    required LoginApi loginApi,
  })  : _prefs = prefs,
        _apiClient = apiClient,
        _loginApi = loginApi,
        super(AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔄 AuthBloc: Iniciando registro...');
      emit(AuthLoading());

      final response = await _apiClient.post(
        '/accounts/register/',
        data: {
          'username': event.username,
          'email': event.email,
          'password': event.password,
        },
      );

      if (response.statusCode == 201) {
        debugPrint('✅ AuthBloc: Registro bem sucedido, salvando dados...');
        final data = response.data;
        await _apiClient.setAccessToken(data['access']);
        await _apiClient.setRefreshToken(data['refresh']);

        final userData = {
          'username': event.username,
          'email': event.email,
        };

        await _prefs.setString(_userKey, jsonEncode(userData));
        await _prefs.setString(_authStateKey, 'authenticated');

        debugPrint('✅ AuthBloc: Dados salvos com sucesso');
        emit(AuthAuthenticated(
          token: data['access'],
          user: userData,
        ));
      } else {
        final error = response.data;
        debugPrint('❌ AuthBloc: Erro no registro - ${error['detail']}');
        emit(AuthError(error['detail'] ?? 'Erro ao registrar usuário'));
      }
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro inesperado no registro - $e');
      emit(AuthError('Erro ao conectar com o servidor'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔄 AuthBloc: Iniciando login...');
      emit(AuthLoading());

      final authEntity = await _loginApi(event.email, event.password);
      final user = await _getUserProfile();

      debugPrint('✅ AuthBloc: Login bem sucedido, salvando dados...');
      await _prefs.setString(_userKey, jsonEncode(user));
      await _prefs.setString(_authStateKey, 'authenticated');

      debugPrint('✅ AuthBloc: Dados salvos com sucesso');
      emit(AuthAuthenticated(
        token: authEntity.accessToken,
        user: user,
      ));
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro no login - $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<Map<String, dynamic>> _getUserProfile() async {
    try {
      debugPrint('🔍 AuthBloc: Buscando perfil do usuário...');
      final response = await _apiClient.get('/accounts/profile/');
      debugPrint('✅ AuthBloc: Perfil obtido com sucesso');
      return response.data;
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro ao buscar perfil - $e');
      throw Exception('Erro ao carregar perfil do usuário');
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔄 AuthBloc: Iniciando logout...');
      await _apiClient.clearTokens();
      await _prefs.remove(_userKey);
      await _prefs.remove(_authStateKey);
      debugPrint('✅ AuthBloc: Logout realizado com sucesso');
      emit(AuthUnauthenticated());
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro ao fazer logout - $e');
      emit(AuthError('Erro ao fazer logout'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔍 AuthBloc: Verificando status de autenticação...');
      final token = await _apiClient.getAccessToken();
      final userStr = _prefs.getString(_userKey);
      final authState = _prefs.getString(_authStateKey);

      if (token != null && userStr != null && authState == 'authenticated') {
        debugPrint('✅ AuthBloc: Usuário autenticado encontrado');
        try {
          final user = jsonDecode(userStr);
          emit(AuthAuthenticated(token: token, user: user));
        } catch (e) {
          debugPrint('❌ AuthBloc: Erro ao decodificar dados do usuário - $e');
          await _clearAuthData();
          emit(AuthUnauthenticated());
        }
      } else {
        debugPrint('ℹ️ AuthBloc: Nenhuma sessão ativa encontrada');
        await _clearAuthData();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro ao verificar status de autenticação - $e');
      await _clearAuthData();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _apiClient.clearTokens();
      await _prefs.remove(_userKey);
      await _prefs.remove(_authStateKey);
      debugPrint('🧹 AuthBloc: Dados de autenticação limpos');
    } catch (e) {
      debugPrint('❌ AuthBloc: Erro ao limpar dados de autenticação - $e');
    }
  }
}
