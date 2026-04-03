import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AddCategoryDialog extends StatefulWidget {
  final bool isProjectLevel;
  final String? initialName;

  const AddCategoryDialog({
    super.key,
    this.isProjectLevel = false,
    this.initialName,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.isProjectLevel
          ? (isEditing
              ? l10n.dialog_category_edit_project_title
              : l10n.dialog_category_new_project_title)
          : (isEditing ? l10n.dialog_category_edit_title : l10n.dialog_category_new_title)),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.common_name_label).small.medium,
            const Gap(4),
            TextField(
              controller: _nameController,
              placeholder: Text(l10n.dialog_category_name_placeholder),
            ),
            if (widget.isProjectLevel) ...[
              const Gap(8),
              Text(
                l10n.dialog_category_project_info,
              ).muted.small,
            ],
          ],
        ),
      ),
      actions: [
        OutlineButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        PrimaryButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(name);
          },
          child: Text(isEditing ? l10n.common_save : l10n.common_create),
        ),
      ],
    );
  }
}
