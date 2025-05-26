import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final bool isLoading;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Function(int) onPageSelected;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.isLoading,
    this.onNext,
    this.onPrevious,
    required this.onPageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildPageButton(int page) {
      final isCurrentPage = page == currentPage;
      return InkWell(
        onTap: isLoading ? null : () => onPageSelected(page),
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isCurrentPage ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPage ? colorScheme.primary : colorScheme.outline,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '$page',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isCurrentPage
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    List<Widget> buildPageNumbers() {
      final pages = <Widget>[];
      const maxVisiblePages = 5;

      if (totalPages <= maxVisiblePages) {
        // Mostra todas as páginas se o total for menor que maxVisiblePages
        for (var i = 1; i <= totalPages; i++) {
          pages.add(buildPageButton(i));
        }
      } else {
        // Lógica para mostrar páginas com elipses
        if (currentPage <= 3) {
          // Páginas iniciais
          for (var i = 1; i <= 4; i++) {
            pages.add(buildPageButton(i));
          }
          pages.add(const Text('...'));
          pages.add(buildPageButton(totalPages));
        } else if (currentPage >= totalPages - 2) {
          // Páginas finais
          pages.add(buildPageButton(1));
          pages.add(const Text('...'));
          for (var i = totalPages - 3; i <= totalPages; i++) {
            pages.add(buildPageButton(i));
          }
        } else {
          // Páginas do meio
          pages.add(buildPageButton(1));
          pages.add(const Text('...'));
          for (var i = currentPage - 1; i <= currentPage + 1; i++) {
            pages.add(buildPageButton(i));
          }
          pages.add(const Text('...'));
          pages.add(buildPageButton(totalPages));
        }
      }

      return pages;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: hasPrevious && !isLoading ? onPrevious : null,
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colorScheme.outline),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ...buildPageNumbers(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: hasNext && !isLoading ? onNext : null,
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colorScheme.outline),
              ),
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
