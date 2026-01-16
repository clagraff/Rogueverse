import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/dialog/dialog.dart';

/// Editor widget for selecting and configuring a DialogCondition.
///
/// Provides a dropdown to select condition type and type-specific fields.
class ConditionEditor extends StatelessWidget {
  final DialogCondition? condition;
  final void Function(DialogCondition?) onUpdate;

  const ConditionEditor({
    super.key,
    required this.condition,
    required this.onUpdate,
  });

  static const List<_ConditionType> _conditionTypes = [
    _ConditionType('none', 'None', 'No condition - always available'),
    _ConditionType('always', 'Always', 'Always passes'),
    _ConditionType('never', 'Never', 'Never passes (disabled)'),
    _ConditionType('hasItem', 'Has Item', 'Check if player has an item'),
    _ConditionType('health', 'Health', 'Check player health'),
    _ConditionType('hasComponent', 'Has Component', 'Check for a component'),
    _ConditionType('not', 'Not', 'Inverts another condition'),
    _ConditionType('all', 'All (AND)', 'All conditions must pass'),
    _ConditionType('any', 'Any (OR)', 'Any condition must pass'),
  ];

  String _getConditionTypeId() {
    if (condition == null) return 'none';
    if (condition is AlwaysCondition) return 'always';
    if (condition is NeverCondition) return 'never';
    if (condition is HasItemCondition) return 'hasItem';
    if (condition is HealthCondition) return 'health';
    if (condition is HasComponentCondition) return 'hasComponent';
    if (condition is NotCondition) return 'not';
    if (condition is AllCondition) return 'all';
    if (condition is AnyCondition) return 'any';
    return 'none';
  }

  void _onTypeChanged(String? typeId) {
    if (typeId == null) return;

    switch (typeId) {
      case 'none':
        onUpdate(null);
        break;
      case 'always':
        onUpdate(const AlwaysCondition());
        break;
      case 'never':
        onUpdate(const NeverCondition());
        break;
      case 'hasItem':
        onUpdate(const HasItemCondition(itemIdentifier: 'Item Name'));
        break;
      case 'health':
        onUpdate(const HealthCondition(minPercentage: 0.5));
        break;
      case 'hasComponent':
        onUpdate(const HasComponentCondition(componentType: 'ComponentName'));
        break;
      case 'not':
        onUpdate(const NotCondition(AlwaysCondition()));
        break;
      case 'all':
        onUpdate(const AllCondition([AlwaysCondition()]));
        break;
      case 'any':
        onUpdate(const AnyCondition([AlwaysCondition()]));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTypeId = _getConditionTypeId();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: currentTypeId,
          isExpanded: true,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: _conditionTypes.map((type) {
            return DropdownMenuItem(
              value: type.id,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: _onTypeChanged,
        ),

        // Type-specific fields
        if (condition != null) ...[
          const SizedBox(height: 8),
          _buildConditionFields(context),
        ],
      ],
    );
  }

  Widget _buildConditionFields(BuildContext context) {
    if (condition is HasItemCondition) {
      return _HasItemFields(
        condition: condition as HasItemCondition,
        onUpdate: onUpdate,
      );
    } else if (condition is HealthCondition) {
      return _HealthFields(
        condition: condition as HealthCondition,
        onUpdate: onUpdate,
      );
    } else if (condition is HasComponentCondition) {
      return _HasComponentFields(
        condition: condition as HasComponentCondition,
        onUpdate: onUpdate,
      );
    } else if (condition is NotCondition) {
      return _NotFields(
        condition: condition as NotCondition,
        onUpdate: onUpdate,
      );
    } else if (condition is AllCondition) {
      return _CompositeFields(
        label: 'All Conditions (AND)',
        conditions: (condition as AllCondition).conditions,
        onUpdate: (conditions) => onUpdate(AllCondition(conditions)),
      );
    } else if (condition is AnyCondition) {
      return _CompositeFields(
        label: 'Any Condition (OR)',
        conditions: (condition as AnyCondition).conditions,
        onUpdate: (conditions) => onUpdate(AnyCondition(conditions)),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ConditionType {
  final String id;
  final String name;
  final String description;

  const _ConditionType(this.id, this.name, this.description);
}

/// Fields for HasItemCondition.
class _HasItemFields extends StatelessWidget {
  final HasItemCondition condition;
  final void Function(DialogCondition?) onUpdate;

  const _HasItemFields({
    required this.condition,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildField(
          context: context,
          label: 'Item Name',
          value: condition.itemIdentifier,
          onChanged: (value) {
            onUpdate(HasItemCondition(
              itemIdentifier: value,
              minCount: condition.minCount,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildIntField(
          context: context,
          label: 'Minimum Count',
          value: condition.minCount,
          onChanged: (value) {
            onUpdate(HasItemCondition(
              itemIdentifier: condition.itemIdentifier,
              minCount: value,
            ));
          },
        ),
      ],
    );
  }
}

/// Fields for HealthCondition.
class _HealthFields extends StatelessWidget {
  final HealthCondition condition;
  final void Function(DialogCondition?) onUpdate;

  const _HealthFields({
    required this.condition,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOptionalIntField(
          context: context,
          label: 'Min Health (absolute)',
          value: condition.minHealth,
          onChanged: (value) {
            onUpdate(HealthCondition(
              minHealth: value,
              maxHealth: condition.maxHealth,
              minPercentage: condition.minPercentage,
              maxPercentage: condition.maxPercentage,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildOptionalIntField(
          context: context,
          label: 'Max Health (absolute)',
          value: condition.maxHealth,
          onChanged: (value) {
            onUpdate(HealthCondition(
              minHealth: condition.minHealth,
              maxHealth: value,
              minPercentage: condition.minPercentage,
              maxPercentage: condition.maxPercentage,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildOptionalDoubleField(
          context: context,
          label: 'Min Percentage (0.0 - 1.0)',
          value: condition.minPercentage,
          onChanged: (value) {
            onUpdate(HealthCondition(
              minHealth: condition.minHealth,
              maxHealth: condition.maxHealth,
              minPercentage: value,
              maxPercentage: condition.maxPercentage,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildOptionalDoubleField(
          context: context,
          label: 'Max Percentage (0.0 - 1.0)',
          value: condition.maxPercentage,
          onChanged: (value) {
            onUpdate(HealthCondition(
              minHealth: condition.minHealth,
              maxHealth: condition.maxHealth,
              minPercentage: condition.minPercentage,
              maxPercentage: value,
            ));
          },
        ),
      ],
    );
  }
}

/// Fields for HasComponentCondition.
class _HasComponentFields extends StatelessWidget {
  final HasComponentCondition condition;
  final void Function(DialogCondition?) onUpdate;

  const _HasComponentFields({
    required this.condition,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildField(
          context: context,
          label: 'Component Type',
          value: condition.componentType,
          onChanged: (value) {
            onUpdate(HasComponentCondition(
              componentType: value,
              checkPlayer: condition.checkPlayer,
            ));
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: condition.checkPlayer,
              onChanged: (value) {
                onUpdate(HasComponentCondition(
                  componentType: condition.componentType,
                  checkPlayer: value ?? true,
                ));
              },
            ),
            Text(
              'Check Player (unchecked = check NPC)',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fields for NotCondition.
class _NotFields extends StatelessWidget {
  final NotCondition condition;
  final void Function(DialogCondition?) onUpdate;

  const _NotFields({
    required this.condition,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ConditionEditor(
          condition: condition.condition,
          onUpdate: (inner) {
            if (inner != null) {
              onUpdate(NotCondition(inner));
            }
          },
        ),
      ),
    );
  }
}

/// Fields for AllCondition and AnyCondition.
class _CompositeFields extends StatelessWidget {
  final String label;
  final List<DialogCondition> conditions;
  final void Function(List<DialogCondition>) onUpdate;

  const _CompositeFields({
    required this.label,
    required this.conditions,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                onUpdate([...conditions, const AlwaysCondition()]);
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...conditions.asMap().entries.map((entry) {
          final index = entry.key;
          final cond = entry.value;

          return Card(
            margin: const EdgeInsets.only(left: 8, bottom: 4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ConditionEditor(
                      condition: cond,
                      onUpdate: (newCond) {
                        if (newCond != null) {
                          final updated = List<DialogCondition>.from(conditions);
                          updated[index] = newCond;
                          onUpdate(updated);
                        }
                      },
                    ),
                  ),
                  if (conditions.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () {
                        final updated = List<DialogCondition>.from(conditions);
                        updated.removeAt(index);
                        onUpdate(updated);
                      },
                      tooltip: 'Remove',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// Helper field builders

Widget _buildField({
  required BuildContext context,
  required String label,
  required String value,
  required void Function(String) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    ],
  );
}

Widget _buildIntField({
  required BuildContext context,
  required String label,
  required int value,
  required void Function(int) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        initialValue: value.toString(),
        keyboardType: TextInputType.number,
        onChanged: (text) {
          final parsed = int.tryParse(text);
          if (parsed != null) {
            onChanged(parsed);
          }
        },
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    ],
  );
}

Widget _buildOptionalIntField({
  required BuildContext context,
  required String label,
  required int? value,
  required void Function(int?) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        initialValue: value?.toString() ?? '',
        keyboardType: TextInputType.number,
        onChanged: (text) {
          if (text.isEmpty) {
            onChanged(null);
          } else {
            final parsed = int.tryParse(text);
            if (parsed != null) {
              onChanged(parsed);
            }
          }
        },
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: '(not set)',
        ),
      ),
    ],
  );
}

Widget _buildOptionalDoubleField({
  required BuildContext context,
  required String label,
  required double? value,
  required void Function(double?) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        initialValue: value?.toString() ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (text) {
          if (text.isEmpty) {
            onChanged(null);
          } else {
            final parsed = double.tryParse(text);
            if (parsed != null) {
              onChanged(parsed);
            }
          }
        },
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: '(not set)',
        ),
      ),
    ],
  );
}
