import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen text editor for editing multiline text content.
/// Returns the edited text on save, or null if cancelled.
class TextEditorScreen extends StatefulWidget {
  final String title;
  final String initialValue;
  final String? hintText;

  const TextEditorScreen({
    super.key,
    required this.title,
    required this.initialValue,
    this.hintText,
  });

  /// Navigates to the text editor screen and returns the edited text or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String initialValue,
    String? hintText,
  }) async {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => TextEditorScreen(
          title: title,
          initialValue: initialValue,
          hintText: hintText,
        ),
      ),
    );
  }

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  late TextEditingController _controller;
  late FocusNode _textFocusNode;
  late FocusNode _keyboardFocusNode;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _textFocusNode = FocusNode();
    _keyboardFocusNode = FocusNode();
    _controller.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
      // Move cursor to end
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasChanges = _controller.text != widget.initialValue;
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  void _save() {
    Navigator.of(context).pop(_controller.text);
  }

  void _cancel() {
    if (_hasChanges) {
      _showDiscardDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showDiscardDialog() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (discard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Ctrl+S to save
    if (event.logicalKey == LogicalKeyboardKey.keyS &&
        HardwareKeyboard.instance.isControlPressed) {
      _save();
    }
    // Escape to cancel (with confirmation if changes)
    else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancel,
            tooltip: 'Cancel (Escape)',
          ),
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            focusNode: _textFocusNode,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Enter text...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Ctrl+S to save, Escape to cancel',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              if (_hasChanges)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Unsaved changes',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
