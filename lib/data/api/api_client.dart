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

  void _handleAuthError() async {
    debugPrint('🔒 Erro de autenticação, redirecionando para login...');
    await clearTokens();
    _onAuthError?.call();
  }

  void _initializeDio() {
    if (_isInitialized) return;

    debugPrint('🌐 ApiClient: Inicializando Dio...');
    debugPrint('🌐 ApiClient: URL Base: ${Env.apiUrl}');

    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: Env.defaultHeaders,
      ),
    );

    debugPrint('🌐 ApiClient: Configurando interceptors...');

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            debugPrint('🌐 ApiClient: ${options.method} ${options.path}');
            debugPrint('🌐 ApiClient: Headers: ${options.headers}');
            debugPrint('🌐 ApiClient: Data: ${options.data}');

            // Se for um endpoint público, permite a requisição sem token
            if (_isPublicEndpoint(options.path)) {
              debugPrint(
                  '🔓 ApiClient: Endpoint público, permitindo requisição sem token');
              return handler.next(options);
            }

            final token = await getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              debugPrint('🔑 ApiClient: Token adicionado aos headers');
            } else {
              debugPrint('❌ ApiClient: Token não encontrado');
              _handleAuthError();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'Token não encontrado',
                ),
              );
            }
            return handler.next(options);
          } catch (e) {
            debugPrint('❌ ApiClient: Erro ao obter token: $e');
            _handleAuthError();
            return handler.reject(
              DioException(
                requestOptions: options,
                error: e.toString(),
              ),
            );
          }
        },
        onResponse: (response, handler) {
          debugPrint('✅ ApiClient: Resposta recebida - ${response.statusCode}');
          debugPrint('📦 ApiClient: Dados: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('❌ ApiClient: Erro na requisição - ${error.message}');
          debugPrint(
              '❌ ApiClient: Status code - ${error.response?.statusCode}');
          debugPrint('❌ ApiClient: Resposta - ${error.response?.data}');

          if (error.response?.statusCode == 401 && !_isRefreshing) {
            try {
              _isRefreshing = true;
              debugPrint('🔒 ApiClient: Token expirado, tentando refresh...');
              await _refreshToken();
              final token = await getAccessToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                _isRefreshing = false;
                debugPrint(
                    '✅ ApiClient: Token atualizado, retentando requisição');
                return handler.resolve(await dio.fetch(error.requestOptions));
              } else {
                debugPrint('❌ ApiClient: Falha ao obter novo token');
                _handleAuthError();
                return handler.reject(error);
              }
            } catch (e) {
              debugPrint('❌ ApiClient: Erro ao atualizar token: $e');
              _handleAuthError();
              return handler.reject(error);
            } finally {
              _isRefreshing = false;
            }
          }
          return handler.next(error);
        },
      ),
    );

    debugPrint('✅ ApiClient: Dio inicializado com sucesso');
    _isInitialized = true;
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      debugPrint('🌐 ApiClient: POST $path');
      debugPrint('🌐 ApiClient: Dados: $data');

      final token = await getAccessToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );

      debugPrint('🌐 ApiClient: Resposta - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Refresh token não encontrado');
      }

      debugPrint('🔄 Atualizando token...');
      final response = await dio.post(
        '/accounts/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final newToken = response.data['access'] as String;
      final newRefreshToken = response.data['refresh'] as String;

      await setAccessToken(newToken);
      await setRefreshToken(newRefreshToken);
      debugPrint('✅ Token atualizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar token: $e');
      await clearTokens();
      rethrow;
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response?.data as Map;
      final message = data['detail'] ?? data['message'] ?? e.message;
      return Exception(message);
    }
    return Exception(e.message ?? 'Erro na requisição');
  }
}
