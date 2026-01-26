import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rogueverse/app/services/game_settings_service.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/keyboard/auto_focus_keyboard_listener.dart';
import 'package:rogueverse/app/services/text_template_service.dart';
import 'package:rogueverse/app/ui_constants.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/ecs/world.dart';
import 'package:rogueverse/game/components/dialog_control_handler.dart';

/// Overlay for displaying NPC dialog conversations.
///
/// Shows the NPC's text at the top and player choices below.
/// Supports keyboard navigation.
///
/// Reads dialog state from:
/// - Player's ActiveDialog component (NPC ID, current node ID)
/// - DialogNode entities (text, choices)
/// - NPC's Name component (speaker name)
class DialogOverlay extends StatefulWidget {
  /// The overlay name used to register and toggle this overlay.
  static const String overlayName = 'dialogOverlay';

  /// The dialog control handler managing state.
  final DialogControlHandler handler;

  /// The ECS world for entity lookup.
  final World world;

  /// The player entity for reading ActiveDialog.
  final Entity? player;

  const DialogOverlay({
    super.key,
    required this.handler,
    required this.world,
    required this.player,
  });

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> {
  final ScrollController _textScrollController = ScrollController();
  final ScrollController _choicesScrollController = ScrollController();

  @override
  void dispose() {
    _textScrollController.dispose();
    _choicesScrollController.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keybindings = KeyBindingService.instance;

    // Escape/menu.back - close dialog
    if (key == LogicalKeyboardKey.escape || keybindings.matches('menu.back', {key})) {
      widget.handler.endDialog();
      return;
    }

    // Navigation using menu.* keybindings (with arrow key fallbacks)
    if (key == LogicalKeyboardKey.arrowUp || keybindings.matches('menu.up', {key})) {
      widget.handler.moveSelectionUp();
      _ensureSelectedVisible();
      return;
    }

    if (key == LogicalKeyboardKey.arrowDown || keybindings.matches('menu.down', {key})) {
      widget.handler.moveSelectionDown();
      _ensureSelectedVisible();
      return;
    }

    // Selection using menu.select (with Enter/Space fallbacks)
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.select', {key})) {
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
    final player = widget.player;
    if (player == null) {
      return const SizedBox.shrink();
    }

    // Listen to keybinding changes, selected index changes, and component changes
    return ValueListenableBuilder<int>(
      valueListenable: KeyBindingService.instance.changeNotifier,
      builder: (context, _, __) => ValueListenableBuilder<int>(
        valueListenable: widget.handler.selectedIndexNotifier,
        builder: (context, selectedIndex, __) => StreamBuilder<Change>(
          stream: widget.world.componentChanges.onEntityOnComponent<ActiveDialog>(player.id),
          builder: (context, snapshot) {
            final active = player.get<ActiveDialog>();
            if (active == null) {
              return const SizedBox.shrink();
            }

            // Get speaker name from NPC entity
            final npcEntity = widget.world.getEntity(active.npcEntityId);
            final speakerName = npcEntity.get<Name>()?.name ?? 'Unknown';

            // Get dialog node
            final nodeEntity = widget.world.getEntity(active.currentNodeId);
            final dialogNode = nodeEntity.get<DialogNode>();
            if (dialogNode == null) {
              return const SizedBox.shrink();
            }

            return _buildDialogUI(
              context,
              player,
              npcEntity,
              speakerName,
              dialogNode,
              active.currentNodeId,
              selectedIndex,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDialogUI(
    BuildContext context,
    Entity player,
    Entity npc,
    String speakerName,
    DialogNode dialogNode,
    int currentNodeId,
    int selectedIndex,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<int>(
      valueListenable: GameSettingsService.instance.changeNotifier,
      builder: (context, _, __) {
        final dialogPosition = GameSettingsService.instance.dialogPosition;

        final dialogBox = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kDialogMaxWidth),
          child: AutoFocusKeyboardListener(
            onKeyEvent: _handleKeyEvent,
            child: Material(
              elevation: kElevationHigh,
              borderRadius: BorderRadius.circular(kRadiusL),
              color: colorScheme.surface,
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: kDialogMaxHeight,
                  minHeight: 100,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NPC text section
                    _buildNpcTextSection(colorScheme, player, npc, speakerName, dialogNode),

                    // Divider
                    Divider(height: 1, color: colorScheme.outlineVariant),

                    // Player choices section
                    _buildChoicesSection(colorScheme, dialogNode, currentNodeId, selectedIndex),

                    // Hint footer
                    _buildHintFooter(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        );

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

            // Dialog box with dynamic positioning
            _buildPositionedDialog(dialogBox, dialogPosition),
          ],
        );
      },
    );
  }

  Widget _buildPositionedDialog(Widget dialogBox, DialogPosition position) {
    return switch (position) {
      DialogPosition.bottom => Positioned(
          left: kSpacingMax,
          right: kSpacingMax,
          bottom: kSpacingMax,
          child: Center(child: dialogBox),
        ),
      DialogPosition.center => Positioned(
          left: kSpacingMax,
          right: kSpacingMax,
          top: 0,
          bottom: 0,
          child: Center(child: dialogBox),
        ),
      DialogPosition.top => Positioned(
          left: kSpacingMax,
          right: kSpacingMax,
          top: kSpacingMax,
          child: Center(child: dialogBox),
        ),
    };
  }

  Widget _buildNpcTextSection(
    ColorScheme colorScheme,
    Entity player,
    Entity npc,
    String speakerName,
    DialogNode dialogNode,
  ) {
    return Container(
      padding: const EdgeInsets.all(kSpacingXL),
      constraints: const BoxConstraints(maxHeight: kPanelMaxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker name
          Text(
            speakerName,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kSpacingM),

          // NPC text (scrollable if long)
          Flexible(
            child: SingleChildScrollView(
              controller: _textScrollController,
              child: Text(
                TextTemplateService.instance.resolve(
                  dialogNode.text,
                  context: TemplateContext(player: player, npc: npc),
                ),
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
    ColorScheme colorScheme,
    DialogNode dialogNode,
    int currentNodeId,
    int selectedIndex,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: kPanelMaxHeight),
      child: ListView.builder(
        controller: _choicesScrollController,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: kSpacingM),
        itemCount: dialogNode.choices.length,
        itemBuilder: (context, index) {
          final choice = dialogNode.choices[index];
          final isVisited = widget.handler.isChoiceVisited(currentNodeId, index);
          return _buildChoiceItem(
            colorScheme,
            choice,
            index,
            selectedIndex,
            isVisited,
          );
        },
      ),
    );
  }

  Widget _buildHintFooter(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingXL, vertical: kSpacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Esc',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: kSpacingS),
          Text(
            'Close',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceItem(
    ColorScheme colorScheme,
    DialogChoice choice,
    int index,
    int selectedIndex,
    bool isVisited,
  ) {
    final isSelected = index == selectedIndex;

    // Determine text color based on state
    Color textColor;
    if (isSelected) {
      textColor = colorScheme.onPrimaryContainer;
    } else if (isVisited) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.6);
    } else {
      textColor = colorScheme.onSurface;
    }

    return InkWell(
      onTap: () => widget.handler.selectChoice(index),
      onHover: (hovering) {
        if (hovering) {
          widget.handler.selectedIndexNotifier.value = index;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kSpacingXL, vertical: 10),
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
              child: Row(
                children: [
                  // Visited checkmark
                  if (isVisited) ...[
                    Icon(
                      Icons.check,
                      size: 14,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: kSpacingS),
                  ],
                  Expanded(
                    child: Text(
                      choice.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
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
