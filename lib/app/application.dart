import 'package:flame/game.dart' hide Game;
import 'package:flutter/material.dart';
import 'package:rogueverse/game/game_area.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/inspector_overlay.dart';
import 'package:rogueverse/app/widgets/overlays/navigation_menu.dart';
import 'package:rogueverse/app/widgets/overlays/template_panel/template_panel.barrel.dart';

class Application extends StatelessWidget {
  final FocusNode gameAreaFocusNode;

  const Application({super.key, required this.gameAreaFocusNode});

  @override
  Widget build(BuildContext context) {
    final game = GameArea(gameAreaFocusNode);
    var darkColorScheme = ColorScheme.dark();

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
      // Root widget
      home: Scaffold(
        appBar: AppBar(
          // Title is dynamic so the game can control what displays, eg current location or tile name, etc.
          title: ValueListenableBuilder<String>(
            valueListenable: game.title,
            builder: (context, name, child) {
              return Text(name);
            },
          ),
          backgroundColor: darkColorScheme.surface,
          foregroundColor: darkColorScheme.onSurface,
          elevation: 2,
        ),
        drawer: NavigationDrawerContent(
          onEntityTemplatesPressed: () {
            // Turn off any active overlays, then open the template panel.
            game.overlays.clear();
            game.overlays.add('templatePanel');
          },
        ),
        body: Stack(children: [
          GameWidget(
            focusNode: gameAreaFocusNode,
            game: game,
            overlayBuilderMap: {
              // Inspector panel (right side)
              "inspectorPanel": (context, game) => Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 320,
                      child: InspectorPanel(
                        entityNotifier: (game as GameArea).selectedEntity,
                      ),
                    ),
                  ),
              // Template panel (left side)
              "templatePanel": (context, game) => Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 320,
                      child: TemplatePanel(
                        selectedTemplateNotifier:
                            (game as GameArea).selectedTemplate,
                        onCreateTemplate: () async {
                          await game.startTemplateCreation(context);
                        },
                        onClose: () {
                          game.overlays.remove('templatePanel');
                        },
                      ),
                    ),
                  ),
            },
          ),
        ]),
      ),
    );
  }
}
