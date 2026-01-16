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
    required ValueNotifier<int?> selectedTemplateIdNotifier,
    required VoidCallback onCreateTemplate,
    required void Function(Entity) onEditTemplate,
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
              world: world,
              selectedTemplateIdNotifier: selectedTemplateIdNotifier,
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
  /// Uses a SizedBox to give the Stack enough height to include the FAB
  /// in its hit test area (the FAB floats above the footer bar).
  static Widget buildBottomBar({
    required ValueNotifier<EditTarget> editTargetNotifier,
    required ValueNotifier<bool> blankEntityModeNotifier,
  }) {
    const fabSize = 40.0; // FloatingActionButton.small size
    const fabSpacing = 8.0;
    const footerHeight = 48.0; // Approximate footer bar height
    const totalHeight = fabSize + fabSpacing + footerHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Footer bar at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: EditorFooterBar(editTargetNotifier: editTargetNotifier),
          ),

          // FAB positioned above the footer bar
          Positioned(
            left: 16,
            top: 0,
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
      ),
    );
  }
}
