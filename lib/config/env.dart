class Env {
  static const String apiBaseUrl =
      'http://10.0.2.2:8000/api/v1'; // Para Android Emulator

  static const String apiUrl = 'http://10.0.2.2:8000/api/v1';

  // Timeouts
  static const int connectionTimeout = 15000; // 15 segundos
  static const int receiveTimeout = 15000; // 15 segundos

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
