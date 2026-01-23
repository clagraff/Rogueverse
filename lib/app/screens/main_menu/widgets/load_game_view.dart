import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
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

class _LoadGameViewState extends State<LoadGameView> {
  final FocusNode _focusNode = FocusNode();
  List<SaveFileInfo>? _saves;
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSaves();
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Save'),
        content: Text('Are you sure you want to delete "${save.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Re-request focus after dialog closes
    _focusNode.requestFocus();

    if (confirmed == true) {
      await Persistence.deleteSave(save.path);
      _loadSaves();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_saves == null || _saves!.isEmpty) {
      // Only handle Escape when no saves
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onBack();
      }
      return;
    }

    final key = event.logicalKey;

    // Navigation
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, _saves!.length - 1);
      });
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, _saves!.length - 1);
      });
    }
    // Load selected save (Enter, Space, or interact key)
    else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        KeyBindingService.instance.matches('entity.interact', {key})) {
      widget.onLoadSave(_saves![_selectedIndex].path);
    }
    // Delete selected save
    else if (key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) {
      _deleteSave(_saves![_selectedIndex]);
    }
    // Go back
    else if (key == LogicalKeyboardKey.escape) {
      widget.onBack();
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

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
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
                Text(
                  'Enter to load, Delete to remove',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline,
                  ),
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

        return MouseRegion(
          onEnter: (_) => setState(() => _selectedIndex = index),
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
              color: isSelected ? colorScheme.primaryContainer : null,
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
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: colorScheme.error),
                      onPressed: () => _deleteSave(save),
                      tooltip: 'Delete (Del)',
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () => widget.onLoadSave(save.path),
                      child: const Text('Play'),
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
