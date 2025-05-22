import 'package:flutter/material.dart';
import 'dart:math';

class TelaRastreamento extends StatelessWidget {
  const TelaRastreamento({super.key});

  List<Map<String, String>> _gerarHistorico(String medicamento) {
    final corredores = ['A1', 'B2', 'C3', 'D4'];
    final andares = ['1º andar', '2º andar', '3º andar', 'Subsolo'];
    final horarios = ['08:15', '09:30', '11:05', '13:20', '15:45'];

    final random = Random();
    return List.generate(4, (index) {
      return {
        'corredor': corredores[random.nextInt(corredores.length)],
        'andar': andares[random.nextInt(andares.length)],
        'horario': horarios[random.nextInt(horarios.length)],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicamento = ModalRoute.of(context)!.settings.arguments as String;
    final historico = _gerarHistorico(medicamento);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rastreamento: $medicamento'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: historico.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = historico[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.local_hospital_outlined),
                title: Text('Corredor ${item['corredor']} - ${item['andar']}'),
                subtitle: Text('Horário: ${item['horario']}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
