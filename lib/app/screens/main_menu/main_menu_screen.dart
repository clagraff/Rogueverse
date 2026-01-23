import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/screens/main_menu/widgets/load_game_view.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/screens/main_menu/widgets/menu_button.dart';
import 'package:rogueverse/app/screens/main_menu/widgets/new_game_dialog.dart';
import 'package:rogueverse/app/screens/main_menu/widgets/settings_view.dart';

/// The view state for the main menu.
enum _MenuView {
  main,
  loadGame,
  settings,
}

/// The main menu screen shown at app launch.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  _MenuView _currentView = _MenuView.main;
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 0;
  static const int _menuItemCount = 4;

  @override
  void initState() {
    super.initState();
    // Request focus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToGame(String? savePath) {
    Navigator.of(context).pushNamed('/game', arguments: savePath);
  }

  Future<void> _onNewGame() async {
    final savePath = await NewGameDialog.show(context);
    if (savePath != null && mounted) {
      _navigateToGame(savePath);
    }
    // Re-request focus after dialog closes
    _focusNode.requestFocus();
  }

  void _onLoadGame() {
    setState(() {
      _currentView = _MenuView.loadGame;
    });
  }

  void _onSettings() {
    setState(() {
      _currentView = _MenuView.settings;
    });
  }

  void _onQuit() {
    exit(0);
  }

  void _goBack() {
    setState(() {
      _currentView = _MenuView.main;
      _selectedIndex = 0;
    });
    // Re-request focus when returning to main menu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final keybindings = KeyBindingService.instance;

    // Navigation using menu.* keybindings (with arrow key fallbacks)
    if (key == LogicalKeyboardKey.arrowUp || keybindings.matches('menu.up', {key})) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, _menuItemCount - 1);
      });
    } else if (key == LogicalKeyboardKey.arrowDown || keybindings.matches('menu.down', {key})) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, _menuItemCount - 1);
      });
    }
    // Selection (Enter, Space, or menu.select)
    else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.select', {key})) {
      _activateSelectedItem();
    }
  }

  void _activateSelectedItem() {
    switch (_selectedIndex) {
      case 0:
        _onNewGame();
        break;
      case 1:
        _onLoadGame();
        break;
      case 2:
        _onSettings();
        break;
      case 3:
        _onQuit();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentView) {
      case _MenuView.main:
        return _buildMainMenu();
      case _MenuView.loadGame:
        return LoadGameView(
          onBack: _goBack,
          onLoadSave: _navigateToGame,
        );
      case _MenuView.settings:
        return SettingsView(onBack: _goBack);
    }
  }

  Widget _buildMainMenu() {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'Rogueverse',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),

            // Menu buttons
            MenuButton(
              label: 'New Game',
              icon: Icons.add,
              onPressed: _onNewGame,
              isSelected: _selectedIndex == 0,
              onHover: (hovering) {
                if (hovering) setState(() => _selectedIndex = 0);
              },
            ),
            const SizedBox(height: 12),
            MenuButton(
              label: 'Load Game',
              icon: Icons.folder_open,
              onPressed: _onLoadGame,
              isSelected: _selectedIndex == 1,
              onHover: (hovering) {
                if (hovering) setState(() => _selectedIndex = 1);
              },
            ),
            const SizedBox(height: 12),
            MenuButton(
              label: 'Settings',
              icon: Icons.settings,
              onPressed: _onSettings,
              isSelected: _selectedIndex == 2,
              onHover: (hovering) {
                if (hovering) setState(() => _selectedIndex = 2);
              },
            ),
            const SizedBox(height: 12),
            MenuButton(
              label: 'Quit',
              icon: Icons.exit_to_app,
              onPressed: _onQuit,
              isSelected: _selectedIndex == 3,
              onHover: (hovering) {
                if (hovering) setState(() => _selectedIndex = 3);
              },
            ),
          ],
        ),
      ),
    );
  }
}
