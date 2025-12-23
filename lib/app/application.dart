import 'package:flame/game.dart' hide Game;
import 'package:flutter/gestures.dart'; // kMiddleMouseButton
import 'package:flutter/material.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/inspector_overlay.dart';
import 'package:rogueverse/app/widgets/overlays/navigation_menu.dart';
import 'package:rogueverse/app/widgets/overlays/template_panel/template_panel.barrel.dart';

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  "inspectorPanel": (context, game) => Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 260,
                      child: InspectorPanel(
                        entityNotifier: (_game).selectedEntity,
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
                          await _game.startTemplateEditing(context, template);
                        },
                        onClose: () {
                          _game.overlays.remove('templatePanel');
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
