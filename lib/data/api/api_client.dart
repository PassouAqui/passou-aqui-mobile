import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/env.dart';

typedef AuthCallback = void Function();

class ApiClient {
  Dio? _dio;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  bool _isInitialized = false;
  bool _isRefreshing = false;
  AuthCallback? _onAuthError;

  // Endpoints que não precisam de autenticação
  static const List<String> _publicEndpoints = [
    '/accounts/auth/login/',
    '/accounts/auth/refresh/',
    '/accounts/register/',
  ];

  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((endpoint) => path.endsWith(endpoint));
  }

  void setAuthErrorCallback(AuthCallback callback) {
    _onAuthError = callback;
  }

  Dio get dio {
    if (_dio == null) {
      _initializeDio();
    }
    return _dio!;
  }

  void _initializeDio() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiUrl,
        connectTimeout: const Duration(milliseconds: Env.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: Env.receiveTimeout),
        sendTimeout: const Duration(milliseconds: Env.connectionTimeout),
        headers: Env.defaultHeaders,
      ),
    );

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_isPublicEndpoint(options.path)) {
            final token = await getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              debugPrint('🔄 ApiClient: Token expirado, tentando refresh...');
              final refreshToken = await getRefreshToken();
              if (refreshToken != null) {
                final newToken = await _refreshToken(refreshToken);
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                debugPrint('✅ ApiClient: Token atualizado com sucesso');
                _isRefreshing = false;
                return handler.resolve(await _dio!.fetch(error.requestOptions));
              }
            } catch (e) {
              debugPrint('❌ ApiClient: Erro ao atualizar token - $e');
              _isRefreshing = false;
              await clearTokens();
              _onAuthError?.call();
            }
          }
          _isRefreshing = false;
          return handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  Future<String?> getAccessToken() async {
    try {
      debugPrint('🔍 ApiClient: Buscando access token...');
      final token = await _storage.read(key: _tokenKey);
      debugPrint(token != null
          ? '✅ ApiClient: Token encontrado'
          : 'ℹ️ ApiClient: Token não encontrado');
      return token;
    } catch (e) {
      debugPrint('❌ ApiClient: Erro ao buscar access token - $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      debugPrint('🔍 ApiClient: Buscando refresh token...');
      final token = await _storage.read(key: _refreshTokenKey);
      debugPrint(token != null
          ? '✅ ApiClient: Refresh token encontrado'
          : 'ℹ️ ApiClient: Refresh token não encontrado');
      return token;
    } catch (e) {
      debugPrint('❌ ApiClient: Erro ao buscar refresh token - $e');
      return null;
    }
  }

  Future<void> setAccessToken(String token) async {
    try {
      debugPrint('💾 ApiClient: Salvando access token...');
      await _storage.write(key: _tokenKey, value: token);
      debugPrint('✅ ApiClient: Access token salvo com sucesso');
    } catch (e) {
      debugPrint('❌ ApiClient: Erro ao salvar access token - $e');
      rethrow;
    }
  }

  Future<void> setRefreshToken(String token) async {
    try {
      debugPrint('💾 ApiClient: Salvando refresh token...');
      await _storage.write(key: _refreshTokenKey, value: token);
      debugPrint('✅ ApiClient: Refresh token salvo com sucesso');
    } catch (e) {
      debugPrint('❌ ApiClient: Erro ao salvar refresh token - $e');
      rethrow;
    }
  }

  Future<String> _refreshToken(String refreshToken) async {
    try {
      debugPrint('🔄 ApiClient: Iniciando refresh do token...');
      final response = await _dio!.post(
        '/accounts/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access'] as String;
        await setAccessToken(newToken);
        debugPrint('✅ ApiClient: Token atualizado com sucesso');
        return newToken;
      } else {
        throw Exception('Falha ao atualizar token');
      }
    } catch (e) {
      debugPrint('❌ ApiClient: Erro ao atualizar token - $e');
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    try {
      debugPrint('🧹 ApiClient: Limpando tokens...');
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      debugPrint('✅ ApiClient: Tokens limpos com sucesso');
    } catch (e) {
      debugPrint('❌ ApiClient: Erro ao limpar tokens - $e');
      rethrow;
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      debugPrint('📡 ApiClient: GET $path');
      final response = await dio.get(path, queryParameters: queryParameters);
      debugPrint('✅ ApiClient: GET $path - Sucesso');
      return response;
    } catch (e) {
      debugPrint('❌ ApiClient: GET $path - Erro: $e');
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      debugPrint('📡 ApiClient: POST $path');
      final response = await dio.post(path, data: data);
      debugPrint('✅ ApiClient: POST $path - Sucesso');
      return response;
    } catch (e) {
      debugPrint('❌ ApiClient: POST $path - Erro: $e');
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      debugPrint('📡 ApiClient: PUT $path');
      final response = await dio.put(path, data: data);
      debugPrint('✅ ApiClient: PUT $path - Sucesso');
      return response;
    } catch (e) {
      debugPrint('❌ ApiClient: PUT $path - Erro: $e');
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      debugPrint('📡 ApiClient: DELETE $path');
      final response = await dio.delete(path);
      debugPrint('✅ ApiClient: DELETE $path - Sucesso');
      return response;
    } catch (e) {
      debugPrint('❌ ApiClient: DELETE $path - Erro: $e');
      rethrow;
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      debugPrint('📡 ApiClient: PATCH $path');
      final response = await dio.patch(path, data: data);
      debugPrint('✅ ApiClient: PATCH $path - Sucesso');
      return response;
    } catch (e) {
      debugPrint('❌ ApiClient: PATCH $path - Erro: $e');
      rethrow;
    }
  }
}
