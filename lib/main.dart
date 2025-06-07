import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passou_aqui_mobile/presentation/blocs/auth/auth_bloc.dart';
import 'package:passou_aqui_mobile/presentation/blocs/auth/auth_event.dart';
import 'package:passou_aqui_mobile/di.dart';
import 'package:passou_aqui_mobile/data/api/api_client.dart';
import 'package:passou_aqui_mobile/data/api/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa serviços essenciais
  final prefs = await SharedPreferences.getInstance();

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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            prefs: prefs,
            apiClient: ApiClient(),
            loginApi: LoginApi(ApiClient()),
          )..add(CheckAuthStatus()),
        ),
      ],
      child: Builder(
        builder: (context) => FutureBuilder<Widget>(
          future: DependencyInjection.setup(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Erro ao inicializar o app: ${snapshot.error}'),
                  ),
                ),
              );
            }

            // Carrega as preferências do usuário após o setup das dependências
            final userPreferencesProvider = getUserPreferencesProvider();
            userPreferencesProvider.loadPreferences();

            return snapshot.data!;
          },
        ),
      ),
    ),
  );
}
