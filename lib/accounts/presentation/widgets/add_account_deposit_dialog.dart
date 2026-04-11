import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AddAccountDepositDialog extends StatefulWidget {
  final double? initialAmount;
  final String? initialDescription;

  const AddAccountDepositDialog({
    super.key,
    this.initialAmount,
    this.initialDescription,
  });

  @override
  State<AddAccountDepositDialog> createState() =>
      _AddAccountDepositDialogState();
}

class _AddAccountDepositDialogState extends State<AddAccountDepositDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.initialAmount != null || widget.initialDescription != null;
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: AlertDialog(
        title: Text(
          isEditing ? l10n.dialog_tx_edit_deposit : l10n.dialog_tx_new_deposit,
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.dialog_tx_amount_label).small.medium,
                const Gap(4),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  placeholder: const Text('0.00'),
                  autofocus: true,
                ),
                const Gap(12),
                Text(l10n.common_description_label).small.medium,
                const Gap(4),
                TextField(
                  controller: _descriptionController,
                  placeholder: Text(l10n.dialog_tx_description_placeholder),
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_cancel),
          ),
          PrimaryButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text.trim());
              if (amount == null || amount <= 0) return;
              final description = _descriptionController.text.trim();
              Navigator.of(context).pop({
                'amount': amount,
                'description': description.isEmpty ? null : description,
              });
            },
            child: Text(isEditing ? l10n.common_save : l10n.common_add),
          ),
        ],
      ),
    );
  }
}
