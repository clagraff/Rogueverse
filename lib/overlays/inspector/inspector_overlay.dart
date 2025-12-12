import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/widgets/properties/properties.dart';


class InspectorOverlay extends StatefulWidget {
  final ValueNotifier<Entity?> entityNotifier;

  const InspectorOverlay({super.key, required this.entityNotifier});

  @override
  State<InspectorOverlay> createState() => _InspectorOverlayState();
}

class _InspectorOverlayState extends State<InspectorOverlay> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Entity?>(
      valueListenable: widget.entityNotifier,
      builder: (context, entity, child) {
        if (entity == null) {
          return const SizedBox.shrink();
        }
        // Keying by entity.id ensures the panel resets state (like scroll position) when the entity changes.
        return _InspectorPanel(key: ValueKey(entity.id), entity: entity);
      },
    );
  }
}

class _InspectorPanel extends StatefulWidget {
  final Entity entity;

  const _InspectorPanel({super.key, required this.entity});

  @override
  State<_InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<_InspectorPanel> {

  void _updateComponentField(Component component, String key, dynamic value) {
    // 1. Convert component to Map
    final map = MapperContainer.globals.toMap(component) as Map<String, dynamic>;

    // 2. Update the specific field
    map[key] = value;

    try {
      // 3. Convert back to Component using the global container.
      // Note: This relies on dart_mappable being able to infer the type or the map containing type info.
      final newComponent = MapperContainer.globals.fromMap<Component>(map);

      // 4. Save back to entity
      setState(() {
        widget.entity.upsert(newComponent);
      });
    } catch (e) {
      debugPrint("Failed to update component: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final components = widget.entity.getAll();
    final sections = <PropertySectionData>[];

    var name = widget.entity.get<Name>();
    if (name != null) {
      sections.add(PropertySectionData(id: "", title: "Name", items: [
        StringPropertyItem(id: "", label: "Name", value: name.name, onChanged: (String s) {
          widget.entity.upsert<Name>(name.copyWith(name: s));
        })
      ]));
    }

    var localPosition = widget.entity.get<LocalPosition>();
    if (localPosition != null) {
      sections.add(PropertySectionData(id: "", title: "LocalPosition", items: [
        IntPropertyItem(id: "", label: "X", value: localPosition.x, onChanged: (int newX) {
          widget.entity.upsert<LocalPosition>(localPosition.copyWith(x: newX));
        }),
        IntPropertyItem(id: "", label: "Y", value: localPosition.y, onChanged: (int newY) {
          widget.entity.upsert<LocalPosition>(localPosition.copyWith(y: newY));
        }),
      ]));
    }

    // for (var component in components) {
    //   // Convert component to a Map to inspect its properties
    //   final properties = MapperContainer.globals.toMap(component);
    //   final items = <PropertyItem>[];
    //
    //   properties.forEach((key, value) {
    //     // Skip internal keys if any (like discriminator keys usually starting with __)
    //     if (key.startsWith('__')) return;
    //
    //     if (value is bool) {
    //       items.add(BoolPropertyItem(
    //         id: key,
    //         label: key, // Capitalize or format if desired
    //         value: value,
    //         onChanged: (v) => _updateComponentField(component, key, v),
    //       ));
    //     } else if (value is int) {
    //       // Use DoubleItem for numbers, but cast back to int on save
    //       items.add(DoublePropertyItem(
    //         id: key,
    //         label: key,
    //         value: value.toDouble(),
    //         onChanged: (v) => _updateComponentField(component, key, v.toInt()),
    //       ));
    //     } else if (value is double) {
    //       items.add(DoublePropertyItem(
    //         id: key,
    //         label: key,
    //         value: value,
    //         onChanged: (v) => _updateComponentField(component, key, v),
    //       ));
    //     } else {
    //       // Fallback for Strings, Lists, or complex objects
    //       items.add(ReadonlyPropertyItem(
    //         id: key,
    //         label: key,
    //         value: value.toString(),
    //       ));
    //     }
    //   });
    //
    //   sections.add(PropertySectionData(
    //     id: component.componentType,
    //     title: component.componentType,
    //     items: items,
    //   ));
    // }

    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: PropertyPanel(
        sections: sections,
        theme: const PropertyPanelThemeData(
          minWidth: 260,
          maxWidth: 360,
          labelColumnWidth: 140,
        ),
      ),
    );
  }
}


