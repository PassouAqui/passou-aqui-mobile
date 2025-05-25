import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drug_provider.dart';
import '../../domain/entities/drug.dart';

class DrugsPage extends StatefulWidget {
  const DrugsPage({super.key});

  @override
  State<DrugsPage> createState() => _DrugsPageState();
}

class _DrugsPageState extends State<DrugsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() async {
      if (!mounted) return;
      Provider.of<DrugProvider>(context, listen: false).loadDrugs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<DrugProvider>(context, listen: false).loadDrugs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final drugProvider = Provider.of<DrugProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: drugProvider.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Card com o total de medicamentos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.medication_outlined,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total de Medicamentos',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          drugProvider.totalCount.toString(),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Lista de medicamentos
            if (drugProvider.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        drugProvider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: drugProvider.refresh,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (drugProvider.drugs.isEmpty && !drugProvider.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Text('Nenhum medicamento encontrado'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == drugProvider.drugs.length) {
                        if (drugProvider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (drugProvider.hasMore) {
                          return const SizedBox.shrink();
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                          ),
                        );
                      }

                      final drug = drugProvider.drugs[index];
                      return DrugCard(drug: drug);
                    },
                    childCount: drugProvider.drugs.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DrugCard extends StatelessWidget {
  final Drug drug;

  const DrugCard({
    super.key,
    required this.drug,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    drug.nome,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: drug.ativo ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    drug.ativo ? 'Ativo' : 'Inativo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              drug.descricao,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.tag,
                  label: 'Tag: ${drug.tagUid}',
                ),
                _InfoChip(
                  icon: Icons.inventory,
                  label: 'Lote: ${drug.lote}',
                ),
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: 'Validade: ${_formatDate(drug.validade)}',
                ),
                _InfoChip(
                  icon: Icons.label,
                  label: 'Tarja: ${drug.tarja}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
