import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passou_aqui_mobile/domain/entities/drug.dart';
import 'package:passou_aqui_mobile/presentation/providers/drug_provider.dart';
import 'package:passou_aqui_mobile/presentation/widgets/drug_form.dart';
import 'package:passou_aqui_mobile/presentation/pages/drug_detail_page.dart';

class DrugListPage extends StatefulWidget {
  const DrugListPage({super.key});

  @override
  State<DrugListPage> createState() => _DrugListPageState();
}

class _DrugListPageState extends State<DrugListPage> {
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDrugs();
    });
  }

  Future<void> _loadDrugs() async {
    await Provider.of<DrugProvider>(context, listen: false)
        .loadDrugs(active: _showOnlyActive);
  }

  Future<bool> _showDeleteConfirmation(Drug drug) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o medicamento "${drug.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await Provider.of<DrugProvider>(context, listen: false)
            .deleteDrug(drug.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medicamento excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir medicamento: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }
    return false;
  }

  Future<void> _showDrugForm({Drug? drug}) async {
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrugDetailPage(drug: drug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drugProvider = Provider.of<DrugProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
        actions: [
          IconButton(
            icon: Icon(
                _showOnlyActive ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showOnlyActive = !_showOnlyActive;
              });
              _loadDrugs();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrugs,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDrugForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total de Medicamentos: ${drugProvider.drugs.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Ativos: ${drugProvider.drugs.where((d) => d.ativo).length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: drugProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : drugProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Erro ao carregar medicamentos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDrugs,
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : drugProvider.drugs.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhum medicamento encontrado',
                              style: theme.textTheme.titleMedium,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDrugs,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: drugProvider.drugs.length,
                              itemBuilder: (context, index) {
                                final drug = drugProvider.drugs[index];
                                return Dismissible(
                                  key: Key(drug.id),
                                  direction: DismissDirection.horizontal,
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      return await _showDeleteConfirmation(
                                          drug);
                                    }
                                    return true;
                                  },
                                  onDismissed: (direction) {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      _showDrugForm(drug: drug);
                                    }
                                  },
                                  background: Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    color: theme.colorScheme.primary,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Editar',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  secondaryBackground: Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    color: Colors.red,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Excluir',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: _getTarjaColor(drug.tarja),
                                        width: 0.5,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          width: 0.5,
                                          child: Container(
                                            color: _getTarjaColor(drug.tarja),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _showDrugDetails(drug),
                                          child: ListTile(
                                            title: Text(
                                              drug.nome,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                color: drug.ativo
                                                    ? theme
                                                        .colorScheme.onSurface
                                                    : theme
                                                        .colorScheme.onSurface
                                                        .withAlpha(128),
                                              ),
                                            ),
                                            subtitle:
                                                Text('Lote: ${drug.lote}'),
                                            trailing: IconButton(
                                              icon: Icon(
                                                drug.ativo
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                Provider.of<DrugProvider>(
                                                        context,
                                                        listen: false)
                                                    .toggleDrugStatus(
                                                        drug.id, !drug.ativo);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Color _getTarjaColor(Tarja tarja) {
    switch (tarja) {
      case Tarja.semTarja:
        return Colors.green;
      case Tarja.amarela:
        return Colors.amber;
      case Tarja.vermelha:
        return Colors.red;
      case Tarja.preta:
        return Colors.black;
    }
  }
}
