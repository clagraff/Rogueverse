import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/app/widgets/keyboard/auto_focus_keyboard_listener.dart';
import 'package:rogueverse/app/widgets/keyboard/confirmation_dialog.dart';
import 'package:rogueverse/ecs/persistence.dart';

/// View for loading an existing save game.
class LoadGameView extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String savePath) onLoadSave;

  const LoadGameView({
    super.key,
    required this.onBack,
    required this.onLoadSave,
  });

  @override
  State<LoadGameView> createState() => _LoadGameViewState();
}

/// Actions available within each save row.
enum _RowAction { row, delete, play }

class _LoadGameViewState extends State<LoadGameView> {
  // Owned by this widget for manual refocus after dialogs.
  final FocusNode _focusNode = FocusNode();
  List<SaveFileInfo>? _saves;
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 0;
  _RowAction _focusedAction = _RowAction.row;

  @override
  void initState() {
    super.initState();
    _loadSaves();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSaves() async {
    try {
      final saves = await Persistence.listSaves();
      if (mounted) {
        setState(() {
          _saves = saves;
          _isLoading = false;
          _selectedIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSave(SaveFileInfo save) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Save',
      message: 'Are you sure you want to delete "${save.name}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    // Re-request focus after dialog closes
    _focusNode.requestFocus();

    if (confirmed) {
      await Persistence.deleteSave(save.path);
      _loadSaves();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final keybindings = KeyBindingService.instance;

    if (_saves == null || _saves!.isEmpty) {
      // Only handle Escape/menu.back when no saves
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          keybindings.matches('menu.back', {event.logicalKey})) {
        widget.onBack();
      }
      return;
    }

    final key = event.logicalKey;

    // Vertical navigation - move between save rows
    if (key == LogicalKeyboardKey.arrowUp || keybindings.matches('menu.up', {key})) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, _saves!.length - 1);
        _focusedAction = _RowAction.row; // Reset to row when changing rows
      });
    } else if (key == LogicalKeyboardKey.arrowDown || keybindings.matches('menu.down', {key})) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, _saves!.length - 1);
        _focusedAction = _RowAction.row; // Reset to row when changing rows
      });
    }
    // Horizontal navigation - move between actions within a row
    else if (key == LogicalKeyboardKey.arrowRight || keybindings.matches('menu.right', {key})) {
      setState(() {
        _focusedAction = switch (_focusedAction) {
          _RowAction.row => _RowAction.delete,
          _RowAction.delete => _RowAction.play,
          _RowAction.play => _RowAction.play, // Stay at play
        };
      });
    } else if (key == LogicalKeyboardKey.arrowLeft || keybindings.matches('menu.left', {key})) {
      setState(() {
        _focusedAction = switch (_focusedAction) {
          _RowAction.row => _RowAction.row, // Stay at row
          _RowAction.delete => _RowAction.row,
          _RowAction.play => _RowAction.delete,
        };
      });
    }
    // Activate the focused action (Enter, Space, or menu.select)
    else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        keybindings.matches('menu.select', {key})) {
      _activateFocusedAction();
    }
    // Delete shortcut (always deletes, regardless of focused action)
    else if (key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) {
      _deleteSave(_saves![_selectedIndex]);
    }
    // Go back (Escape or menu.back)
    else if (key == LogicalKeyboardKey.escape || keybindings.matches('menu.back', {key})) {
      // If focused on an action, go back to row first
      if (_focusedAction != _RowAction.row) {
        setState(() {
          _focusedAction = _RowAction.row;
        });
      } else {
        widget.onBack();
      }
    }
  }

  void _activateFocusedAction() {
    final save = _saves![_selectedIndex];
    switch (_focusedAction) {
      case _RowAction.row:
      case _RowAction.play:
        widget.onLoadSave(save.path);
      case _RowAction.delete:
        _deleteSave(save);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AutoFocusKeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
                tooltip: 'Back (Escape)',
              ),
              const SizedBox(width: 8),
              Text(
                'Load Game',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (_saves != null && _saves!.isNotEmpty)
                Builder(
                  builder: (context) {
                    final keybindings = KeyBindingService.instance;
                    final upKey = keybindings.getCombo('menu.up')?.toDisplayString() ?? 'W';
                    final downKey = keybindings.getCombo('menu.down')?.toDisplayString() ?? 'S';
                    final leftKey = keybindings.getCombo('menu.left')?.toDisplayString() ?? 'A';
                    final rightKey = keybindings.getCombo('menu.right')?.toDisplayString() ?? 'D';
                    final selectKey = keybindings.getCombo('menu.select')?.toDisplayString() ?? 'E';
                    return Text(
                      '$upKey/$downKey navigate, $leftKey/$rightKey select action, $selectKey confirm',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _buildContent(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Error loading saves', style: TextStyle(color: colorScheme.error)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadSaves();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_saves == null || _saves!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No saves found',
              style: TextStyle(color: colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new game to create your first save.',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              'Press Escape to go back',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.builder(
          itemCount: _saves!.length,
          itemBuilder: (context, index) {
        final save = _saves![index];
        final isSelected = index == _selectedIndex;
        final isDeleteFocused = isSelected && _focusedAction == _RowAction.delete;
        final isPlayFocused = isSelected && _focusedAction == _RowAction.play;
        final isRowFocused = isSelected && _focusedAction == _RowAction.row;

        return MouseRegion(
          onEnter: (_) => setState(() {
            _selectedIndex = index;
            _focusedAction = _RowAction.row;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: Card(
              margin: EdgeInsets.zero,
              color: isRowFocused
                  ? colorScheme.primaryContainer
                  : isSelected
                      ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                      : null,
              child: ListTile(
                leading: Icon(
                  Icons.save,
                  color: isSelected ? colorScheme.onPrimaryContainer : null,
                ),
                title: Text(
                  save.name,
                  style: TextStyle(
                    color: isSelected ? colorScheme.onPrimaryContainer : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                subtitle: Text(
                  'Last played: ${_formatDate(save.lastModified)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                        : colorScheme.outline,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delete button with focus indicator
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDeleteFocused ? colorScheme.error : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete_outline, color: colorScheme.error),
                        onPressed: () => _deleteSave(save),
                        tooltip: 'Delete',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Load button with focus indicator
                    isPlayFocused
                        ? FilledButton(
                            onPressed: () => widget.onLoadSave(save.path),
                            child: const Text('Load'),
                          )
                        : FilledButton.tonal(
                            onPressed: () => widget.onLoadSave(save.path),
                            child: const Text('Load'),
                          ),
                  ],
                ),
                onTap: () => widget.onLoadSave(save.path),
              ),
            ),
          ),
        );
        },
        ),
      ),
    );
  }
}
