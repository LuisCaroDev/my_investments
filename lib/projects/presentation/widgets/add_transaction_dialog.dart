import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/projects/domain/entities/category.dart' as domain;
import 'package:my_investments/projects/domain/entities/transaction.dart';

class AddTransactionDialog extends StatefulWidget {
  final List<domain.Category> availableCategories;
  final bool depositOnly;
  final Transaction? initialTransaction;

  const AddTransactionDialog({
    super.key,
    required this.availableCategories,
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
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = _type == TransactionType.deposit;
    final isEditing = widget.initialTransaction != null;
    return AlertDialog(
      title: Text(
        isEditing
            ? (isDeposit ? 'Editar Depósito' : 'Editar Gasto')
            : widget.depositOnly
                ? 'Nuevo Depósito'
                : isDeposit
                    ? 'Nuevo Depósito'
                    : 'Nuevo Gasto',
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.depositOnly) ...[
              const Text('Tipo').small.medium,
              const Gap(4),
              Row(
                children: [
                  Expanded(
                    child: _type == TransactionType.expense
                        ? PrimaryButton(
                            onPressed: () {},
                            child: const Text('Gasto'),
                          )
                        : OutlineButton(
                            onPressed: () => setState(
                                () => _type = TransactionType.expense),
                            child: const Text('Gasto'),
                          ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: _type == TransactionType.deposit
                        ? PrimaryButton(
                            onPressed: () {},
                            child: const Text('Depósito'),
                          )
                        : OutlineButton(
                            onPressed: () => setState(
                                () => _type = TransactionType.deposit),
                            child: const Text('Depósito'),
                          ),
                  ),
                ],
              ),
              const Gap(12),
            ],
            const Text('Monto').small.medium,
            const Gap(4),
            TextField(
              controller: _amountController,
              placeholder: const Text('0.00'),
              keyboardType: TextInputType.number,
            ),
            const Gap(12),
            const Text('Fecha').small.medium,
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
            const Text('Descripción (opcional)').small.medium,
            const Gap(4),
            TextField(
              controller: _descriptionController,
              placeholder: const Text('Detalle de la transacción...'),
            ),
            if (!isDeposit && widget.availableCategories.isNotEmpty) ...[
              const Gap(12),
              const Text('Categoría (opcional)').small.medium,
              const Gap(4),
              _buildCategorySelector(),
            ],
          ],
        ),
      ),
      actions: [
        OutlineButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
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
              'categoryId': isDeposit ? null : _selectedCategoryId,
            });
          },
          child: Text(isEditing ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final selectedCategory = _selectedCategoryId != null
        ? widget.availableCategories
            .where((c) => c.id == _selectedCategoryId)
            .firstOrNull
        : null;

    return OutlineButton(
      onPressed: () => _showCategoryPicker(),
      child: Row(
        children: [
          Expanded(
            child: selectedCategory != null
                ? Text(
                    selectedCategory.activityId == null
                        ? '${selectedCategory.name} (proyecto)'
                        : selectedCategory.name,
                  )
                : const Text('Seleccionar categoría').muted,
          ),
          const Icon(RadixIcons.chevronDown, size: 14),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    final activityCategories = widget.availableCategories
        .where((c) => c.activityId != null)
        .toList();
    final projectCategories = widget.availableCategories
        .where((c) => c.activityId == null)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar Categoría'),
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
                child: const Row(
                  children: [
                    Expanded(child: Text('Sin categoría')),
                  ],
                ),
              ),
              if (activityCategories.isNotEmpty) ...[
                const Gap(8),
                const Text('Actividad').small.medium,
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
                const Text('Proyecto').small.medium,
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
