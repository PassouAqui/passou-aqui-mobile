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
            } else {
              _handleAuthError();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'No access token available',
                ),
              );
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final refreshToken = await getRefreshToken();
              if (refreshToken != null) {
                final response = await _dio!.post(
                  '/accounts/auth/refresh/',
                  data: {'refresh': refreshToken},
                );
                final newToken = response.data['access'] as String;
                await setAccessToken(newToken);
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                _isRefreshing = false;
                return handler.resolve(await _dio!.fetch(error.requestOptions));
              }
            } catch (e) {
              debugPrint('❌ Erro ao atualizar token: $e');
              _handleAuthError();
            }
            _isRefreshing = false;
          }
          return handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  void _handleAuthError() async {
    debugPrint('🔒 Erro de autenticação, notificando...');
    await clearTokens();
    _onAuthError?.call();
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

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      debugPrint('🌐 ApiClient: PATCH $path');
      debugPrint('🌐 ApiClient: Dados: $data');

      final token = await getAccessToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await dio.patch(
        path,
        data: data,
        options: Options(headers: headers),
      );

      debugPrint('🌐 ApiClient: Resposta - Status: ${response.statusCode}');
      debugPrint('🌐 ApiClient: Resposta - Dados: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ ApiClient: Erro na requisição PATCH');
      debugPrint('❌ ApiClient: Status: ${e.response?.statusCode}');
      debugPrint('❌ ApiClient: Dados do erro: ${e.response?.data}');
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

  Exception _handleError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response?.data as Map;
      final message = data['detail'] ?? data['message'] ?? e.message;
      return Exception(message);
    }
    return Exception(e.message ?? 'Erro na requisição');
  }
}
