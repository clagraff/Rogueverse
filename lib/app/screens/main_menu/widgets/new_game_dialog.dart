import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/persistence.dart';

/// Dialog for creating a new game save.
class NewGameDialog extends StatefulWidget {
  const NewGameDialog({super.key});

  /// Shows the dialog and returns the save path if created, null if cancelled.
  static Future<String?> show(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => const NewGameDialog(),
    );
  }

  @override
  State<NewGameDialog> createState() => _NewGameDialogState();
}

class _NewGameDialogState extends State<NewGameDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name';
    }
    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(value)) {
      return 'Name contains invalid characters';
    }
    if (value.length > 50) {
      return 'Name is too long (max 50 characters)';
    }
    return null;
  }

  Future<void> _createSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final name = _controller.text.trim();
      final savePath = await Persistence.createNewSave(name);
      if (mounted) {
        Navigator.of(context).pop(savePath);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('StateError: ', '');
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Game'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Save name',
                hintText: 'Enter a name for your save',
              ),
              validator: _validateName,
              onFieldSubmitted: (_) => _createSave(),
              enabled: !_isCreating,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isCreating ? null : _createSave,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
