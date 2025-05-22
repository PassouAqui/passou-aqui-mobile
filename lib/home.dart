import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _medicamentoController = TextEditingController();
  bool _mostrarLocalAtual = false;

  void _salvarMedicamentoLocalmente() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medicamento', _medicamentoController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medicamento salvo localmente')),
    );
  }

  void _navegarParaRastreamento() {
  final nomeMedicamento = _medicamentoController.text.trim();

  if (nomeMedicamento.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Digite o nome do medicamento para continuar.')),
    );
    return;
  }

  Navigator.pushNamed(
    context,
    '/rastreamento',
    arguments: nomeMedicamento,
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rastreamento de Medicamentos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  height: screenWidth < 400 ? 180 : 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/hospital.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verifique o percurso do medicamento dentro do hospital.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _medicamentoController,
                  decoration: InputDecoration(
                    labelText: 'Nome ou Código do Medicamento',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.medical_information_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                SwitchListTile.adaptive(
                  title: const Text('Mostrar localização atual do remédio'),
                  value: _mostrarLocalAtual,
                  onChanged: (val) {
                    setState(() {
                      _mostrarLocalAtual = val;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _salvarMedicamentoLocalmente,
                        icon: const Icon(Icons.save_alt_outlined),
                        label: const Text('Salvar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _navegarParaRastreamento,
                        icon: const Icon(Icons.route_outlined),
                        label: const Text('Rastrear'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
