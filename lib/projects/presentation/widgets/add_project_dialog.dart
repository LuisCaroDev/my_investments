import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AddProjectDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final double? initialBudget;

  const AddProjectDialog({
    super.key,
    this.initialName,
    this.initialDescription,
    this.initialBudget,
  });

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _budgetController = TextEditingController(
      text: widget.initialBudget?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(isEditing ? l10n.dialog_project_edit_title : l10n.dialog_project_new_title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.common_name_label).small.medium,
            const Gap(4),
            TextField(
              controller: _nameController,
              placeholder: Text(l10n.dialog_project_name_placeholder),
            ),
            const Gap(12),
            Text(l10n.common_description_label).small.medium,
            const Gap(4),
            TextField(
              controller: _descriptionController,
              placeholder: Text(l10n.dialog_project_description_placeholder),
              maxLines: 3,
            ),
            const Gap(12),
            Text(l10n.dialog_project_budget_label).small.medium,
            const Gap(4),
            TextField(
              controller: _budgetController,
              placeholder: const Text('0.00'),
              keyboardType: TextInputType.number,
            ),
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
            final budget = double.tryParse(_budgetController.text.trim());
            final description = _descriptionController.text.trim();
            Navigator.of(context).pop({
              'name': name,
              'description': description.isEmpty ? null : description,
              'budget': budget,
            });
          },
          child: Text(isEditing ? l10n.common_save : l10n.common_create),
        ),
      ],
    );
  }
}
