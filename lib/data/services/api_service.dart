import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../main.dart';

class ApiService {
  final Dio _dio;
  String? _accessToken;

  ApiService(Dio dio) : _dio = dio {
    // Configurar o Dio com baseUrl e outras opções
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Adicionar interceptor para capturar detalhes de erro
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Adicionar token de autenticação se disponível
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
            debugPrint('📤 Requisição com autenticação: ${options.uri}');
            debugPrint('🔑 Token: Bearer $_accessToken');
            debugPrint('📋 Headers: ${options.headers}');
          } else {
            debugPrint('📤 Requisição SEM autenticação: ${options.uri}');
            debugPrint('📋 Headers: ${options.headers}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '📥 Resposta [${response.statusCode}]: ${response.requestOptions.uri}',
          );
          debugPrint('📄 Dados: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          if (e.response != null) {
            debugPrint('=== ERRO DE API ===');
            debugPrint('Status: ${e.response?.statusCode}');
            debugPrint('Dados: ${e.response?.data}');
            debugPrint('Headers: ${e.response?.headers}');
            debugPrint('URL: ${e.requestOptions.uri}');
            debugPrint('Método: ${e.requestOptions.method}');
            debugPrint('Body: ${e.requestOptions.data}');
            debugPrint('Headers enviados: ${e.requestOptions.headers}');
          } else if (e.type == DioExceptionType.connectionTimeout) {
            debugPrint('=== ERRO DE TIMEOUT DE CONEXÃO ===');
            debugPrint('URL: ${e.requestOptions.uri}');
            debugPrint('Método: ${e.requestOptions.method}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Método para definir o token de autenticação
  void setAccessToken(String token) {
    _accessToken = token;
    debugPrint('🔐 Token configurado: $token');
  }

  // Método para limpar o token
  void clearToken() {
    _accessToken = null;
    debugPrint('🔓 Token removido');
  }

  Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data;
    } catch (e) {
      debugPrint('❌ Erro ao fazer GET para $path: $e');
      _handleApiError(e);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } catch (e) {
      return _handleApiError(e);
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } catch (e) {
      return _handleApiError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } catch (e) {
      _handleApiError(e);
    }
  }

  dynamic _handleApiError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Erro de conexão: O servidor demorou para responder. Verifique sua conexão com a internet ou se o servidor está online.',
        );
      } else if (e.response != null) {
        // Extrair a mensagem de erro da resposta, se existir
        final responseData = e.response!.data;
        if (responseData is Map && responseData.containsKey('detail')) {
          throw Exception('Erro API: ${responseData['detail']}');
        }
      }
    }
    throw e;
  }
}
