import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Força orientação retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configura o tema do sistema
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Carrega as preferências assim que o widget é inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserPreferencesProvider().loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DependencyInjection.setup(context);
  }
}
