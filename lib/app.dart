import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/profile_page.dart';
import 'di.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: DI.providers,
      child: MaterialApp(
        title: 'Passou Aqui',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/profile': (context) => const ProfilePage(),
          // Adicione outras rotas aqui
        },
      ),
    );
  }
}
