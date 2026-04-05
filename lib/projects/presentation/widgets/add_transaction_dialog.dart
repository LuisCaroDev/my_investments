import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/projects/domain/entities/category.dart'
    as domain;
import 'package:my_investments/projects/domain/entities/financial_account.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';

class AddTransactionDialog extends StatefulWidget {
  final List<domain.Category> availableCategories;
  final List<FinancialAccount> availableAccounts;
  final bool depositOnly;
  final Transaction? initialTransaction;

  const AddTransactionDialog({
    super.key,
    required this.availableCategories,
    required this.availableAccounts,
    this.depositOnly = false,
    this.initialTransaction,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late TransactionType _type;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _type =
        widget.initialTransaction?.type ??
        (widget.depositOnly
            ? TransactionType.deposit
            : TransactionType.expense);
    _amountController = TextEditingController(
      text: widget.initialTransaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialTransaction?.description ?? '',
    );
    _selectedDate = widget.initialTransaction?.date ?? DateTime.now();
    _selectedCategoryId = widget.initialTransaction?.categoryId;
    final initialAccountId = widget.initialTransaction?.accountId;
    if (initialAccountId != null &&
        widget.availableAccounts.any((a) => a.id == initialAccountId)) {
      _selectedAccountId = initialAccountId;
    } else if (widget.availableAccounts.isNotEmpty) {
      _selectedAccountId = widget.availableAccounts.first.id;
    } else {
      _selectedAccountId = 'initial_statement';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;
    final isEditing = widget.initialTransaction != null;
    final l10n = AppLocalizations.of(context)!;

    final title = isEditing
        ? isExpense
              ? l10n.dialog_tx_edit_expense
              : l10n.dialog_tx_edit_deposit
        : widget.depositOnly
        ? l10n.dialog_tx_new_deposit
        : isExpense
        ? l10n.dialog_tx_new_expense
        : l10n.dialog_tx_new_deposit;
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.depositOnly) ...[
              Text(l10n.dialog_tx_type_label).small.medium,
              const Gap(4),
              FittedBox(
                child: ButtonGroup(
                  children: [
                    _type == TransactionType.expense
                        ? PrimaryButton(
                            onPressed: () {},
                            child: Text(l10n.dialog_tx_type_expense),
                          )
                        : OutlineButton(
                            onPressed: () =>
                                setState(() => _type = TransactionType.expense),
                            child: Text(l10n.dialog_tx_type_expense),
                          ),
                    _type == TransactionType.deposit
                        ? PrimaryButton(
                            onPressed: () {},
                            child: Text(l10n.dialog_tx_type_deposit),
                          )
                        : OutlineButton(
                            onPressed: () =>
                                setState(() => _type = TransactionType.deposit),
                            child: Text(l10n.dialog_tx_type_deposit),
                          ),

                  ],
                ),
              ),
              const Gap(12),
            ],
            Text(l10n.dialog_tx_account_select).small.medium,
            const Gap(4),
            _buildAccountSelector(l10n),
            const Gap(12),
            Text(l10n.dialog_tx_amount_label).small.medium,
            const Gap(4),
            TextField(
              controller: _amountController,
              placeholder: const Text('0.00'),
              keyboardType: TextInputType.number,
            ),
            const Gap(12),
            Text(l10n.dialog_tx_date_label).small.medium,
            const Gap(4),
            DatePicker(
              value: _selectedDate,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDate = value);
                }
              },
              mode: PromptMode.dialog,
            ),
            const Gap(12),
            Text(l10n.common_description_label).small.medium,
            const Gap(4),
            TextField(
              controller: _descriptionController,
              placeholder: Text(l10n.dialog_tx_description_placeholder),
            ),
            if (isExpense && widget.availableCategories.isNotEmpty) ...[
              const Gap(12),
              Text(l10n.dialog_tx_category_label).small.medium,
              const Gap(4),
              _buildCategorySelector(l10n),
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
            final amount = double.tryParse(_amountController.text.trim());
            if (amount == null || amount <= 0) return;
            final description = _descriptionController.text.trim();
            Navigator.of(context).pop({
              'type': _type,
              'amount': amount,
              'date': _selectedDate,
              'description': description.isEmpty ? null : description,
              'categoryId': isExpense ? _selectedCategoryId : null,
              'accountId': _selectedAccountId,
            });
          },
          child: Text(isEditing ? l10n.common_save : l10n.common_add),
        ),
      ],
    );
  }

  Widget _buildAccountSelector(AppLocalizations l10n) {
    final accounts = widget.availableAccounts;
    final selected = _selectedAccountId != null
        ? accounts.where((a) => a.id == _selectedAccountId).firstOrNull
        : null;

    return OutlineButton(
      onPressed: accounts.isEmpty ? null : () => _showAccountPicker(l10n),
      child: Row(
        children: [
          Expanded(
            child: selected != null
                ? Text(selected.name)
                : Text('Initial Statement').muted,
          ),
          const Icon(RadixIcons.chevronDown, size: 14),
        ],
      ),
    );
  }

  void _showAccountPicker(AppLocalizations l10n) {
    final accounts = widget.availableAccounts;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialog_tx_account_select),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...accounts.map(
                (acc) => GhostButton(
                  onPressed: () {
                    setState(() => _selectedAccountId = acc.id);
                    Navigator.of(ctx).pop();
                  },
                  child: Row(
                    children: [
                      Expanded(child: Text(acc.name)),
                      if (_selectedAccountId == acc.id)
                        const Icon(RadixIcons.check, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(AppLocalizations l10n) {
    final selectedCategory = _selectedCategoryId != null
        ? widget.availableCategories
              .where((c) => c.id == _selectedCategoryId)
              .firstOrNull
        : null;

    return OutlineButton(
      onPressed: () => _showCategoryPicker(l10n),
      child: Row(
        children: [
          Expanded(
            child: selectedCategory != null
                ? Text(
                    selectedCategory.activityId == null
                        ? '${selectedCategory.name} ${l10n.widget_tx_tile_project_label}'
                        : selectedCategory.name,
                  )
                : Text(l10n.dialog_tx_category_select).muted,
          ),
          const Icon(RadixIcons.chevronDown, size: 14),
        ],
      ),
    );
  }

  void _showCategoryPicker(AppLocalizations l10n) {
    final activityCategories = widget.availableCategories
        .where((c) => c.activityId != null)
        .toList();
    final projectCategories = widget.availableCategories
        .where((c) => c.activityId == null)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialog_tx_category_select),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // None option
              GhostButton(
                onPressed: () {
                  setState(() => _selectedCategoryId = null);
                  Navigator.of(ctx).pop();
                },
                child: Row(
                  children: [
                    Expanded(child: Text(l10n.dialog_tx_category_none)),
                  ],
                ),
              ),
              if (activityCategories.isNotEmpty) ...[
                const Gap(8),
                Text(l10n.common_activity).small.medium,
                const Gap(4),
                ...activityCategories.map(
                  (cat) => GhostButton(
                    onPressed: () {
                      setState(() => _selectedCategoryId = cat.id);
                      Navigator.of(ctx).pop();
                    },
                    child: Row(
                      children: [
                        Expanded(child: Text(cat.name)),
                        if (_selectedCategoryId == cat.id)
                          const Icon(RadixIcons.check, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
              if (projectCategories.isNotEmpty) ...[
                const Gap(8),
                Text(l10n.common_project).small.medium,
                const Gap(4),
                ...projectCategories.map(
                  (cat) => GhostButton(
                    onPressed: () {
                      setState(() => _selectedCategoryId = cat.id);
                      Navigator.of(ctx).pop();
                    },
                    child: Row(
                      children: [
                        Expanded(child: Text(cat.name)),
                        if (_selectedCategoryId == cat.id)
                          const Icon(RadixIcons.check, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
