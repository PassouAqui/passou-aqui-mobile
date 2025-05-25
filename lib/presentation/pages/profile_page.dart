import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/app_scaffold.dart';
import '../widgets/common/info_card.dart';
import '../widgets/common/loading_error_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      debugPrint('🔑 Usuário autenticado, carregando perfil...');
      if (!mounted) return;
      await Provider.of<ProfileProvider>(context, listen: false).loadProfile();
    } else {
      debugPrint('❌ Usuário não autenticado, redirecionando para login...');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para ver seu perfil'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return AppScaffold(
      title: 'Meu Perfil',
      showLogoutButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadProfile,
        ),
      ],
      body: LoadingErrorState(
        isLoading: profileProvider.isLoading,
        error: profileProvider.error,
        onRetry: _loadProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar do usuário
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profileProvider.profile?.photo != null
                      ? NetworkImage(profileProvider.profile!.photo!)
                      : null,
                  child: profileProvider.profile?.photo == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Informações do usuário
              InfoCard(
                title: 'Usuário',
                content: profileProvider.profile?.username ?? '',
                icon: Icons.account_circle,
              ),
              InfoCard(
                title: 'E-mail',
                content: profileProvider.profile?.email ?? '',
                icon: Icons.email,
              ),
              if (profileProvider.profile?.name != null)
                InfoCard(
                  title: 'Nome',
                  content: profileProvider.profile!.name!,
                  icon: Icons.person,
                ),
              if (profileProvider.profile?.phone != null)
                InfoCard(
                  title: 'Telefone',
                  content: profileProvider.profile!.phone!,
                  icon: Icons.phone,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
