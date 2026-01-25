import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/keybindings_editor.dart';
import 'package:rogueverse/app/widgets/general_settings_editor.dart';

/// Settings tab content for the character screen.
///
/// Implements hierarchical keyboard navigation:
/// - Sub-tab level: A/D to switch between General/Keybindings, S to enter content
/// - When focus is on sub-tab level, Escape returns focus to parent (closes overlay)
///
/// Displays a tabbed layout with General and Keybindings sections.
class SettingsTabContent extends StatefulWidget {
  /// Parent's focus node. When user presses Escape at sub-tab level,
  /// focus returns here (which typically closes the overlay).
  final FocusNode? parentFocusNode;

  const SettingsTabContent({super.key, this.parentFocusNode});

  @override
  State<SettingsTabContent> createState() => _SettingsTabContentState();
}

enum _SettingsSection { general, keybindings }

class _SettingsTabContentState extends State<SettingsTabContent> {
  _SettingsSection _currentSection = _SettingsSection.general;

  /// Our own focus node for sub-tab level navigation.
  final _focusNode = FocusNode();

  /// Focus node for the GeneralSettingsEditor (we control when it gets focus).
  final _generalSettingsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus on sub-tab level after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _generalSettingsFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keybindings = KeyBindingService.instance;

    // Escape: return focus to parent (closes overlay from parent's perspective)
    if (key == LogicalKeyboardKey.escape ||
        keybindings.matches('menu.back', {key})) {
      widget.parentFocusNode?.requestFocus();
      return;
    }

    // A/Left: switch to General sub-tab
    if (key == LogicalKeyboardKey.arrowLeft ||
        keybindings.matches('menu.left', {key})) {
      setState(() => _currentSection = _SettingsSection.general);
      return;
    }

    // D/Right: switch to Keybindings sub-tab
    if (key == LogicalKeyboardKey.arrowRight ||
        keybindings.matches('menu.right', {key})) {
      setState(() => _currentSection = _SettingsSection.keybindings);
      return;
    }

    // S/Down/Enter/Space: Enter content level
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.down', {key}) ||
        keybindings.matches('menu.select', {key})) {
      if (_currentSection == _SettingsSection.general) {
        _generalSettingsFocusNode.requestFocus();
      }
      // Keybindings section doesn't have keyboard navigation yet
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _focusNode,
      builder: (context, child) {
        final hasSubTabFocus = _focusNode.hasFocus;

        return KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: Column(
            children: [
              // Tab buttons - show selection highlight only when sub-tab level has focus
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTabButton(
                      context,
                      label: 'General',
                      isSelected: _currentSection == _SettingsSection.general,
                      showHighlight: hasSubTabFocus && _currentSection == _SettingsSection.general,
                      onTap: () {
                        setState(() => _currentSection = _SettingsSection.general);
                        _focusNode.requestFocus();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildTabButton(
                      context,
                      label: 'Keybindings',
                      isSelected: _currentSection == _SettingsSection.keybindings,
                      showHighlight: hasSubTabFocus && _currentSection == _SettingsSection.keybindings,
                      onTap: () {
                        setState(() => _currentSection = _SettingsSection.keybindings);
                        _focusNode.requestFocus();
                      },
                    ),
                  ],
                ),
              ),

              Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                height: 16,
              ),

              // Content based on selected tab
              Expanded(
                child: _currentSection == _SettingsSection.general
                    ? GeneralSettingsEditor(
                        focusNode: _generalSettingsFocusNode,
                        parentFocusNode: _focusNode,
                      )
                    : const KeybindingsEditor(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required bool showHighlight,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    // showHighlight: true when sub-tab level has focus AND this tab is selected
    // isSelected: true when this is the current section (determines content)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: showHighlight
              ? colorScheme.primaryContainer
              : isSelected
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: showHighlight
                ? colorScheme.primary
                : isSelected
                    ? colorScheme.outlineVariant
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: showHighlight
                ? colorScheme.onPrimaryContainer
                : isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: showHighlight || isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
