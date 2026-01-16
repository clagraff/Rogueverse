import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/game/game_area.dart';

import 'panel_section.dart';
import 'entity_list_panel.dart';
import 'templates_panel.dart';
import 'properties_panel.dart';
import 'editor_footer_bar.dart';

/// Convenience class for building editor-specific panel content.
///
/// Provides static methods to build the left, right, and bottom panels
/// used in editing mode. These can be passed to [PanelLayout].
class EditorPanels {
  EditorPanels._();

  /// Builds the left panel content containing Entities and Templates sections.
  static Widget buildLeftPanel({
    required World world,
    required ValueNotifier<int?> viewedParentIdNotifier,
    required ValueNotifier<Set<Entity>> selectedEntitiesNotifier,
    required ValueNotifier<EntityTemplate?> selectedTemplateNotifier,
    required VoidCallback onCreateTemplate,
    required void Function(EntityTemplate) onEditTemplate,
  }) {
    return Column(
      children: [
        Flexible(
          child: PanelSection(
            title: 'Entities',
            child: EntityListPanel(
              world: world,
              viewedParentIdNotifier: viewedParentIdNotifier,
              selectedEntitiesNotifier: selectedEntitiesNotifier,
            ),
          ),
        ),
        Flexible(
          child: PanelSection(
            title: 'Templates',
            child: TemplatesPanel(
              selectedTemplateNotifier: selectedTemplateNotifier,
              onCreateTemplate: onCreateTemplate,
              onEditTemplate: onEditTemplate,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the right panel content containing the Properties section.
  static Widget buildRightPanel({
    required ValueNotifier<Entity?> entityNotifier,
    required ValueNotifier<Set<Entity>> selectedEntitiesNotifier,
  }) {
    return Column(
      children: [
        Flexible(
          child: PanelSection(
            title: 'Properties',
            child: PropertiesPanel(
              entityNotifier: entityNotifier,
              selectedEntitiesNotifier: selectedEntitiesNotifier,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the bottom bar containing the edit target selector and FAB.
  ///
  /// The FAB is positioned in a Stack overlay above the footer bar.
  static Widget buildBottomBar({
    required ValueNotifier<EditTarget> editTargetNotifier,
    required ValueNotifier<bool> blankEntityModeNotifier,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Footer bar
        EditorFooterBar(editTargetNotifier: editTargetNotifier),

        // FAB positioned above the footer bar
        Positioned(
          left: 16,
          top: -48, // Position above the footer bar
          child: Builder(
            builder: (context) {
              return ValueListenableBuilder<bool>(
                valueListenable: blankEntityModeNotifier,
                builder: (context, isActive, _) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return FloatingActionButton.small(
                    onPressed: () {
                      blankEntityModeNotifier.value = !isActive;
                    },
                    tooltip: 'Place blank entity',
                    backgroundColor:
                        isActive ? colorScheme.primaryContainer : null,
                    foregroundColor:
                        isActive ? colorScheme.onPrimaryContainer : null,
                    child: const Icon(Icons.add_box_outlined),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
