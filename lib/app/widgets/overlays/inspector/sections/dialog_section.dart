import 'package:flutter/material.dart' hide Dialog;
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/ecs/dialog/dialog.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/screens/dialog_editor_screen.dart';

/// Metadata for the Dialog component.
///
/// Displays a button to open the dialog tree editor screen.
class DialogMetadata extends ComponentMetadata {
  @override
  String get componentName => 'Dialog';

  @override
  bool hasComponent(Entity entity) => entity.has<Dialog>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Dialog>(entity.id),
      builder: (context, snapshot) {
        final dialog = entity.get<Dialog>();
        if (dialog == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dialog Tree',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Root: ${dialog.root.runtimeType}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DialogEditorScreen(entity: entity),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Dialog Tree'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Component createDefault() {
    // Create a default dialog with a simple speak node
    return Dialog(
      const SpeakNode(
        speakerName: 'Speaker',
        text: 'Hello!',
        choices: [
          Choice(
            text: 'Goodbye',
            child: EndNode(),
          ),
        ],
      ),
    );
  }

  @override
  void removeComponent(Entity entity) => entity.remove<Dialog>();
}
