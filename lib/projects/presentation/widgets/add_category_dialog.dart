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
    return AlertDialog(
      title: Text(widget.isProjectLevel
          ? (isEditing
              ? 'Editar Categoría de Proyecto'
              : 'Nueva Categoría de Proyecto')
          : (isEditing ? 'Editar Categoría' : 'Nueva Categoría')),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nombre').small.medium,
            const Gap(4),
            TextField(
              controller: _nameController,
              placeholder: const Text('Ej: Compra de palma'),
            ),
            if (widget.isProjectLevel) ...[
              const Gap(8),
              const Text(
                'Esta categoría estará disponible en todas las actividades del proyecto.',
              ).muted.small,
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
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(name);
          },
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
