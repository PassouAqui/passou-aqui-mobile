import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/env.dart';
import '../../domain/entities/auth_entity.dart';

class ApiService {
  Dio? _dio;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  bool _isInitialized = false;

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
          try {
            final token = await getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          } catch (e) {
            debugPrint('Erro ao obter token: $e');
            return handler.next(options);
          }
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              await _refreshToken();
              final token = await getAccessToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                return handler.resolve(await dio.fetch(error.requestOptions));
              }
            } catch (e) {
              debugPrint('Erro ao atualizar token: $e');
            }
          }
          return handler.next(error);
        },
      ),
    );

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

  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      debugPrint('🌐 ApiService: POST $endpoint');
      debugPrint('🌐 ApiService: Dados: $data');

      final token = await getAccessToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      debugPrint('🌐 ApiService: Headers: $headers');

      final response = await dio.post(
        '${Env.apiUrl}$endpoint',
        data: data,
        options: Options(headers: headers),
      );

      debugPrint('🌐 ApiService: Resposta - Status: ${response.statusCode}');
      debugPrint('🌐 ApiService: Resposta - Dados: ${response.data}');

      return response;
    } on DioException catch (e) {
      debugPrint('❌ ApiService: Erro DioException - ${e.message}');
      debugPrint('❌ ApiService: Resposta de erro - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        debugPrint('🔒 ApiService: Token expirado, tentando refresh...');
        try {
          final currentRefreshToken = await getRefreshToken();
          if (currentRefreshToken == null) {
            debugPrint('❌ ApiService: Sem refresh token disponível');
            await clearTokens();
            rethrow;
          }

          final newTokens = await refreshToken(currentRefreshToken);
          await setAccessToken(newTokens.accessToken);
          debugPrint('✅ ApiService: Token atualizado com sucesso');

          // Retry the original request
          final token = await getAccessToken();
          final headers = {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          };

          final response = await dio.post(
            '${Env.apiUrl}$endpoint',
            data: data,
            options: Options(headers: headers),
          );

          debugPrint(
              '🌐 ApiService: Retry bem-sucedido - Status: ${response.statusCode}');
          return response;
        } catch (refreshError) {
          debugPrint('❌ ApiService: Erro ao atualizar token: $refreshError');
          await clearTokens();
          rethrow;
        }
      }
      rethrow;
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

  Future<AuthEntity> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/accounts/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final newToken = response.data['access'] as String;
      final newRefreshToken = response.data['refresh'] as String;
      await _saveAccessToken(newToken);
      await _saveRefreshToken(newRefreshToken);
      return AuthEntity(
        accessToken: newToken,
        refreshToken: newRefreshToken,
      );
    } catch (e) {
      debugPrint('Erro ao atualizar token: $e');
      await clearTokens();
      rethrow;
    }
  }

  Future<void> _refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        throw 'Refresh token não encontrado';
      }

      debugPrint('Atualizando token...');
      final response = await dio.post(
        '/accounts/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final newToken = response.data['access'] as String;
      await _saveAccessToken(newToken);
      debugPrint('Token atualizado com sucesso');
    } catch (e) {
      debugPrint('Erro ao atualizar token: $e');
      await clearTokens();
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> setAccessToken(String token) async {
    await _saveAccessToken(token);
  }

  Future<String?> getRefreshToken() async {
    return await _getRefreshToken();
  }

  Future<String?> _getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> _saveAccessToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> _saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de conexão esgotado. Verifique sua internet.';
    }

    if (error.type == DioExceptionType.unknown) {
      return 'Erro de conexão. Verifique sua internet.';
    }

    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message'] ??
        error.response?.data?['detail'] ??
        error.message ??
        'Erro desconhecido';

    return '$message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}
