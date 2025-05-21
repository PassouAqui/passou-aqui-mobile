import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Carregar o perfil quando a página for iniciada
    Future.microtask(() {
      // Verificar se o usuário está logado antes de carregar o perfil
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        Provider.of<ProfileProvider>(context, listen: false).loadProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você precisa estar logado para ver seu perfil'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              profileProvider.loadProfile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
        ],
      ),
      body:
          profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : profileProvider.error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profileProvider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        profileProvider.loadProfile();
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Verificar se temos o token de acesso
                        if (authProvider.user != null) {
                          debugPrint(
                            'Token: ${authProvider.user!.accessToken}',
                          );
                        } else {
                          debugPrint('Usuário não está logado');
                        }
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Fazer Login Novamente'),
                    ),
                  ],
                ),
              )
              : profileProvider.profile == null
              ? const Center(child: Text('Nenhum perfil encontrado'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar do usuário
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          profileProvider.profile!.photo != null
                              ? NetworkImage(profileProvider.profile!.photo!)
                              : null,
                      child:
                          profileProvider.profile!.photo == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    const SizedBox(height: 24),

                    // Informações do usuário
                    ProfileInfoCard(
                      title: 'Usuário',
                      content: profileProvider.profile!.username,
                      icon: Icons.account_circle,
                    ),
                    ProfileInfoCard(
                      title: 'E-mail',
                      content: profileProvider.profile!.email,
                      icon: Icons.email,
                    ),
                    if (profileProvider.profile!.name != null)
                      ProfileInfoCard(
                        title: 'Nome',
                        content: profileProvider.profile!.name!,
                        icon: Icons.person,
                      ),
                    if (profileProvider.profile!.phone != null)
                      ProfileInfoCard(
                        title: 'Telefone',
                        content: profileProvider.profile!.phone!,
                        icon: Icons.phone,
                      ),
                  ],
                ),
              ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
