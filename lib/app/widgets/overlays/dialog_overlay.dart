import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/ecs/dialog/dialog.dart';
import 'package:rogueverse/game/components/dialog_control_handler.dart';

/// Overlay for displaying NPC dialog conversations.
///
/// Shows the NPC's text at the top and player choices below.
/// Supports keyboard navigation and displays condition requirements
/// on unavailable choices.
class DialogOverlay extends StatefulWidget {
  /// The overlay name used to register and toggle this overlay.
  static const String overlayName = 'dialogOverlay';

  /// The dialog control handler managing state.
  final DialogControlHandler handler;

  const DialogOverlay({
    super.key,
    required this.handler,
  });

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _textScrollController = ScrollController();
  final ScrollController _choicesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestFocusAfterBuild();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textScrollController.dispose();
    _choicesScrollController.dispose();
    super.dispose();
  }

  void _requestFocusAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    // Escape - close dialog
    if (key == LogicalKeyboardKey.escape) {
      widget.handler.endDialog();
      return;
    }

    // Navigation
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      widget.handler.moveSelectionUp();
      _ensureSelectedVisible();
      return;
    }

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      widget.handler.moveSelectionDown();
      _ensureSelectedVisible();
      return;
    }

    // Selection
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.keyE) {
      widget.handler.confirmSelection();
      return;
    }

    // Number keys for quick selection (1-9)
    final numberKeys = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
    ];

    final keyIndex = numberKeys.indexOf(key);
    if (keyIndex != -1) {
      widget.handler.selectChoice(keyIndex);
      return;
    }
  }

  void _ensureSelectedVisible() {
    // Scroll to make selected item visible if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This would need actual implementation based on item positions
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DialogState?>(
      valueListenable: widget.handler.dialogState,
      builder: (context, state, child) {
        if (state == null) {
          return const SizedBox.shrink();
        }

        final result = state.result;
        if (result is! DialogAwaitingChoice) {
          return const SizedBox.shrink();
        }

        return _buildDialogUI(context, state, result);
      },
    );
  }

  Widget _buildDialogUI(
    BuildContext context,
    DialogState state,
    DialogAwaitingChoice result,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // Semi-transparent backdrop
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.handler.endDialog,
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ),

        // Dialog box centered at bottom
        Positioned(
          left: 32,
          right: 32,
          bottom: 32,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: KeyboardListener(
                focusNode: _focusNode,
                autofocus: true,
                onKeyEvent: _handleKeyEvent,
                child: Material(
                  elevation: 16,
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surface,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 400,
                      minHeight: 100,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // NPC text section
                        _buildNpcTextSection(context, state, result),

                        // Divider
                        Divider(height: 1, color: colorScheme.outlineVariant),

                        // Player choices section
                        _buildChoicesSection(context, state, result),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNpcTextSection(
    BuildContext context,
    DialogState state,
    DialogAwaitingChoice result,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxHeight: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker name
          Text(
            result.speakerName.isNotEmpty ? result.speakerName : state.npcName,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // NPC text (scrollable if long)
          Flexible(
            child: SingleChildScrollView(
              controller: _textScrollController,
              child: Text(
                result.text,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoicesSection(
    BuildContext context,
    DialogState state,
    DialogAwaitingChoice result,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        controller: _choicesScrollController,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: result.choices.length,
        itemBuilder: (context, index) {
          return _buildChoiceItem(context, state, result.choices[index], index);
        },
      ),
    );
  }

  Widget _buildChoiceItem(
    BuildContext context,
    DialogState state,
    DialogChoice choice,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = index == state.selectedIndex;
    final isAvailable = choice.isAvailable;

    // Determine text color based on state
    Color textColor;
    if (!isAvailable) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.4);
    } else if (isSelected) {
      textColor = colorScheme.onPrimaryContainer;
    } else {
      textColor = colorScheme.onSurface;
    }

    return InkWell(
      onTap: isAvailable
          ? () => widget.handler.selectChoice(index)
          : null,
      onHover: (hovering) {
        if (hovering && isAvailable) {
          widget.handler.dialogState.value = state.copyWith(selectedIndex: index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : null,
          border: isSelected
              ? Border(left: BorderSide(color: colorScheme.primary, width: 3))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Choice number indicator
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}.',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),

            // Choice content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Condition label (if unavailable)
                  if (choice.conditionLabel != null) ...[
                    Text(
                      choice.conditionLabel!,
                      style: TextStyle(
                        color: isAvailable
                            ? colorScheme.secondary
                            : colorScheme.error.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],

                  // Choice text
                  Text(
                    choice.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontStyle: isAvailable ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
