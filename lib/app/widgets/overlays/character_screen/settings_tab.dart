import 'package:flutter/material.dart';

import 'package:rogueverse/app/widgets/keybindings_editor.dart';

/// Settings tab content for the character screen.
///
/// Wraps the [KeybindingsEditor] for use in the character screen overlay.
class SettingsTabContent extends StatelessWidget {
  const SettingsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const KeybindingsEditor();
  }
}
