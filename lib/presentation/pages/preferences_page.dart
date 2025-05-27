import 'package:flutter/material.dart';
import '../../di.dart';
import '../providers/user_preferences_provider.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late final UserPreferencesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = getUserPreferencesProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usar ListenableBuilder para reagir às mudanças do provider
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        if (_provider.isLoading && _provider.preferences == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_provider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar preferências',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _provider.error!,
                    style:
                        theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _provider.loadPreferences(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final preferences = _provider.preferences!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Preferências'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                context,
                title: 'Aparência',
                children: [
                  SwitchListTile(
                    title: const Text('Modo Escuro'),
                    subtitle: const Text('Ativar tema escuro'),
                    value: preferences.darkMode,
                    onChanged: (_) => _provider.toggleDarkMode(),
                  ),
                  SwitchListTile(
                    title: const Text('Alto Contraste'),
                    subtitle: const Text('Melhorar legibilidade'),
                    value: preferences.highContrast,
                    onChanged: (_) => _provider.toggleHighContrast(),
                  ),
                  ListTile(
                    title: const Text('Tamanho da Fonte'),
                    subtitle: Text(_getFontSizeLabel(preferences.fontSize)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showFontSizeDialog(context, _provider),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  String _getFontSizeLabel(String fontSize) {
    switch (fontSize) {
      case 'small':
        return 'Pequeno';
      case 'medium':
        return 'Médio';
      case 'large':
        return 'Grande';
      default:
        return 'Médio';
    }
  }

  Future<void> _showFontSizeDialog(
    BuildContext context,
    UserPreferencesProvider provider,
  ) async {
    final fontSize = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Tamanho da Fonte'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'small'),
            child: const Text('Pequeno'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'medium'),
            child: const Text('Médio'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'large'),
            child: const Text('Grande'),
          ),
        ],
      ),
    );

    if (fontSize != null) {
      await provider.updateFontSize(fontSize);
    }
  }
}
