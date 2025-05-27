import 'package:flutter/material.dart';
import '../../domain/entities/drug.dart';

class DrugDetailPage extends StatelessWidget {
  final Drug drug;
  final VoidCallback? onDrugUpdated;

  const DrugDetailPage({
    super.key,
    required this.drug,
    this.onDrugUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(drug.nome),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            drug.nome,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: drug.ativo ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            drug.ativo ? 'Ativo' : 'Inativo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.tag,
                      label: 'Tag',
                      value: drug.tagUid,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.inventory,
                      label: 'Lote',
                      value: drug.lote,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Validade',
                      value: _formatDate(drug.validade),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.label,
                      label: 'Tarja',
                      value: drug.tarja.label,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
