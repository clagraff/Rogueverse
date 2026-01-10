import 'package:flame/game.dart' hide Game;
import 'package:flutter/gestures.dart'; // kMiddleMouseButton
import 'package:flutter/material.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/inspector_overlay.dart';
import 'package:rogueverse/app/widgets/overlays/navigation_menu.dart';
import 'package:rogueverse/app/widgets/overlays/template_panel/entity_template_overlay.dart';
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
      home: Scaffold(
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
          onEntityTemplatesPressed: () {
            _game.overlays.clear();
            _game.overlays.add('templatePanel');
          },
          onHierarchyNavigatorPressed: () {
            _game.overlays.clear();
            _game.overlays.add('hierarchyPanel');
          },
          onVisionObserverPressed: () {
            _game.overlays.clear();
            _game.overlays.add('visionObserverPanel');
          },
          onEntityEditorPressed: () {
            // Toggle editor panel
            if (_game.overlays.isActive('editorPanel')) {
              _game.overlays.remove('editorPanel');
            } else {
              _game.overlays.add('editorPanel');
            }
          },
          selectedEntityNotifier: _game.selectedEntity,
          world: _game.currentWorld,
        ),
        body: Stack(
          children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              child: GameWidget(
                focusNode: widget.gameAreaFocusNode,
                game: _game,
                overlayBuilderMap: {
                  "editorPanel": (context, game) => Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 260,
                          child: InspectorPanel(
                            entityNotifier: _game.selectedEntity,
                            onClose: () {
                              _game.overlays.remove('editorPanel');
                            },
                          ),
                        ),
                      ),
                  "templatePanel": (context, game) => Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 260,
                          child: TemplatePanel(
                            selectedTemplateNotifier: _game.selectedTemplate,
                            onCreateTemplate: () async {
                              await _game.startTemplateCreation(context);
                            },
                            onEditTemplate: (template) async {
                              await _game.startTemplateEditing(
                                  context, template);
                            },
                            onClose: () {
                              _game.overlays.remove('templatePanel');
                            },
                          ),
                        ),
                      ),
                  "hierarchyPanel": (context, game) => Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 320,
                          child: HierarchyPanel(
                            world: _game.currentWorld,
                            viewedParentIdNotifier: _game.viewedParentId,
                            onClose: () {
                              _game.overlays.remove('hierarchyPanel');
                            },
                          ),
                        ),
                      ),
                  "visionObserverPanel": (context, game) => Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 280,
                          child: VisionObserverPanel(
                            world: _game.currentWorld,
                            observerEntityIdNotifier: _game.observerEntityId,
                            viewedParentIdNotifier: _game.viewedParentId,
                            onClose: () {
                              _game.overlays.remove('visionObserverPanel');
                            },
                          ),
                        ),
                      ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
