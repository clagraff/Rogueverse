import 'package:flutter/material.dart';
import 'package:rogueverse/app/screens/main_menu/main_menu_screen.dart';
import 'package:rogueverse/app/screens/game/game_screen_wrapper.dart';

/// The root application widget with routing between main menu and game.
class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    const darkColorScheme = ColorScheme.dark();

    return MaterialApp(
      title: 'Rogueverse',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        dialogTheme: DialogThemeData(
          backgroundColor: darkColorScheme.surface,
          elevation: 6.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const MainMenuScreen(),
            );
          case '/game':
            final savePath = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => GameScreenWrapper(
                gameAreaFocusNode: FocusNode(debugLabel: 'game'),
                savePatchPath: savePath,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const MainMenuScreen(),
            );
        }
      },
    );
  }
}
