import 'package:flutter/material.dart';
import 'home.dart';
import 'rastreamento.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rastreamento de Medicamentos',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/rastreamento': (context) => const TelaRastreamento(), 
      },
    );
  }
}
