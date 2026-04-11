import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart'
    as domain;

class OperationalTaskTile extends StatelessWidget {
  final domain.OperationalTask task;
  final String? subtitle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OperationalTaskTile({
    super.key,
    required this.task,
    this.subtitle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Widget content = Card(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            RadixIcons.bookmark,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const Gap(10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(task.name).small,
                if (subtitle != null)
                  Text(subtitle!).muted.xSmall,
              ],
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const Gap(6),
            IconButton.ghost(
              onPressed: () => _showActionsMenu(context, l10n),
              icon: const Icon(RadixIcons.dotsVertical, size: 16),
            ),
          ],
        ],
      ),
    );

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
              onPressed: (_) => onDelete?.call(),
            ),
        ],
      ),
    );
  }
}
