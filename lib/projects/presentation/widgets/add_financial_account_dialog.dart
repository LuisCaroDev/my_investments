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

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.dialog_account_type).small.medium,
            const Gap(4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _type == FinancialAccountType.bank
                      ? PrimaryButton(
                          onPressed: () {},
                          child: Text(l10n.dialog_account_type_bank),
                        )
                      : OutlineButton(
                          onPressed: () => setState(
                              () => _type = FinancialAccountType.bank),
                          child: Text(l10n.dialog_account_type_bank),
                        ),
                  const Gap(8),
                  _type == FinancialAccountType.loan
                      ? PrimaryButton(
                          onPressed: () {},
                          child: Text(l10n.dialog_account_type_loan),
                        )
                      : OutlineButton(
                          onPressed: () => setState(
                              () => _type = FinancialAccountType.loan),
                          child: Text(l10n.dialog_account_type_loan),
                        ),
                ],
              ),
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
    );
  }
}
