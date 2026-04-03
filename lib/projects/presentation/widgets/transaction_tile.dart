import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:my_investments/projects/domain/entities/category.dart'
    as domain;
import 'package:my_investments/projects/domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final List<domain.Category> categories;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool confirmSwipeDelete;
  final bool confirmDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.categories,
    this.onEdit,
    this.onDelete,
    this.confirmSwipeDelete = true,
    this.confirmDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final category = transaction.categoryId != null
        ? categories.where((c) => c.id == transaction.categoryId).firstOrNull
        : null;

    Widget content = Card(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            isExpense ? RadixIcons.arrowDown : RadixIcons.arrowUp,
            size: 14,
            color: isExpense
                ? theme.colorScheme.destructive
                : theme.colorScheme.primary,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? (isExpense ? 'Gasto' : 'Depósito'),
                ).small,
                Row(
                  children: [
                    Text(
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                    ).muted.xSmall,
                    if (category != null) ...[
                      const Gap(6),
                      Text('• ${category.name}').muted.xSmall,
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${transaction.amount.toCompactCurrency()}',
          ).small.semiBold(
            color: isExpense
                ? theme.colorScheme.destructive
                : theme.colorScheme.primary,
          ),
          if (onEdit != null || onDelete != null) ...[
            const Gap(6),
            IconButton.ghost(
              onPressed: () => _showActionsMenu(context),
              icon: Icon(RadixIcons.dotsVertical, size: 16),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: content,
    );
  }

  void _showActionsMenu(BuildContext context) {
    showDropdown<void>(
      context: context,
      anchorAlignment: Alignment.bottomRight,
      alignment: Alignment.topRight,
      builder: (ctx) => DropdownMenu(
        children: [
          if (onEdit != null)
            MenuButton(
              leading: const Icon(RadixIcons.pencil1),
              child: const Text('Editar'),
              onPressed: (_) => onEdit?.call(),
            ),
          if (onDelete != null)
            MenuButton(
              leading: const Icon(RadixIcons.trash),
              child: const Text('Eliminar'),
              onPressed: (_) => _handleMenuDelete(context),
            ),
        ],
      ),
    );
  }

  Future<void> _handleMenuDelete(BuildContext context) async {
    if (onDelete == null) return;
    if (confirmDelete) {
      final confirmed = await _confirmDelete(context);
      if (confirmed != true) return;
    }
    onDelete?.call();
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text(
          '¿Seguro que quieres eliminar esta transacción?',
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
