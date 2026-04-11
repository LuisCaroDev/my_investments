import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart'
    as domain;
import 'package:my_investments/core/domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final List<domain.OperationalTask> operationalTasks;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool confirmSwipeDelete;
  final bool confirmDelete;
  final bool showActionsOnTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.operationalTasks,
    this.onEdit,
    this.onDelete,
    this.confirmSwipeDelete = true,
    this.confirmDelete = true,
    this.showActionsOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final task = transaction.operationalTaskId != null
        ? operationalTasks
            .where((c) => c.id == transaction.operationalTaskId)
            .firstOrNull
        : null;
    final icon = isExpense ? RadixIcons.arrowDown : RadixIcons.arrowUp;
    final valueColor = isExpense
        ? theme.colorScheme.destructive
        : theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final label =
        transaction.description ??
        (isExpense ? l10n.dialog_tx_type_expense : l10n.dialog_tx_type_deposit);
    final sign = isExpense ? '-' : '+';

    Widget content = Card(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: valueColor),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label).small,
                if (task != null) ...[
                  const Gap(2),
                  Text(task.name).muted.xSmall,
                ],
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              ).muted.xSmall,
              Text(
                '$sign${transaction.amount.toCompactCurrency(context)}',
              ).small.semiBold(color: valueColor),
            ],
          ),
          if ((onEdit != null || onDelete != null) && !showActionsOnTap) ...[
            const Gap(6),
            IconButton.ghost(
              onPressed: () => _showActionsMenu(context, l10n),
              icon: const Icon(RadixIcons.dotsVertical, size: 16),
            ),
          ],
        ],
      ),
    );

    if (showActionsOnTap && (onEdit != null || onDelete != null)) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showActionsMenu(context, l10n),
        child: content,
      );
    }

    return Padding(padding: const EdgeInsets.only(bottom: 4), child: content);
  }

  void _showActionsMenu(BuildContext context, AppLocalizations l10n) {
    showDropdown<void>(
      context: context,
      anchorAlignment: Alignment.bottomRight,
      alignment: Alignment.topRight,
      builder: (ctx) => DropdownMenu(
        children: [
          if (onEdit != null)
            MenuButton(
              leading: const Icon(RadixIcons.pencil1),
              child: Text(l10n.common_edit),
              onPressed: (_) => onEdit?.call(),
            ),
          if (onDelete != null)
            MenuButton(
              leading: const Icon(RadixIcons.trash),
              child: Text(l10n.common_delete),
              onPressed: (_) => _handleMenuDelete(context, l10n),
            ),
        ],
      ),
    );
  }

  Future<void> _handleMenuDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    if (onDelete == null) return;
    if (confirmDelete) {
      final confirmed = await _confirmDelete(context, l10n);
      if (confirmed != true) return;
    }
    onDelete?.call();
  }

  Future<bool?> _confirmDelete(BuildContext context, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialog_tx_delete_title),
        content: Text(l10n.dialog_tx_delete_confirm),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.common_cancel),
          ),
          PrimaryButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }
}
