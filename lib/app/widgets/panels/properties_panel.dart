import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_section.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/inherited_component_section.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/add_component_button.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/entity_navigator.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/save_as_template_button.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/section_headers.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/direct_component_section.dart';

/// Panel showing the currently selected entity's components for editing.
///
/// Displays all components on the selected entity with editable fields,
/// and provides buttons to add new components or save as template.
class PropertiesPanel extends StatefulWidget {
  final ValueNotifier<Entity?> entityNotifier;
  final ValueNotifier<Set<Entity>>? selectedEntitiesNotifier;

  const PropertiesPanel({
    super.key,
    required this.entityNotifier,
    this.selectedEntitiesNotifier,
  });

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  final ValueNotifier<bool> _showTransient = ValueNotifier(false);

  @override
  void dispose() {
    _showTransient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If multi-select notifier is provided, wrap in builder to check selection count
    if (widget.selectedEntitiesNotifier != null) {
      return ValueListenableBuilder<Set<Entity>>(
        valueListenable: widget.selectedEntitiesNotifier!,
        builder: (context, selectedEntities, _) {
          if (selectedEntities.length > 1) {
            return ValueListenableBuilder<bool>(
              valueListenable: _showTransient,
              builder: (context, showTransientValue, _) {
                return Column(
                  children: [
                    _buildSectionHeader(context, showTransientValue),
                    Expanded(child: _buildMultiSelectState(context, selectedEntities.length)),
                  ],
                );
              },
            );
          }
          return _buildMainContent(context);
        },
      );
    }
    return _buildMainContent(context);
  }

  Widget _buildMainContent(BuildContext context) {
    return EntityNavigator(
      onNavigateToEntity: _navigateToEntity,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showTransient,
        builder: (context, showTransientValue, _) {
          return Column(
            children: [
              // Section header
              _buildSectionHeader(context, showTransientValue),
              // Component list
              Expanded(
                child: ValueListenableBuilder<Entity?>(
                  valueListenable: widget.entityNotifier,
                  builder: (context, entity, _) {
                    if (entity == null) {
                      return _buildEmptyState(context);
                    }

                    return StreamBuilder<Change>(
                      stream: entity.parentCell.componentChanges.onEntityChange(entity.id),
                      builder: (context, snapshot) {
                        // Check if entity has a template
                        final hasTemplate = entity.getTemplateEntity() != null;

                        if (hasTemplate) {
                          return _buildSplitView(
                            context,
                            entity,
                            showTransientValue,
                          );
                        } else {
                          return _buildFlatView(
                            context,
                            entity,
                            showTransientValue,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Navigate to a specific entity by selecting it in the inspector.
  void _navigateToEntity(Entity entity) {
    // Set the entity in both notifiers - selectedEntitiesNotifier takes precedence
    // in some listeners, so we need to include the entity there too
    widget.selectedEntitiesNotifier?.value = {entity};
    widget.entityNotifier.value = entity;
  }

  /// Builds the flat view for entities without templates (original behavior).
  Widget _buildFlatView(
    BuildContext context,
    Entity entity,
    bool showTransient,
  ) {
    var presentComponents = ComponentRegistry.getPresent(entity);
    if (!showTransient) {
      presentComponents = presentComponents
          .where((m) => !m.isTransient)
          .toList();
    }
    presentComponents.sort((a, b) => a.componentName.compareTo(b.componentName));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 2),
      children: [
        ...presentComponents.map(
          (metadata) => ComponentSection(
            entity: entity,
            metadata: metadata,
          ),
        ),
        AddComponentButton(
          entity: entity,
          showTransient: showTransient,
        ),
      ],
    );
  }

  /// Builds the split view for entities with templates.
  /// Shows direct components section and inherited components section separately.
  Widget _buildSplitView(
    BuildContext context,
    Entity entity,
    bool showTransient,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final templateEntity = entity.getTemplateEntity()!;
    final templateName = templateEntity.get<Name>()?.name ?? 'Template';

    // Get direct components
    var directComponents = ComponentRegistry.getDirectPresent(entity);
    if (!showTransient) {
      directComponents = directComponents.where((m) => !m.isTransient).toList();
    }
    directComponents.sort((a, b) => a.componentName.compareTo(b.componentName));

    // Get inherited (active) components
    var inheritedComponents = ComponentRegistry.getInheritedPresent(entity);
    if (!showTransient) {
      inheritedComponents = inheritedComponents.where((m) => !m.isTransient).toList();
    }
    inheritedComponents.sort((a, b) => a.componentName.compareTo(b.componentName));

    // Get excluded components
    var excludedComponents = ComponentRegistry.getExcludedTypes(entity);
    if (!showTransient) {
      excludedComponents = excludedComponents.where((m) => !m.isTransient).toList();
    }
    excludedComponents.sort((a, b) => a.componentName.compareTo(b.componentName));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 2),
      children: [
        // Direct Components Section Header
        ComponentSectionHeader(
          title: 'Direct Components',
          count: directComponents.length,
          color: colorScheme.primary,
        ),

        // Direct component sections
        ...directComponents.map(
          (metadata) => DirectComponentSection(
            entity: entity,
            metadata: metadata,
          ),
        ),

        // Add Component button
        AddComponentButton(
          entity: entity,
          showTransient: showTransient,
        ),

        const SizedBox(height: 8),

        // From Template Section Header
        TemplateSectionHeader(
          templateName: templateName,
          count: inheritedComponents.length + excludedComponents.length,
          color: colorScheme.tertiary,
          onEditTemplate: () => _navigateToTemplate(entity),
        ),

        // Active inherited components
        ...inheritedComponents.map(
          (metadata) => InheritedComponentSection(
            entity: entity,
            metadata: metadata,
            isExcluded: false,
          ),
        ),

        // Excluded components (greyed out)
        ...excludedComponents.map(
          (metadata) => InheritedComponentSection(
            entity: entity,
            metadata: metadata,
            isExcluded: true,
          ),
        ),
      ],
    );
  }

  /// Navigate to the template entity when "Edit Template" is clicked.
  void _navigateToTemplate(Entity entity) {
    final templateEntity = entity.getTemplateEntity();
    if (templateEntity != null) {
      // Clear multi-selection if present
      widget.selectedEntitiesNotifier?.value = {};
      widget.entityNotifier.value = templateEntity;
    }
  }

  Widget _buildSectionHeader(BuildContext context, bool showTransientValue) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Properties',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          // Toggle visibility of transient components
          Tooltip(
            message: showTransientValue
                ? 'Hide transient components'
                : 'Show transient components',
            child: InkWell(
              onTap: () => _showTransient.value = !_showTransient.value,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  showTransientValue ? Icons.visibility : Icons.visibility_off,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Save as template button (only shown when entity selected)
          ValueListenableBuilder<Entity?>(
            valueListenable: widget.entityNotifier,
            builder: (context, entity, _) {
              if (entity == null) return const SizedBox.shrink();
              return SaveAsTemplateButton(entity: entity);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectState(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.select_all,
              size: 32,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              '$count entities selected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a single entity to edit',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 32,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No entity selected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Click an entity to edit',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
