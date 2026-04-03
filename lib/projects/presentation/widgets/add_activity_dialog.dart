import 'package:shadcn_flutter/shadcn_flutter.dart';

class AddActivityDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final int? initialYear;
  final double? initialBudget;

  const AddActivityDialog({
    super.key,
    this.initialName,
    this.initialDescription,
    this.initialYear,
    this.initialBudget,
  });

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _yearController;
  late final TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _yearController = TextEditingController(
      text: widget.initialYear?.toString() ??
          DateTime.now().year.toString(),
    );
    _budgetController = TextEditingController(
      text: widget.initialBudget?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Actividad' : 'Nueva Actividad'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nombre').small.medium,
            const Gap(4),
            TextField(
              controller: _nameController,
              placeholder: const Text('Ej: Siembra 2025'),
            ),
            const Gap(12),
            const Text('Descripción (opcional)').small.medium,
            const Gap(4),
            TextField(
              controller: _descriptionController,
              placeholder: const Text('Describe la actividad...'),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Año').small.medium,
                      const Gap(4),
                      TextField(
                        controller: _yearController,
                        placeholder: const Text('2025'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Presupuesto').small.medium,
                      const Gap(4),
                      TextField(
                        controller: _budgetController,
                        placeholder: const Text('0.00'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            final budget = double.tryParse(_budgetController.text.trim());
            final year = int.tryParse(_yearController.text.trim());
            final description = _descriptionController.text.trim();
            Navigator.of(context).pop({
              'name': name,
              'description': description.isEmpty ? null : description,
              'year': year,
              'budget': budget,
            });
          },
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
