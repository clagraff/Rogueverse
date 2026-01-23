import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogueverse/app/services/keybinding_service.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/game/interaction/interaction_definition.dart';
import 'package:rogueverse/game/interaction/nearby_entity_finder.dart';

/// A context menu overlay for selecting interactions with nearby entities.
///
/// Displays available interactions grouped by action type. When multiple
/// entities support the same action, shows a submenu to select which entity.
/// Self-actions (like Wait) appear at the end and have no submenu.
class InteractionContextMenu extends StatefulWidget {
  /// The overlay name used to register and toggle this menu.
  static const String overlayName = 'interactionContextMenu';

  /// List of nearby entities with their available interactions.
  final List<InteractableEntity> interactables;

  /// Self-actions available to the player (e.g., Wait).
  final List<InteractionDefinition> selfActions;

  /// Screen position to display the menu at.
  final Offset position;

  /// Called when a target interaction is selected.
  final void Function(Entity? target, InteractionDefinition interaction) onSelect;

  /// Called when the menu should be dismissed.
  final VoidCallback onDismiss;

  /// Called when the highlighted target entity changes (for visual feedback).
  /// Passes null when no entity is highlighted (e.g., self-action selected).
  final void Function(Entity? entity)? onHighlightChanged;

  const InteractionContextMenu({
    super.key,
    required this.interactables,
    this.selfActions = const [],
    required this.position,
    required this.onSelect,
    required this.onDismiss,
    this.onHighlightChanged,
  });

  @override
  State<InteractionContextMenu> createState() => _InteractionContextMenuState();
}

/// Represents a single menu item (either target interaction(s) or self-action).
class _MenuItem {
  final String actionName;
  final int sortOrder;

  /// For target interactions: list of (entity, interaction) pairs.
  /// Empty for self-actions.
  final List<(InteractableEntity, InteractionDefinition)> targets;

  /// For self-actions: the interaction definition. Null for target interactions.
  final InteractionDefinition? selfAction;

  /// Direction priority (lower = better alignment with player facing).
  /// Used as secondary sort key after sortOrder.
  final int directionPriority;

  bool get isSelfAction => selfAction != null;
  bool get hasSubmenu => targets.length > 1;

  _MenuItem.target({
    required this.actionName,
    required this.sortOrder,
    required this.targets,
    this.directionPriority = 0,
  }) : selfAction = null;

  _MenuItem.self({
    required InteractionDefinition interaction,
  })  : actionName = interaction.actionName,
        sortOrder = interaction.sortOrder,
        targets = [],
        selfAction = interaction,
        directionPriority = 999; // Self-actions always last within same sortOrder
}

class _InteractionContextMenuState extends State<InteractionContextMenu> {
  final FocusNode _focusNode = FocusNode();
  final _keybindings = KeyBindingService.instance;
  int _selectedIndex = 0;
  int? _expandedIndex;
  int _submenuSelectedIndex = 0;

  /// Builds the list of menu items, sorted by sortOrder and direction priority.
  List<_MenuItem> get _menuItems {
    final items = <_MenuItem>[];

    // Group target interactions by action name
    // Track direction priority (index in the pre-sorted interactables list)
    final groups = <String, List<(InteractableEntity, InteractionDefinition)>>{};
    final sortOrders = <String, int>{};
    final directionPriorities = <String, int>{};

    for (var i = 0; i < widget.interactables.length; i++) {
      final interactable = widget.interactables[i];
      for (final interaction in interactable.availableInteractions) {
        groups.putIfAbsent(interaction.actionName, () => []);
        groups[interaction.actionName]!.add((interactable, interaction));

        // Use the lowest sortOrder for the action
        sortOrders[interaction.actionName] = sortOrders[interaction.actionName] == null
            ? interaction.sortOrder
            : (interaction.sortOrder < sortOrders[interaction.actionName]!
                ? interaction.sortOrder
                : sortOrders[interaction.actionName]!);

        // Use the lowest index (best direction) for the action
        directionPriorities[interaction.actionName] =
            directionPriorities[interaction.actionName] == null
                ? i
                : (i < directionPriorities[interaction.actionName]!
                    ? i
                    : directionPriorities[interaction.actionName]!);
      }
    }

    // Add target interactions as menu items
    for (final entry in groups.entries) {
      items.add(_MenuItem.target(
        actionName: entry.key,
        sortOrder: sortOrders[entry.key] ?? 0,
        targets: entry.value,
        directionPriority: directionPriorities[entry.key] ?? 0,
      ));
    }

    // Add self-actions as menu items
    for (final selfAction in widget.selfActions) {
      items.add(_MenuItem.self(interaction: selfAction));
    }

    // Sort by sortOrder first, then by direction priority
    items.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) return sortCompare;
      return a.directionPriority.compareTo(b.directionPriority);
    });

    return items;
  }

  @override
  void initState() {
    super.initState();
    _requestFocusAfterBuild();
    // Notify initial highlight after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyHighlightChanged();
    });
  }

  @override
  void dispose() {
    // Clear highlight when menu closes
    widget.onHighlightChanged?.call(null);
    _focusNode.dispose();
    super.dispose();
  }

  /// Gets the currently highlighted entity based on selection state.
  Entity? get _highlightedEntity {
    final items = _menuItems;
    if (_selectedIndex >= items.length) return null;

    final menuItem = items[_selectedIndex];

    // Self-actions don't highlight an entity
    if (menuItem.isSelfAction) return null;

    // If in submenu, highlight the submenu selection
    if (_expandedIndex != null) {
      final targets = menuItem.targets;
      if (_submenuSelectedIndex < targets.length) {
        return targets[_submenuSelectedIndex].$1.entity;
      }
      return null;
    }

    // In main menu with single target, highlight that target
    if (menuItem.targets.length == 1) {
      return menuItem.targets.first.$1.entity;
    }

    // Multiple targets but not expanded - no single entity to highlight
    return null;
  }

  /// Notifies the parent of the currently highlighted entity.
  void _notifyHighlightChanged() {
    widget.onHighlightChanged?.call(_highlightedEntity);
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

    final items = _menuItems;
    if (items.isEmpty) return;

    final key = event.logicalKey;

    // Handle escape/menu.back - close submenu or dismiss menu
    if (key == LogicalKeyboardKey.escape || _keybindings.matches('menu.back', {key})) {
      if (_expandedIndex != null) {
        setState(() => _expandedIndex = null);
        _notifyHighlightChanged();
      } else {
        widget.onDismiss();
      }
      return;
    }

    // Check for interact key and menu.select (same key that opens menu can select/expand)
    final isInteractKey = _keybindings.matches('entity.interact', {key});
    final isSelectKey = _keybindings.matches('menu.select', {key});

    // Handle enter/space/menu.select/interact - select current item
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        isSelectKey ||
        isInteractKey) {
      _selectCurrentItem();
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
      if (_expandedIndex != null) {
        // In submenu - select by number
        final menuItem = items[_expandedIndex!];
        if (keyIndex < menuItem.targets.length) {
          final (interactable, interaction) = menuItem.targets[keyIndex];
          widget.onSelect(interactable.entity, interaction);
        }
      } else if (keyIndex < items.length) {
        // In main menu - select by number
        setState(() => _selectedIndex = keyIndex);
        _selectCurrentItem();
      }
      return;
    }

    // Navigation keys: arrows and menu.* keybindings
    // Avoid navigation if the key is used for interact/select (e.g., WASD might be bound to interact)
    final isUp = key == LogicalKeyboardKey.arrowUp ||
        (!isInteractKey && !isSelectKey && _keybindings.matches('menu.up', {key}));
    final isDown = key == LogicalKeyboardKey.arrowDown ||
        (!isInteractKey && !isSelectKey && _keybindings.matches('menu.down', {key}));
    final isLeft = key == LogicalKeyboardKey.arrowLeft ||
        (!isInteractKey && !isSelectKey && _keybindings.matches('menu.left', {key}));
    final isRight = key == LogicalKeyboardKey.arrowRight ||
        (!isInteractKey && !isSelectKey && _keybindings.matches('menu.right', {key}));

    if (_expandedIndex != null) {
      // Navigating within submenu
      final menuItem = items[_expandedIndex!];
      final targets = menuItem.targets;

      if (isUp) {
        setState(() {
          _submenuSelectedIndex = (_submenuSelectedIndex - 1).clamp(0, targets.length - 1);
        });
        _notifyHighlightChanged();
      } else if (isDown) {
        setState(() {
          _submenuSelectedIndex = (_submenuSelectedIndex + 1).clamp(0, targets.length - 1);
        });
        _notifyHighlightChanged();
      } else if (isLeft) {
        // Close submenu, go back to main menu
        setState(() => _expandedIndex = null);
        _notifyHighlightChanged();
      } else if (isRight) {
        // Already in submenu, right does nothing (or could select)
      }
    } else {
      // Navigating main menu
      if (isUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1).clamp(0, items.length - 1);
        });
        _notifyHighlightChanged();
      } else if (isDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1).clamp(0, items.length - 1);
        });
        _notifyHighlightChanged();
      } else if (isRight) {
        // Expand submenu if available (not for self-actions)
        final menuItem = items[_selectedIndex];
        if (menuItem.hasSubmenu) {
          setState(() {
            _expandedIndex = _selectedIndex;
            _submenuSelectedIndex = 0; // Reset submenu selection
          });
          _notifyHighlightChanged();
        } else {
          // Single item or self-action - select it directly
          _selectCurrentItem();
        }
      } else if (isLeft) {
        // At main menu, left closes the entire menu
        widget.onDismiss();
      }
    }
  }

  void _selectCurrentItem() {
    final items = _menuItems;
    if (_selectedIndex >= items.length) return;

    final menuItem = items[_selectedIndex];

    if (_expandedIndex != null) {
      // In submenu - select the highlighted submenu item
      final targets = menuItem.targets;
      if (_submenuSelectedIndex < targets.length) {
        final (interactable, interaction) = targets[_submenuSelectedIndex];
        widget.onSelect(interactable.entity, interaction);
      }
      return;
    }

    // In main menu
    if (menuItem.isSelfAction) {
      // Self-action - execute directly with null target
      widget.onSelect(null, menuItem.selfAction!);
    } else if (menuItem.targets.length == 1) {
      // Single target - execute directly
      final (interactable, interaction) = menuItem.targets.first;
      widget.onSelect(interactable.entity, interaction);
    } else {
      // Multiple targets - expand submenu
      setState(() {
        _expandedIndex = _selectedIndex;
        _submenuSelectedIndex = 0;
      });
      _notifyHighlightChanged();
    }
  }

  void _selectEntity(InteractableEntity interactable, InteractionDefinition interaction) {
    widget.onSelect(interactable.entity, interaction);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = _menuItems;

    if (items.isEmpty) {
      // No interactions available - dismiss
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDismiss();
      });
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Invisible barrier to catch taps outside menu
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Main menu
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(4),
              color: colorScheme.surface,
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildMenuItems(context),
                ),
              ),
            ),
          ),
        ),

        // Submenu (if expanded)
        if (_expandedIndex != null) _buildSubmenu(context),
      ],
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = _menuItems;

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final menuItem = entry.value;
      final isSelected = index == _selectedIndex;

      return InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          _selectCurrentItem();
        },
        onHover: (hovering) {
          if (hovering) {
            setState(() => _selectedIndex = index);
            _notifyHighlightChanged();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : null,
            border: isSelected
                ? Border(left: BorderSide(color: colorScheme.primary, width: 3))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${index + 1}. ${menuItem.actionName}',
                style: TextStyle(
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (menuItem.hasSubmenu) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSubmenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final menuItem = _menuItems[_expandedIndex!];
    final targets = menuItem.targets;

    // Position submenu to the right of the main menu
    // Estimate main menu width (rough calculation)
    const mainMenuWidth = 120.0;
    final submenuLeft = widget.position.dx + mainMenuWidth;
    final submenuTop = widget.position.dy + (_expandedIndex! * 36.0);

    return Positioned(
      left: submenuLeft,
      top: submenuTop,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(4),
        color: colorScheme.surface,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: targets.asMap().entries.map((entry) {
              final index = entry.key;
              final (interactable, interaction) = entry.value;
              final isSelected = index == _submenuSelectedIndex;

              return InkWell(
                onTap: () => _selectEntity(interactable, interaction),
                onHover: (hovering) {
                  if (hovering) {
                    setState(() => _submenuSelectedIndex = index);
                    _notifyHighlightChanged();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primaryContainer : null,
                    border: isSelected
                        ? Border(left: BorderSide(color: colorScheme.primary, width: 3))
                        : null,
                  ),
                  child: Text(
                    '${index + 1}. ${interactable.displayName}',
                    style: TextStyle(
                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
