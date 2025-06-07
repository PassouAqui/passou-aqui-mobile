import 'package:flutter/material.dart';
import 'package:passou_aqui_mobile/domain/entities/drug.dart';

class DrugFilter extends StatelessWidget {
  final bool showOnlyActive;
  final Tarja? selectedTarja;
  final String searchQuery;
  final Function(bool) onActiveFilterChanged;
  final Function(Tarja?) onTarjaFilterChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onClearFilters;

  const DrugFilter({
    super.key,
    required this.showOnlyActive,
    required this.selectedTarja,
    required this.searchQuery,
    required this.onActiveFilterChanged,
    required this.onTarjaFilterChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de busca
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar medicamentos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(77),
            ),
          ),
          const SizedBox(height: 16),

          // Filtros
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Filtro de Status
              FilterChip(
                label: const Text('Ativos'),
                selected: showOnlyActive,
                onSelected: onActiveFilterChanged,
                avatar: Icon(
                  showOnlyActive ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                ),
              ),

              // Filtro de Tarja
              PopupMenuButton<Tarja?>(
                tooltip: 'Filtrar por tarja',
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('Todas as tarjas'),
                  ),
                  ...Tarja.values.map((tarja) => PopupMenuItem(
                        value: tarja,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getTarjaColor(tarja),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(tarja.label),
                          ],
                        ),
                      )),
                ],
                onSelected: onTarjaFilterChanged,
                child: Chip(
                  avatar: Icon(
                    Icons.filter_list,
                    size: 18,
                    color: selectedTarja != null
                        ? _getTarjaColor(selectedTarja!)
                        : null,
                  ),
                  label: Text(selectedTarja?.label ?? 'Todas as tarjas'),
                ),
              ),

              // Botão limpar filtros
              if (searchQuery.isNotEmpty ||
                  selectedTarja != null ||
                  !showOnlyActive)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar filtros'),
                ),
            ],
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
