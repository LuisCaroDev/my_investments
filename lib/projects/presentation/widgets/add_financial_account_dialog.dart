import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/projects/domain/entities/financial_account.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_cubit.dart';

class AddFinancialAccountDialog extends StatefulWidget {
  final FinancialAccount? initialAccount;

  const AddFinancialAccountDialog({super.key, this.initialAccount});

  @override
  State<AddFinancialAccountDialog> createState() =>
      _AddFinancialAccountDialogState();
}

class _AddFinancialAccountDialogState extends State<AddFinancialAccountDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  FinancialAccountType _type = FinancialAccountType.bank;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialAccount?.name);
    _balanceController = TextEditingController(
      text: widget.initialAccount?.balance.toString() ?? '',
    );
    if (widget.initialAccount != null) {
      _type = widget.initialAccount!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.initialAccount != null;
    final title = isEditing ? 'Edit Account' : l10n.dialog_account_title;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.dialog_account_type).small.medium,
                const Gap(4),
                ButtonGroup(
                  children: [
                    SelectedButton(
                      value: _type == FinancialAccountType.bank,
                      style: const ButtonStyle.outline(),
                      selectedStyle: const ButtonStyle.primary(),
                      child: Text(l10n.dialog_account_type_bank),
                      onPressed: () =>
                          setState(() => _type = FinancialAccountType.bank),
                    ),
                    SelectedButton(
                      value: _type == FinancialAccountType.loan,
                      style: const ButtonStyle.outline(),
                      selectedStyle: const ButtonStyle.primary(),
                      child: Text(l10n.dialog_account_type_loan),
                      onPressed: () =>
                          setState(() => _type = FinancialAccountType.loan),
                    ),
                  ],
                ),
                const Gap(12),
                Text(l10n.dialog_account_name).small.medium,
                const Gap(4),
                TextField(
                  controller: _nameController,
                  placeholder: const Text('Checking, Saving...'),
                  autofocus: true,
                ),
                const Gap(12),
                Text(l10n.dialog_account_balance_label).small.medium,
                const Gap(4),
                TextField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  placeholder: const Text('0.00'),
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
              final name = _nameController.text.trim();
              final balance = double.tryParse(_balanceController.text) ?? 0.0;
              if (name.isEmpty) return;

              if (isEditing) {
                context.read<AccountsCubit>().updateAccount(
                  widget.initialAccount!.copyWith(
                    name: name,
                    balance: balance,
                    type: _type,
                  ),
                );
              } else {
                context.read<AccountsCubit>().addAccount(
                  FinancialAccount(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    balance: balance,
                    type: _type,
                    createdAt: DateTime.now(),
                  ),
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(l10n.common_save),
          ),
        ],
      ),
    );
  }
}
