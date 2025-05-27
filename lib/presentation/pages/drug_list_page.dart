import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passou_aqui_mobile/domain/entities/drug.dart';
import 'package:passou_aqui_mobile/presentation/providers/drug_provider.dart';
import 'package:passou_aqui_mobile/presentation/widgets/drug_form.dart';
import 'package:passou_aqui_mobile/presentation/widgets/pagination_controls.dart';
import 'package:passou_aqui_mobile/presentation/widgets/drug_filter.dart';
import 'package:passou_aqui_mobile/presentation/pages/drug_detail_page.dart';

class DrugListPage extends StatefulWidget {
  const DrugListPage({super.key});

  @override
  State<DrugListPage> createState() => _DrugListPageState();
}

class _DrugListPageState extends State<DrugListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDrugs();
    });
  }

  Future<void> _loadDrugs({bool refresh = false}) async {
    await Provider.of<DrugProvider>(context, listen: false)
        .loadDrugs(refresh: refresh);
  }

  Future<void> _showDrugForm(BuildContext context, [Drug? drug]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DrugForm(
          drug: drug,
          isEditing: drug != null,
        ),
      ),
    );
    _loadDrugs();
  }

  void _showDrugDetails(Drug drug) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrugDetailPage(
          drug: drug,
          onDrugUpdated: () => _loadDrugs(refresh: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<DrugProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Lista',
            onPressed: () => _loadDrugs(refresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Medicamento',
            onPressed: () => _showDrugForm(context),
          ),
        ],
      ),
      body: Column(
        children: [
          DrugFilter(
            onSearchChanged: provider.setSearchQuery,
            onActiveFilterChanged: provider.setActiveFilter,
            onTarjaFilterChanged: provider.setTarjaFilter,
            onClearFilters: provider.clearFilters,
            showOnlyActive: provider.showOnlyActive,
            selectedTarja: provider.selectedTarja,
            searchQuery: provider.searchQuery,
          ),
          Expanded(
            child: provider.isLoading && provider.drugs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.drugs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum medicamento encontrado',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadDrugs(refresh: true),
                        child: ListView.builder(
                          itemCount: provider.drugs.length,
                          itemBuilder: (context, index) {
                            final drug = provider.drugs[index];
                            return Dismissible(
                              key: Key(drug.id),
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  // Deslizar para esquerda - Editar
                                  await _showDrugForm(context, drug);
                                  return false; // Não remove o item pois é edição
                                } else {
                                  // Deslizar para direita - Desativar/Ativar
                                  if (drug.ativo) {
                                    final shouldDismiss =
                                        await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Desativar Medicamento'),
                                                content: const Text(
                                                    'Tem certeza que deseja desativar este medicamento?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child:
                                                        const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child:
                                                        const Text('Desativar'),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                            false;

                                    if (shouldDismiss) {
                                      await provider.toggleDrugStatus(
                                          drug.id, false);
                                      await _loadDrugs(refresh: true);
                                    }
                                    return shouldDismiss;
                                  } else {
                                    final shouldDismiss =
                                        await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Ativar Medicamento'),
                                                content: const Text(
                                                    'Tem certeza que deseja ativar este medicamento?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child:
                                                        const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child: const Text('Ativar'),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                            false;

                                    if (shouldDismiss) {
                                      await provider.toggleDrugStatus(
                                          drug.id, true);
                                      await _loadDrugs(refresh: true);
                                    }
                                    return shouldDismiss;
                                  }
                                }
                              },
                              background: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: drug.ativo ? Colors.red : Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 16),
                                child: Icon(
                                  drug.ativo
                                      ? Icons.delete_outline
                                      : Icons.restore,
                                  color: Colors.white,
                                ),
                              ),
                              secondaryBackground: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) {
                                // Não precisamos fazer nada aqui pois a ação já foi executada no confirmDismiss
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: InkWell(
                                  onTap: () => _showDrugDetails(drug),
                                  child: ListTile(
                                    title: Text(
                                      drug.nome,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: drug.ativo
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurface
                                                .withAlpha(128),
                                      ),
                                    ),
                                    subtitle: Text('Lote: ${drug.lote}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: drug.ativo
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            drug.ativo ? 'Ativo' : 'Inativo',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right,
                                          color: theme.colorScheme.onSurface
                                              .withAlpha(128),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          if (provider.drugs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: PaginationControls(
                currentPage: provider.currentPage,
                totalPages: provider.totalPages,
                hasNext: provider.hasNext,
                hasPrevious: provider.hasPrevious,
                isLoading: provider.isLoading,
                onNext: provider.hasNext
                    ? () => provider.loadDrugs(page: provider.currentPage + 1)
                    : null,
                onPrevious: provider.hasPrevious
                    ? () => provider.loadDrugs(page: provider.currentPage - 1)
                    : null,
                onPageSelected: (page) => provider.loadDrugs(page: page),
              ),
            ),
        ],
      ),
    );
  }
}
