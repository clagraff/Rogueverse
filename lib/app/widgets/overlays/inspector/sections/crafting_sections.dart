import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

// ============================================================================
// Recipe Component Metadata
// ============================================================================

/// Metadata for the Recipe component.
///
/// Displays editors for inputs, outputs, required capabilities, and crafting ticks.
class RecipeMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 120);

  @override
  String get componentName => 'Recipe';

  @override
  bool hasComponent(Entity entity) => entity.has<Recipe>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Recipe>(entity.id),
      builder: (context, snapshot) {
        final recipe = entity.get<Recipe>();
        if (recipe == null) return const SizedBox.shrink();

        return _RecipeEditor(
          entity: entity,
          recipe: recipe,
          theme: _theme,
        );
      },
    );
  }

  @override
  Component createDefault() => Recipe(
        inputs: [],
        outputs: [],
        requiredCapabilities: {},
        craftingTicks: 1,
      );

  @override
  void removeComponent(Entity entity) => entity.remove<Recipe>();
}

/// Widget for editing a Recipe component.
class _RecipeEditor extends StatelessWidget {
  final Entity entity;
  final Recipe recipe;
  final PropertyPanelThemeData theme;

  const _RecipeEditor({
    required this.entity,
    required this.recipe,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crafting ticks
        PropertyRow(
          key: ValueKey('recipe_ticks_${recipe.craftingTicks}'),
          item: IntPropertyItem(
            id: "craftingTicks",
            label: "Crafting Ticks",
            value: recipe.craftingTicks,
            onChanged: (int val) {
              entity.upsert(Recipe(
                inputs: recipe.inputs,
                outputs: recipe.outputs,
                requiredCapabilities: recipe.requiredCapabilities,
                craftingTicks: val.clamp(1, 1000),
              ));
            },
          ),
          theme: theme,
        ),
        const SizedBox(height: 8),

        // Required capabilities
        _CapabilitiesEditor(
          entity: entity,
          recipe: recipe,
          theme: theme,
        ),
        const SizedBox(height: 12),

        // Inputs section
        _IngredientsSection(
          entity: entity,
          recipe: recipe,
          sectionTitle: 'Inputs',
          items: recipe.inputs,
          onAdd: () => _addInput(context),
          onUpdate: _updateInputs,
          onRemove: _removeInput,
        ),
        const SizedBox(height: 12),

        // Outputs section
        _OutputsSection(
          entity: entity,
          recipe: recipe,
          sectionTitle: 'Outputs',
          items: recipe.outputs,
          onAdd: () => _addOutput(context),
          onUpdate: _updateOutputs,
          onRemove: _removeOutput,
        ),
      ],
    );
  }

  void _addInput(BuildContext context) {
    final itemTemplates = _getItemTemplates();
    if (itemTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No item templates found. Create an Item template first.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    entity.upsert(Recipe(
      inputs: [...recipe.inputs, RecipeIngredient(templateId: itemTemplates.first.id, quantity: 1)],
      outputs: recipe.outputs,
      requiredCapabilities: recipe.requiredCapabilities,
      craftingTicks: recipe.craftingTicks,
    ));
  }

  void _updateInputs(List<RecipeIngredient> newInputs) {
    entity.upsert(Recipe(
      inputs: newInputs,
      outputs: recipe.outputs,
      requiredCapabilities: recipe.requiredCapabilities,
      craftingTicks: recipe.craftingTicks,
    ));
  }

  void _removeInput(int index) {
    final newInputs = List<RecipeIngredient>.from(recipe.inputs)..removeAt(index);
    _updateInputs(newInputs);
  }

  void _addOutput(BuildContext context) {
    final itemTemplates = _getItemTemplates();
    if (itemTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No item templates found. Create an Item template first.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    entity.upsert(Recipe(
      inputs: recipe.inputs,
      outputs: [...recipe.outputs, RecipeOutput(templateId: itemTemplates.first.id, quantity: 1)],
      requiredCapabilities: recipe.requiredCapabilities,
      craftingTicks: recipe.craftingTicks,
    ));
  }

  void _updateOutputs(List<RecipeOutput> newOutputs) {
    entity.upsert(Recipe(
      inputs: recipe.inputs,
      outputs: newOutputs,
      requiredCapabilities: recipe.requiredCapabilities,
      craftingTicks: recipe.craftingTicks,
    ));
  }

  void _removeOutput(int index) {
    final newOutputs = List<RecipeOutput>.from(recipe.outputs)..removeAt(index);
    _updateOutputs(newOutputs);
  }

  List<Entity> _getItemTemplates() {
    return entity.parentCell.entities()
        .where((e) => e.has<IsTemplate>() && e.has<Item>())
        .toList();
  }
}

/// Editor for required capabilities set.
class _CapabilitiesEditor extends StatelessWidget {
  final Entity entity;
  final Recipe recipe;
  final PropertyPanelThemeData theme;

  const _CapabilitiesEditor({
    required this.entity,
    required this.recipe,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final capabilities = recipe.requiredCapabilities.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                'Required Capabilities',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add, size: 16, color: scheme.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Add capability',
                onPressed: () => _showAddCapabilityDialog(context),
              ),
            ],
          ),
        ),
        if (capabilities.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'None (inventory craft)',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: capabilities.map((cap) {
              return Chip(
                label: Text(cap, style: const TextStyle(fontSize: 10)),
                deleteIcon: const Icon(Icons.close, size: 12),
                onDeleted: () => _removeCapability(cap),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAddCapabilityDialog(BuildContext context) {
    final controller = TextEditingController();
    final commonCapabilities = ['smelting', 'heating', 'cooking', 'crafting', 'shaping', 'refining'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Capability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Capability name',
                hintText: 'e.g., smelting',
              ),
              autofocus: true,
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  _addCapability(val.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Common:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: commonCapabilities
                  .where((c) => !recipe.requiredCapabilities.contains(c))
                  .map((cap) => ActionChip(
                        label: Text(cap, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          _addCapability(cap);
                          Navigator.of(context).pop();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addCapability(controller.text.trim());
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCapability(String capability) {
    entity.upsert(Recipe(
      inputs: recipe.inputs,
      outputs: recipe.outputs,
      requiredCapabilities: {...recipe.requiredCapabilities, capability},
      craftingTicks: recipe.craftingTicks,
    ));
  }

  void _removeCapability(String capability) {
    final newCapabilities = Set<String>.from(recipe.requiredCapabilities)..remove(capability);
    entity.upsert(Recipe(
      inputs: recipe.inputs,
      outputs: recipe.outputs,
      requiredCapabilities: newCapabilities,
      craftingTicks: recipe.craftingTicks,
    ));
  }
}

/// Section for editing recipe ingredients (inputs).
class _IngredientsSection extends StatelessWidget {
  final Entity entity;
  final Recipe recipe;
  final String sectionTitle;
  final List<RecipeIngredient> items;
  final VoidCallback onAdd;
  final void Function(List<RecipeIngredient>) onUpdate;
  final void Function(int) onRemove;

  const _IngredientsSection({
    required this.entity,
    required this.recipe,
    required this.sectionTitle,
    required this.items,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                '$sectionTitle (${items.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add, size: 16, color: scheme.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Add $sectionTitle',
                onPressed: onAdd,
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'No $sectionTitle. Click + to add.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _IngredientRow(
              key: ValueKey('ingredient_$index'),
              entity: entity,
              ingredient: item,
              index: index,
              onUpdate: (newItem) {
                final newList = List<RecipeIngredient>.from(items);
                newList[index] = newItem;
                onUpdate(newList);
              },
              onRemove: () => onRemove(index),
            );
          }),
      ],
    );
  }
}

/// Row for editing a single RecipeIngredient.
class _IngredientRow extends StatelessWidget {
  final Entity entity;
  final RecipeIngredient ingredient;
  final int index;
  final void Function(RecipeIngredient) onUpdate;
  final VoidCallback onRemove;

  const _IngredientRow({
    super.key,
    required this.entity,
    required this.ingredient,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemTemplates = entity.parentCell.entities()
        .where((e) => e.has<IsTemplate>() && e.has<Item>())
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: itemTemplates.any((t) => t.id == ingredient.templateId)
                  ? ingredient.templateId
                  : (itemTemplates.isNotEmpty ? itemTemplates.first.id : null),
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Template',
                labelStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
              style: const TextStyle(fontSize: 11),
              items: itemTemplates.map((template) {
                final name = template.get<Name>()?.name ??
                    template.get<IsTemplate>()?.displayName ??
                    'Template #${template.id}';
                return DropdownMenuItem<int>(
                  value: template.id,
                  child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                onUpdate(RecipeIngredient(templateId: val, quantity: ingredient.quantity));
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: TextFormField(
              initialValue: ingredient.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Qty',
                labelStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
              style: const TextStyle(fontSize: 11),
              onFieldSubmitted: (text) {
                final qty = int.tryParse(text) ?? 1;
                onUpdate(RecipeIngredient(templateId: ingredient.templateId, quantity: qty.clamp(1, 999)));
              },
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.close, size: 14, color: scheme.error),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Remove',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

/// Section for editing recipe outputs.
class _OutputsSection extends StatelessWidget {
  final Entity entity;
  final Recipe recipe;
  final String sectionTitle;
  final List<RecipeOutput> items;
  final VoidCallback onAdd;
  final void Function(List<RecipeOutput>) onUpdate;
  final void Function(int) onRemove;

  const _OutputsSection({
    required this.entity,
    required this.recipe,
    required this.sectionTitle,
    required this.items,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                '$sectionTitle (${items.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add, size: 16, color: scheme.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Add $sectionTitle',
                onPressed: onAdd,
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'No $sectionTitle. Click + to add.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _OutputRow(
              key: ValueKey('output_$index'),
              entity: entity,
              output: item,
              index: index,
              onUpdate: (newItem) {
                final newList = List<RecipeOutput>.from(items);
                newList[index] = newItem;
                onUpdate(newList);
              },
              onRemove: () => onRemove(index),
            );
          }),
      ],
    );
  }
}

/// Row for editing a single RecipeOutput.
class _OutputRow extends StatelessWidget {
  final Entity entity;
  final RecipeOutput output;
  final int index;
  final void Function(RecipeOutput) onUpdate;
  final VoidCallback onRemove;

  const _OutputRow({
    super.key,
    required this.entity,
    required this.output,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemTemplates = entity.parentCell.entities()
        .where((e) => e.has<IsTemplate>() && e.has<Item>())
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: itemTemplates.any((t) => t.id == output.templateId)
                  ? output.templateId
                  : (itemTemplates.isNotEmpty ? itemTemplates.first.id : null),
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Template',
                labelStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
              style: const TextStyle(fontSize: 11),
              items: itemTemplates.map((template) {
                final name = template.get<Name>()?.name ??
                    template.get<IsTemplate>()?.displayName ??
                    'Template #${template.id}';
                return DropdownMenuItem<int>(
                  value: template.id,
                  child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                onUpdate(RecipeOutput(templateId: val, quantity: output.quantity));
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: TextFormField(
              initialValue: output.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Qty',
                labelStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
              style: const TextStyle(fontSize: 11),
              onFieldSubmitted: (text) {
                final qty = int.tryParse(text) ?? 1;
                onUpdate(RecipeOutput(templateId: output.templateId, quantity: qty.clamp(1, 999)));
              },
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.close, size: 14, color: scheme.error),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Remove',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CraftingStation Component Metadata
// ============================================================================

/// Metadata for the CraftingStation component.
class CraftingStationMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 120);

  @override
  String get componentName => 'CraftingStation';

  @override
  bool hasComponent(Entity entity) => entity.has<CraftingStation>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<CraftingStation>(entity.id),
      builder: (context, snapshot) {
        final station = entity.get<CraftingStation>();
        if (station == null) return const SizedBox.shrink();

        return _CraftingStationEditor(
          entity: entity,
          station: station,
          theme: _theme,
        );
      },
    );
  }

  @override
  Component createDefault() => CraftingStation(capabilities: {});

  @override
  void removeComponent(Entity entity) => entity.remove<CraftingStation>();
}

/// Widget for editing a CraftingStation component.
class _CraftingStationEditor extends StatelessWidget {
  final Entity entity;
  final CraftingStation station;
  final PropertyPanelThemeData theme;

  const _CraftingStationEditor({
    required this.entity,
    required this.station,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final capabilities = station.capabilities.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Requires presence toggle
        PropertyRow(
          key: ValueKey('station_presence_${station.requiresPresence}'),
          item: BoolPropertyItem(
            id: "requiresPresence",
            label: "Requires Presence",
            value: station.requiresPresence,
            onChanged: (bool val) {
              entity.upsert(CraftingStation(
                capabilities: station.capabilities,
                requiresPresence: val,
              ));
            },
          ),
          theme: theme,
        ),
        const SizedBox(height: 8),

        // Capabilities
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                'Capabilities (${capabilities.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add, size: 16, color: scheme.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Add capability',
                onPressed: () => _showAddCapabilityDialog(context),
              ),
            ],
          ),
        ),
        if (capabilities.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'No capabilities defined.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: capabilities.map((cap) {
                return Chip(
                  label: Text(cap, style: const TextStyle(fontSize: 10)),
                  deleteIcon: const Icon(Icons.close, size: 12),
                  onDeleted: () => _removeCapability(cap),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showAddCapabilityDialog(BuildContext context) {
    final controller = TextEditingController();
    final commonCapabilities = ['smelting', 'heating', 'cooking', 'crafting', 'shaping', 'refining'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Capability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Capability name',
                hintText: 'e.g., smelting',
              ),
              autofocus: true,
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  _addCapability(val.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Common:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: commonCapabilities
                  .where((c) => !station.capabilities.contains(c))
                  .map((cap) => ActionChip(
                        label: Text(cap, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          _addCapability(cap);
                          Navigator.of(context).pop();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addCapability(controller.text.trim());
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCapability(String capability) {
    entity.upsert(CraftingStation(
      capabilities: {...station.capabilities, capability},
      requiresPresence: station.requiresPresence,
    ));
  }

  void _removeCapability(String capability) {
    final newCapabilities = Set<String>.from(station.capabilities)..remove(capability);
    entity.upsert(CraftingStation(
      capabilities: newCapabilities,
      requiresPresence: station.requiresPresence,
    ));
  }
}

// ============================================================================
// Processing Component Metadata (readonly - runtime state)
// ============================================================================

/// Metadata for the Processing component.
/// Displayed as readonly since this is runtime state.
class ProcessingMetadata extends ComponentMetadata {
  @override
  String get componentName => 'Processing';

  @override
  bool hasComponent(Entity entity) => entity.has<Processing>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Processing>(entity.id),
      builder: (context, snapshot) {
        final processing = entity.get<Processing>();
        if (processing == null) return const SizedBox.shrink();

        final scheme = Theme.of(context).colorScheme;

        // Get recipe name
        String recipeName = 'Unknown Recipe';
        try {
          final recipeTemplate = entity.parentCell.getEntity(processing.recipeTemplateId);
          recipeName = recipeTemplate.get<Name>()?.name ?? 'Recipe #${processing.recipeTemplateId}';
        } catch (_) {}

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Recipe', recipeName, scheme),
            _infoRow('Ticks Remaining', processing.ticksRemaining.toString(), scheme),
            _infoRow('Initiator ID', processing.initiatorEntityId.toString(), scheme),
            if (processing.awaitingSpace)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Awaiting inventory space',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Component createDefault() => Processing(
        recipeTemplateId: 0,
        ticksRemaining: 1,
        initiatorEntityId: 0,
      );

  @override
  void removeComponent(Entity entity) => entity.remove<Processing>();
}

// ============================================================================
// Busy Component Metadata
// ============================================================================

/// Metadata for the Busy component.
class BusyMetadata extends ComponentMetadata {
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 80);

  @override
  String get componentName => 'Busy';

  @override
  bool hasComponent(Entity entity) => entity.has<Busy>();

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Busy>(entity.id),
      builder: (context, snapshot) {
        final busy = entity.get<Busy>();
        if (busy == null) return const SizedBox.shrink();

        return PropertyRow(
          key: ValueKey('busy_${busy.activity}'),
          item: StringPropertyItem(
            id: "activity",
            label: "Activity",
            value: busy.activity,
            onChanged: (String val) {
              entity.upsert(Busy(activity: val));
            },
          ),
          theme: _theme,
        );
      },
    );
  }

  @override
  Component createDefault() => Busy(activity: 'crafting');

  @override
  void removeComponent(Entity entity) => entity.remove<Busy>();
}

// ============================================================================
// Intent Metadata (readonly for debugging)
// ============================================================================

/// Metadata for CraftIntent.
class CraftIntentMetadata extends ComponentMetadata {
  @override
  String get componentName => 'CraftIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<CraftIntent>();

  @override
  Widget buildContent(Entity entity) {
    final intent = entity.get<CraftIntent>();
    if (intent == null) return const SizedBox.shrink();

    return _ReadonlyIdRow(
      label: 'Recipe Template ID',
      value: intent.recipeTemplateId,
    );
  }

  @override
  Component createDefault() => CraftIntent(recipeTemplateId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<CraftIntent>();
}

/// Metadata for StationCraftIntent.
class StationCraftIntentMetadata extends ComponentMetadata {
  @override
  String get componentName => 'StationCraftIntent';

  @override
  bool hasComponent(Entity entity) => entity.has<StationCraftIntent>();

  @override
  Widget buildContent(Entity entity) {
    final intent = entity.get<StationCraftIntent>();
    if (intent == null) return const SizedBox.shrink();

    return Column(
      children: [
        _ReadonlyIdRow(label: 'Station ID', value: intent.stationEntityId),
        _ReadonlyIdRow(label: 'Recipe Template ID', value: intent.recipeTemplateId),
      ],
    );
  }

  @override
  Component createDefault() => StationCraftIntent(stationEntityId: 0, recipeTemplateId: 0);

  @override
  void removeComponent(Entity entity) => entity.remove<StationCraftIntent>();
}

// ============================================================================
// Event Metadata (readonly for debugging)
// ============================================================================

/// Metadata for DidStartCrafting.
class DidStartCraftingMetadata extends ComponentMetadata {
  @override
  String get componentName => 'DidStartCrafting';

  @override
  bool hasComponent(Entity entity) => entity.has<DidStartCrafting>();

  @override
  Widget buildContent(Entity entity) {
    final event = entity.get<DidStartCrafting>();
    if (event == null) return const SizedBox.shrink();

    return Column(
      children: [
        _ReadonlyIdRow(label: 'Recipe ID', value: event.recipeTemplateId),
        _ReadonlyBoolRow(label: 'Instant', value: event.isInstant),
      ],
    );
  }

  @override
  Component createDefault() => DidStartCrafting(recipeTemplateId: 0, isInstant: true);

  @override
  void removeComponent(Entity entity) => entity.remove<DidStartCrafting>();
}

/// Metadata for DidCompleteCrafting.
class DidCompleteCraftingMetadata extends ComponentMetadata {
  @override
  String get componentName => 'DidCompleteCrafting';

  @override
  bool hasComponent(Entity entity) => entity.has<DidCompleteCrafting>();

  @override
  Widget buildContent(Entity entity) {
    final event = entity.get<DidCompleteCrafting>();
    if (event == null) return const SizedBox.shrink();

    return Column(
      children: [
        _ReadonlyIdRow(label: 'Recipe ID', value: event.recipeTemplateId),
        _ReadonlyTextRow(label: 'Produced', value: event.producedEntityIds.join(', ')),
      ],
    );
  }

  @override
  Component createDefault() =>
      DidCompleteCrafting(recipeTemplateId: 0, producedEntityIds: []);

  @override
  void removeComponent(Entity entity) => entity.remove<DidCompleteCrafting>();
}

/// Metadata for CraftingFailed.
class CraftingFailedMetadata extends ComponentMetadata {
  @override
  String get componentName => 'CraftingFailed';

  @override
  bool hasComponent(Entity entity) => entity.has<CraftingFailed>();

  @override
  Widget buildContent(Entity entity) {
    final event = entity.get<CraftingFailed>();
    if (event == null) return const SizedBox.shrink();

    return Column(
      children: [
        _ReadonlyIdRow(label: 'Recipe ID', value: event.recipeTemplateId),
        _ReadonlyTextRow(label: 'Reason', value: event.reason.name),
      ],
    );
  }

  @override
  Component createDefault() => CraftingFailed(
        recipeTemplateId: 0,
        reason: CraftingFailureReason.recipeNotFound,
      );

  @override
  void removeComponent(Entity entity) => entity.remove<CraftingFailed>();
}

// ============================================================================
// Helper Widgets
// ============================================================================

class _ReadonlyIdRow extends StatelessWidget {
  final String label;
  final int value;

  const _ReadonlyIdRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ReadonlyBoolRow extends StatelessWidget {
  final String label;
  final bool value;

  const _ReadonlyBoolRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Icon(
            value ? Icons.check : Icons.close,
            size: 14,
            color: value ? scheme.primary : scheme.error,
          ),
        ],
      ),
    );
  }
}

class _ReadonlyTextRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadonlyTextRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
