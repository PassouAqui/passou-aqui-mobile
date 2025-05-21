import 'package:flutter/material.dart';
import 'app.dart';

// Configuração global para quando não temos arquivo .env
class AppConfig {
  // Opções para diferentes ambientes
  static const String _emulatorUrl = "http://10.0.2.2:8000/api/v1/";
  static const String _localIpUrl = "http://192.168.0.6:8000/api/v1/";
  static const String _localHostUrl = "http://localhost:8000/api/v1/";

  // URL ativa - altere aqui para testar diferentes configurações
  static const String apiBaseUrl = _emulatorUrl;
  static const bool isDevelopment = true;

  // Método para uso em debug
  static void printApiUrl() {
    debugPrint('API URL configurada: $apiBaseUrl');
    debugPrint('Outras opções:');
    debugPrint('- Emulador: $_emulatorUrl');
    debugPrint('- IP Local: $_localIpUrl');
    debugPrint('- Localhost: $_localHostUrl');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug da configuração
  if (AppConfig.isDevelopment) {
    AppConfig.printApiUrl();
  }

  runApp(const MyApp());
}
