import 'package:collection/collection.dart';
import 'package:flame/game.dart' hide Game;
import 'package:flutter/gestures.dart'; // kMiddleMouseButton
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/components.dart' show Name, HasParent;
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/app/widgets/panels/dock_panel.dart';
import 'package:rogueverse/app/widgets/panels/panel_section.dart';
import 'package:rogueverse/app/widgets/panels/entity_list_panel.dart';
import 'package:rogueverse/app/widgets/panels/templates_panel.dart';
import 'package:rogueverse/app/widgets/panels/properties_panel.dart';
import 'package:rogueverse/app/widgets/panels/editor_footer_bar.dart';
import 'package:rogueverse/app/widgets/overlays/navigation_menu.dart';
import 'package:rogueverse/app/widgets/overlays/hierarchy_panel/hierarchy_panel.dart';
import 'package:rogueverse/app/widgets/overlays/vision_observer_panel.dart';

class Application extends StatefulWidget {
  final FocusNode gameAreaFocusNode;

  const Application({super.key, required this.gameAreaFocusNode});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late final GameArea _game;

  int? _panPointerId;

  @override
  void initState() {
    super.initState();
    _game = GameArea(widget.gameAreaFocusNode);
  }

  void _onPointerDown(PointerDownEvent event) {
    // Start panning when middle mouse is pressed.
    if ((event.buttons & kMiddleMouseButton) != 0) {
      _panPointerId = event.pointer;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_panPointerId != event.pointer) return;

    // If middle mouse is no longer held, stop panning.
    if ((event.buttons & kMiddleMouseButton) == 0) {
      _panPointerId = null;
      return;
    }

    final d = event.delta;
    _game.camera.moveBy(Vector2(-d.dx, -d.dy));
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_panPointerId == event.pointer) {
      _panPointerId = null;
    }
  }

  /// Finds the Player entity and restores selection, observer, and view to it.
  void _restorePlayerControl() {
    final playerEntity = _game.currentWorld.entities().firstWhereOrNull(
          (e) => e.get<Name>()?.name == "Player",
        );

    if (playerEntity != null) {
      // Set the player as the selected/controlled entity
      _game.selectedEntities.value = {playerEntity};
      // Set the player as the vision observer
      _game.observerEntityId.value = playerEntity.id;
      // Set the view to the player's parent (room/location)
      final playerParent = playerEntity.get<HasParent>();
      if (playerParent != null) {
        _game.viewedParentId.value = playerParent.parentEntityId;
      }
    } else {
      // No player found, just clear selection
      _game.selectedEntities.value = {};
      _game.observerEntityId.value = null;
    }
  }

  /// Toggles between gameplay and editing modes.
  void _toggleGameMode() {
    if (_game.gameMode.value == GameMode.gameplay) {
      _game.gameMode.value = GameMode.editing;
      // Clear any other overlays when entering edit mode
      _game.overlays.clear();
    } else {
      _game.gameMode.value = GameMode.gameplay;
      _restorePlayerControl();
    }
  }

  /// Handles keyboard events at the application level for global shortcuts.
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Get currently pressed keys
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    // Check for mode toggle keybinding (works regardless of focus)
    if (KeyBindingService.instance.matches('game.toggleMode', keysPressed)) {
      _toggleGameMode();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final darkColorScheme = const ColorScheme.dark();

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        dialogTheme: DialogThemeData(
          backgroundColor: darkColorScheme.surface,
          elevation: 6.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: Focus(
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Scaffold(
          appBar: AppBar(
          title: ValueListenableBuilder<String>(
            valueListenable: _game.title,
            builder: (context, name, child) => Text(name),
          ),
          backgroundColor: darkColorScheme.surface,
          foregroundColor: darkColorScheme.onSurface,
          elevation: 2,
        ),
        drawer: NavigationDrawerContent(
          onEditorPressed: () {
            // Editor is now shown via dock panels in edit mode
            // Note: drawer is already closed by NavigationDrawerContent before this callback
            if (_game.gameMode.value != GameMode.editing) {
              _toggleGameMode();
            }
          },
          onHierarchyNavigatorPressed: () {
            _game.overlays.clear();
            _game.overlays.add(HierarchyPanel.overlayName);
          },
          onVisionObserverPressed: () {
            _game.overlays.clear();
            _game.overlays.add(VisionObserverPanel.overlayName);
          },
          onToggleEditModePressed: _toggleGameMode,
          gameModeNotifier: _game.gameMode,
          selectedEntityNotifier: _game.selectedEntity,
          worldGetter: () => _game.currentWorld,
        ),
        body: ValueListenableBuilder<GameMode>(
          valueListenable: _game.gameMode,
          builder: (context, gameMode, _) {
            final isEditingMode = gameMode == GameMode.editing;

            return Stack(
              children: [
                // Game area (center)
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerUp,
                  child: GameWidget(
                    focusNode: widget.gameAreaFocusNode,
                    game: _game,
                    overlayBuilderMap: {
                      HierarchyPanel.overlayName: (context, game) => Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 320,
                              child: HierarchyPanel(
                                world: _game.currentWorld,
                                viewedParentIdNotifier: _game.viewedParentId,
                                onClose: () {
                                  _game.overlays.remove(HierarchyPanel.overlayName);
                                },
                              ),
                            ),
                          ),
                      VisionObserverPanel.overlayName: (context, game) => Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 280,
                              child: VisionObserverPanel(
                                world: _game.currentWorld,
                                observerEntityIdNotifier: _game.observerEntityId,
                                viewedParentIdNotifier: _game.viewedParentId,
                                onClose: () {
                                  _game.overlays.remove(VisionObserverPanel.overlayName);
                                },
                              ),
                            ),
                          ),
                    },
                  ),
                ),

                // Left dock (editing mode only)
                if (isEditingMode)
                  DockPanel(
                    side: DockSide.left,
                    width: 280,
                    children: [
                      PanelSection(
                        title: 'Entities',
                        child: EntityListPanel(
                          world: _game.currentWorld,
                          viewedParentIdNotifier: _game.viewedParentId,
                          selectedEntitiesNotifier: _game.selectedEntities,
                        ),
                      ),
                      PanelSection(
                        title: 'Templates',
                        child: TemplatesPanel(
                          selectedTemplateNotifier: _game.selectedTemplate,
                          onCreateTemplate: () async {
                            await _game.startTemplateCreation(context);
                          },
                          onEditTemplate: (template) async {
                            await _game.startTemplateEditing(context, template);
                          },
                        ),
                      ),
                    ],
                  ),

                // Right dock (editing mode only)
                if (isEditingMode)
                  DockPanel(
                    side: DockSide.right,
                    width: 280,
                    children: [
                      PanelSection(
                        title: 'Properties',
                        child: PropertiesPanel(
                          entityNotifier: _game.selectedEntity,
                        ),
                      ),
                    ],
                  ),

                // Footer bar (editing mode only)
                if (isEditingMode)
                  Positioned(
                    left: 280, // After left dock
                    right: 280, // Before right dock
                    bottom: 0,
                    child: EditorFooterBar(
                      editTargetNotifier: _game.editTarget,
                    ),
                  ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}
