import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _medicamentoController = TextEditingController();
  bool _mostrarLocalAtual = false;
  String? _corredor;
  String? _setor;

  @override
  void dispose() {
    _medicamentoController.dispose();
    super.dispose();
  }

  void _salvarMedicamentoLocalmente() async {
    final nome = _medicamentoController.text.trim();
    if (nome.isEmpty || _corredor == null || _setor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Preencha o nome e ative a localização antes de salvar')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medicamento', nome);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Relatório de Localização do Medicamento',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Nome do Medicamento: $nome'),
              pw.Text('Corredor: $_corredor'),
              pw.Text('Setor: $_setor'),
              pw.Text('Data/Hora: ${DateTime.now()}'),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$nome-relatorio.pdf');
    await file.writeAsBytes(await pdf.save());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF salvo em: ${file.path}')),
    );
  }

  void _navegarParaRastreamento() {
    final nomeMedicamento = _medicamentoController.text.trim();
    if (nomeMedicamento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Digite o nome do medicamento para continuar.')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/rastreamento',
      arguments: nomeMedicamento,
    );
  }

  void _gerarLocalizacaoAleatoria() {
    final corredores = ['A1', 'B3', 'C2', 'D5', 'E4'];
    final setores = ['Farmácia', 'Emergência', 'UTI', 'Pediatria', 'Oncologia'];
    final random = Random();
    setState(() {
      _corredor = corredores[random.nextInt(corredores.length)];
      _setor = setores[random.nextInt(setores.length)];
    });
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
                        color: Colors.black.withAlpha(26),
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
                    fillColor: theme.colorScheme.surfaceContainerHighest,
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
                    if (_medicamentoController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Digite o nome do medicamento antes de mostrar a localização'),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _mostrarLocalAtual = val;
                    });
                    if (val) {
                      _gerarLocalizacaoAleatoria();
                    }
                  },
                  activeColor: theme.colorScheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                ),
                if (_mostrarLocalAtual && _corredor != null && _setor != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📍 Localização Atual do Medicamento:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Corredor: $_corredor'),
                          Text('Setor: $_setor'),
                        ],
                      ),
                    ),
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
