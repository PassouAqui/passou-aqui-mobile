import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpClientFactory {
  static Dio createClient({String? token}) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return Dio(BaseOptions(baseUrl: baseUrl, headers: headers));
  }
}
