import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';

/// Button that saves the current entity as a new template.
class SaveAsTemplateButton extends StatelessWidget {
  final Entity entity;

  const SaveAsTemplateButton({super.key, required this.entity});

  Future<void> _saveAsTemplate(BuildContext context) async {
    final nameComponent = entity.get<Name>();
    final defaultName = nameComponent?.name ?? 'New Template';

    final templateName = await showDialog<String>(
      context: context,
      builder: (context) => TemplateNameDialog(defaultName: defaultName),
    );

    if (templateName == null || templateName.isEmpty) return;

    final template = EntityTemplate.fromEntity(
      id: TemplateRegistry.instance.generateId(),
      displayName: templateName,
      entity: entity,
    );

    await TemplateRegistry.instance.save(template);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved template "$templateName"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Save as Template',
      child: InkWell(
        onTap: () => _saveAsTemplate(context),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.copy,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Dialog for entering the template name when saving.
class TemplateNameDialog extends StatefulWidget {
  final String defaultName;

  const TemplateNameDialog({super.key, required this.defaultName});

  @override
  State<TemplateNameDialog> createState() => _TemplateNameDialogState();
}

class _TemplateNameDialogState extends State<TemplateNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.defaultName.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save as Template'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Template Name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
