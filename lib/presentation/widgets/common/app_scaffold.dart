import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final bool showBackButton;
  final bool showProfileButton;
  final bool showLogoutButton;
  final PreferredSizeWidget? bottom;

  const AppScaffold({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.showBackButton = true,
    this.showProfileButton = true,
    this.showLogoutButton = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final List<Widget> appBarActions = [];

    if (showProfileButton) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            if (authProvider.isAuthenticated) {
              Navigator.of(context).pushNamed('/profile');
            } else {
              _showSessionExpiredSnackBar(context);
            }
          },
        ),
      );
    }

    if (showLogoutButton) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
        ),
      );
    }

    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: appBarActions,
        bottom: bottom,
      ),
      body: body,
    );
  }

  void _showSessionExpiredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sessão expirada. Faça login novamente.'),
        backgroundColor: Colors.orange,
      ),
    );
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
