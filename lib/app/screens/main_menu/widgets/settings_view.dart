import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/widgets/keybindings_editor.dart';

/// Settings view with keybindings configuration.
class SettingsView extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsView({
    super.key,
    required this.onBack,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
                tooltip: 'Back (Escape)',
              ),
              const SizedBox(width: 8),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Keybindings editor
          const Expanded(
            child: KeybindingsEditor(),
          ),
        ],
      ),
    );
  }
}
