import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/components.dart';
import 'package:rogueverse/ecs/entity.dart';
import 'package:rogueverse/ecs/events.dart';
import 'package:rogueverse/app/screens/dialog_editor_screen.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/entity_navigator.dart';
import 'package:rogueverse/app/ui_constants.dart';

/// Metadata for the DialogRef component.
///
/// DialogRef points to the starting dialog node for an NPC.
class DialogRefMetadata extends ComponentMetadata {
  @override
  String get componentName => 'DialogRef';

  @override
  bool hasComponent(Entity entity) => entity.has<DialogRef>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DialogRef>(entity.id),
      builder: (context, snapshot) {
        final dialogRef = entity.get<DialogRef>();
        if (dialogRef == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(kSpacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogNodeDropdown(
                label: 'Root Node',
                world: entity.parentCell,
                selectedNodeId: dialogRef.rootNodeId,
                allowNull: false,
                onChanged: (nodeId) {
                  if (nodeId != null) {
                    entity.upsert(DialogRef(rootNodeId: nodeId));
                  }
                },
                onCreateNew: () {
                  final npcName = entity.get<Name>()?.name ?? 'NPC';
                  final newNode = entity.parentCell.add([
                    DialogNode(
                      text: 'Hello!',
                      choices: [DialogChoice(text: 'Goodbye')],
                    ),
                    Name(name: '$npcName Dialog'),
                  ]);
                  entity.upsert(DialogRef(rootNodeId: newNode.id));
                  // Navigate to the new node
                  EntityNavigator.navigateTo(context, newNode);
                },
              ),
              const SizedBox(height: kSpacingM),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DialogEditorScreen(entity: entity),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Dialog'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Component createDefault() => DialogRef(rootNodeId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<DialogRef>();
}

/// Metadata for the DialogNode component.
///
/// DialogNode contains the text and choices for a dialog node entity.
class DialogNodeMetadata extends ComponentMetadata {
  @override
  String get componentName => 'DialogNode';

  @override
  bool hasComponent(Entity entity) => entity.has<DialogNode>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DialogNode>(entity.id),
      builder: (context, snapshot) {
        final dialogNode = entity.get<DialogNode>();
        if (dialogNode == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(kSpacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text field
              _buildTextField(
                context,
                entity,
                'Text',
                dialogNode.text,
                (value) {
                  entity.upsert(DialogNode(
                    text: value,
                    choices: dialogNode.choices,
                  ));
                },
                maxLines: 4,
              ),
              const SizedBox(height: kSpacingM),

              // Choices list
              Text(
                'Choices (${dialogNode.choices.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: kSpacingS),

              ...dialogNode.choices.asMap().entries.map((entry) {
                final index = entry.key;
                final choice = entry.value;
                return _ChoiceEditor(
                  key: ValueKey('${entity.id}-choice-$index'),
                  entity: entity,
                  dialogNode: dialogNode,
                  index: index,
                  choice: choice,
                );
              }),

              const SizedBox(height: kSpacingS),

              // Add choice button
              TextButton.icon(
                onPressed: () {
                  final newChoices = [...dialogNode.choices, DialogChoice(text: 'New choice')];
                  entity.upsert(DialogNode(
                    text: dialogNode.text,
                    choices: newChoices,
                  ));
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Choice'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Component createDefault() => DialogNode(
    text: 'Hello!',
    choices: [
      DialogChoice(text: 'Goodbye'),
    ],
  );

  @override
  void removeComponent(Entity entity) => entity.remove<DialogNode>();
}

/// Widget for editing a single choice in a DialogNode.
class _ChoiceEditor extends StatelessWidget {
  final Entity entity;
  final DialogNode dialogNode;
  final int index;
  final DialogChoice choice;

  const _ChoiceEditor({
    super.key,
    required this.entity,
    required this.dialogNode,
    required this.index,
    required this.choice,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: kSpacingS),
      padding: const EdgeInsets.all(kSpacingS),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(kRadiusS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${index + 1}.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
                onPressed: () {
                  final newChoices = [...dialogNode.choices]..removeAt(index);
                  entity.upsert(DialogNode(
                    text: dialogNode.text,
                    choices: newChoices,
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: kSpacingXS),

          // Choice text
          TextFormField(
            initialValue: choice.text,
            decoration: const InputDecoration(
              labelText: 'Text',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            onFieldSubmitted: (value) {
              final newChoices = [...dialogNode.choices];
              newChoices[index] = DialogChoice(
                text: value,
                targetNodeId: choice.targetNodeId,
              );
              entity.upsert(DialogNode(
                text: dialogNode.text,
                choices: newChoices,
              ));
            },
          ),
          const SizedBox(height: kSpacingXS),

          // Target node dropdown
          _DialogNodeDropdown(
            label: 'Target Node',
            world: entity.parentCell,
            selectedNodeId: choice.targetNodeId,
            allowNull: true,
            onChanged: (nodeId) {
              final newChoices = [...dialogNode.choices];
              newChoices[index] = DialogChoice(
                text: choice.text,
                targetNodeId: nodeId,
              );
              entity.upsert(DialogNode(
                text: dialogNode.text,
                choices: newChoices,
              ));
            },
            onCreateNew: () {
              // Create a new node and link to it
              final currentName = entity.get<Name>()?.name ?? 'Dialog';
              final newNode = entity.parentCell.add([
                DialogNode(
                  text: 'Continue...',
                  choices: [DialogChoice(text: 'End')],
                ),
                Name(name: '$currentName > Choice ${index + 1}'),
              ]);

              // Update this choice to point to the new node
              final newChoices = [...dialogNode.choices];
              newChoices[index] = DialogChoice(
                text: choice.text,
                targetNodeId: newNode.id,
              );
              entity.upsert(DialogNode(
                text: dialogNode.text,
                choices: newChoices,
              ));

              // Navigate to the new node
              EntityNavigator.navigateTo(context, newNode);
            },
          ),
        ],
      ),
    );
  }
}

/// Dropdown widget for selecting a DialogNode entity.
class _DialogNodeDropdown extends StatelessWidget {
  final String label;
  final dynamic world; // IWorldView
  final int? selectedNodeId;
  final bool allowNull;
  final void Function(int? nodeId) onChanged;
  final VoidCallback onCreateNew;

  const _DialogNodeDropdown({
    required this.label,
    required this.world,
    required this.selectedNodeId,
    required this.allowNull,
    required this.onChanged,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get all entities with DialogNode component
    final dialogNodes = world.get<DialogNode>() as Map<int, DialogNode>;
    final nodeEntities = <({int id, String name, Entity entity})>[];
    for (final entry in dialogNodes.entries) {
      final entity = world.getEntity(entry.key) as Entity;
      final name = entity.get<Name>()?.name ?? 'Unnamed';
      nodeEntities.add((id: entry.key, name: name, entity: entity));
    }

    // Sort by name
    nodeEntities.sort((a, b) => a.name.compareTo(b.name));

    // Check if the selected node is valid
    final selectedExists = selectedNodeId != null &&
        dialogNodes.containsKey(selectedNodeId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: kSpacingXS),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                value: selectedExists ? selectedNodeId : (allowNull ? null : -1),
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                style: Theme.of(context).textTheme.bodySmall,
                isExpanded: true,
                items: [
                  if (allowNull)
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        '(End dialog)',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  if (!selectedExists && selectedNodeId != null && selectedNodeId != 0)
                    DropdownMenuItem<int?>(
                      value: -1,
                      child: Text(
                        'Invalid: $selectedNodeId',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ...nodeEntities.map((node) => DropdownMenuItem<int?>(
                    value: node.id,
                    child: Text('${node.name} (#${node.id})'),
                  )),
                ],
                onChanged: (value) {
                  if (value != -1) {
                    onChanged(value);
                  }
                },
              ),
            ),
            const SizedBox(width: kSpacingXS),
            // Go to button
            if (selectedExists)
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxWidth: 28, maxHeight: 28),
                tooltip: 'Go to node',
                onPressed: () {
                  final targetEntity = world.getEntity(selectedNodeId!);
                  EntityNavigator.navigateTo(context, targetEntity);
                },
              ),
            // Create new button
            IconButton(
              icon: const Icon(Icons.add, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxWidth: 28, maxHeight: 28),
              tooltip: 'Create new node',
              onPressed: onCreateNew,
            ),
          ],
        ),
      ],
    );
  }
}

/// Metadata for the ActiveDialog component.
///
/// ActiveDialog tracks the current dialog state on the player entity.
/// This is a transient component set by the DialogSystem.
class ActiveDialogMetadata extends ComponentMetadata {
  @override
  String get componentName => 'ActiveDialog';

  @override
  bool get isTransient => true;

  @override
  bool hasComponent(Entity entity) => entity.has<ActiveDialog>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<ActiveDialog>(entity.id),
      builder: (context, snapshot) {
        final active = entity.get<ActiveDialog>();
        if (active == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(kSpacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField(context, 'NPC Entity ID', active.npcEntityId.toString()),
              const SizedBox(height: kSpacingS),
              _buildReadOnlyField(context, 'Current Node ID', active.currentNodeId.toString()),
            ],
          ),
        );
      },
    );
  }

  @override
  Component createDefault() => ActiveDialog(npcEntityId: 0, currentNodeId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<ActiveDialog>();
}

/// Metadata for the TalkIntent component.
///
/// TalkIntent is the intent to start a dialog with an NPC.
class TalkIntentMetadata extends ComponentMetadata {
  @override
  String get componentName => 'TalkIntent';

  @override
  bool get isTransient => true;

  @override
  bool hasComponent(Entity entity) => entity.has<TalkIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<TalkIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<TalkIntent>();
        if (intent == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(kSpacingM),
          child: _buildReadOnlyField(context, 'Target Entity ID', intent.targetEntityId.toString()),
        );
      },
    );
  }

  @override
  Component createDefault() => TalkIntent(targetEntityId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<TalkIntent>();
}

/// Metadata for the DialogAdvanceIntent component.
class DialogAdvanceIntentMetadata extends ComponentMetadata {
  @override
  String get componentName => 'DialogAdvanceIntent';

  @override
  bool get isTransient => true;

  @override
  bool hasComponent(Entity entity) => entity.has<DialogAdvanceIntent>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<DialogAdvanceIntent>(entity.id),
      builder: (context, snapshot) {
        final intent = entity.get<DialogAdvanceIntent>();
        if (intent == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(kSpacingM),
          child: _buildReadOnlyField(context, 'Choice Index', intent.choiceIndex.toString()),
        );
      },
    );
  }

  @override
  Component createDefault() => DialogAdvanceIntent(choiceIndex: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<DialogAdvanceIntent>();
}

/// Metadata for the DialogExitIntent component.
class DialogExitIntentMetadata extends ComponentMetadata {
  @override
  String get componentName => 'DialogExitIntent';

  @override
  bool get isTransient => true;

  @override
  bool hasComponent(Entity entity) => entity.has<DialogExitIntent>();

  @override
  Widget buildContent(Entity entity) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(kSpacingM),
          child: Text(
            'Exit intent (no fields)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        );
      },
    );
  }

  @override
  Component createDefault() => DialogExitIntent();

  @override
  void removeComponent(Entity entity) => entity.remove<DialogExitIntent>();
}

// Helper widgets

Widget _buildTextField(
  BuildContext context,
  Entity entity,
  String label,
  String value,
  void Function(String) onSubmit, {
  int maxLines = 1,
  Key? key,
}) {
  // For multiline fields, use onChanged since Enter adds newlines instead of submitting
  final isMultiline = maxLines > 1;

  return TextFormField(
    key: key ?? ValueKey('${entity.id}-$label'),
    initialValue: value,
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      border: const OutlineInputBorder(),
      helperText: isMultiline ? null : null,
    ),
    style: Theme.of(context).textTheme.bodySmall,
    maxLines: maxLines,
    onFieldSubmitted: isMultiline ? null : onSubmit,
    onChanged: isMultiline ? onSubmit : null,
  );
}

Widget _buildReadOnlyField(BuildContext context, String label, String value) {
  final colorScheme = Theme.of(context).colorScheme;
  return Row(
    children: [
      Text(
        '$label: ',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      Text(
        value,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
