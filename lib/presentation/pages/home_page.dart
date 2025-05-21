import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.user?.username ?? 'Mundo';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              if (authProvider.verifyToken()) {
                Navigator.of(context).pushNamed('/profile');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sessão expirada. Faça login novamente.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Olá, $username!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Text('Você está logado com sucesso!'),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                if (authProvider.verifyToken()) {
                  Navigator.of(context).pushNamed('/profile');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sessão expirada. Faça login novamente.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.person),
              label: const Text('Ver meu perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
