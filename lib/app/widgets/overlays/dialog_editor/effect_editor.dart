import 'package:flutter/material.dart';

import 'package:rogueverse/ecs/dialog/dialog.dart';

/// Editor widget for a list of DialogEffects.
class EffectsListEditor extends StatelessWidget {
  final List<DialogEffect> effects;
  final void Function(List<DialogEffect>) onUpdate;

  const EffectsListEditor({
    super.key,
    required this.effects,
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
            Icon(Icons.flash_on, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Effects',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addEffect,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Effect'),
            ),
          ],
        ),
        if (effects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No effects',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          )
        else
          ...effects.asMap().entries.map((entry) {
            return _EffectItem(
              index: entry.key,
              effect: entry.value,
              onUpdate: (newEffect) => _updateEffect(entry.key, newEffect),
              onDelete: () => _deleteEffect(entry.key),
            );
          }),
      ],
    );
  }

  void _addEffect() {
    onUpdate([...effects, const TriggerTickEffect(count: 1)]);
  }

  void _updateEffect(int index, DialogEffect newEffect) {
    final updated = List<DialogEffect>.from(effects);
    updated[index] = newEffect;
    onUpdate(updated);
  }

  void _deleteEffect(int index) {
    final updated = List<DialogEffect>.from(effects);
    updated.removeAt(index);
    onUpdate(updated);
  }
}

/// A single effect item in the list.
class _EffectItem extends StatelessWidget {
  final int index;
  final DialogEffect effect;
  final void Function(DialogEffect) onUpdate;
  final VoidCallback onDelete;

  const _EffectItem({
    required this.index,
    required this.effect,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Effect ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: onDelete,
                  tooltip: 'Delete effect',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _EffectEditor(
              effect: effect,
              onUpdate: onUpdate,
            ),
          ],
        ),
      ),
    );
  }
}

/// Editor for a single DialogEffect.
class _EffectEditor extends StatelessWidget {
  final DialogEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _EffectEditor({
    required this.effect,
    required this.onUpdate,
  });

  static const List<_EffectType> _effectTypes = [
    _EffectType('triggerTick', 'Trigger Tick', 'Advance game time'),
    _EffectType('heal', 'Heal', 'Restore health'),
    _EffectType('damage', 'Damage', 'Deal damage'),
    _EffectType('giveItem', 'Give Item', 'Add item to inventory'),
    _EffectType('removeItem', 'Remove Item', 'Remove item from inventory'),
    _EffectType('moveEntity', 'Move Entity', 'Move player or dialog partner'),
    _EffectType('openDoor', 'Open Door', 'Open an Openable entity'),
    _EffectType('closeDoor', 'Close Door', 'Close an Openable entity'),
    _EffectType('setParent', 'Set Parent', 'Set HasParent component'),
    _EffectType('removeParent', 'Remove Parent', 'Remove HasParent component'),
    _EffectType('teleport', 'Teleport (Legacy)', 'Move player to position'),
    _EffectType('removeComponent', 'Remove Component', 'Remove a component'),
  ];

  String _getEffectTypeId() {
    if (effect is TriggerTickEffect) return 'triggerTick';
    if (effect is HealEffect) return 'heal';
    if (effect is DamageEffect) return 'damage';
    if (effect is GiveItemEffect) return 'giveItem';
    if (effect is RemoveItemEffect) return 'removeItem';
    if (effect is MoveEntityEffect) return 'moveEntity';
    if (effect is OpenDoorEffect) return 'openDoor';
    if (effect is CloseDoorEffect) return 'closeDoor';
    if (effect is SetParentEffect) return 'setParent';
    if (effect is RemoveParentEffect) return 'removeParent';
    if (effect is TeleportEffect) return 'teleport';
    if (effect is RemoveComponentEffect) return 'removeComponent';
    return 'triggerTick';
  }

  void _onTypeChanged(String? typeId) {
    if (typeId == null) return;

    switch (typeId) {
      case 'triggerTick':
        onUpdate(const TriggerTickEffect(count: 1));
        break;
      case 'heal':
        onUpdate(const HealEffect(amount: 10));
        break;
      case 'damage':
        onUpdate(const DamageEffect(amount: 10));
        break;
      case 'giveItem':
        onUpdate(const GiveItemEffect(itemName: 'Item'));
        break;
      case 'removeItem':
        onUpdate(const RemoveItemEffect(itemName: 'Item'));
        break;
      case 'moveEntity':
        onUpdate(const MoveEntityEffect(x: 0, y: 0));
        break;
      case 'openDoor':
        onUpdate(const OpenDoorEffect(doorEntityId: 0));
        break;
      case 'closeDoor':
        onUpdate(const CloseDoorEffect(doorEntityId: 0));
        break;
      case 'setParent':
        onUpdate(const SetParentEffect());
        break;
      case 'removeParent':
        onUpdate(const RemoveParentEffect());
        break;
      case 'teleport':
        onUpdate(const TeleportEffect(x: 0, y: 0));
        break;
      case 'removeComponent':
        onUpdate(const RemoveComponentEffect(componentType: 'ComponentName'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentTypeId = _getEffectTypeId();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Effect Type',
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
          items: _effectTypes.map((type) {
            return DropdownMenuItem(
              value: type.id,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: _onTypeChanged,
        ),
        const SizedBox(height: 8),
        _buildEffectFields(context),
      ],
    );
  }

  Widget _buildEffectFields(BuildContext context) {
    if (effect is TriggerTickEffect) {
      return _TriggerTickFields(
        effect: effect as TriggerTickEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is HealEffect) {
      return _HealFields(
        effect: effect as HealEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is DamageEffect) {
      return _DamageFields(
        effect: effect as DamageEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is GiveItemEffect) {
      return _GiveItemFields(
        effect: effect as GiveItemEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is RemoveItemEffect) {
      return _RemoveItemFields(
        effect: effect as RemoveItemEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is MoveEntityEffect) {
      return _MoveEntityFields(
        effect: effect as MoveEntityEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is OpenDoorEffect) {
      return _OpenDoorFields(
        effect: effect as OpenDoorEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is CloseDoorEffect) {
      return _CloseDoorFields(
        effect: effect as CloseDoorEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is SetParentEffect) {
      return _SetParentFields(
        effect: effect as SetParentEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is RemoveParentEffect) {
      return _RemoveParentFields(
        effect: effect as RemoveParentEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is TeleportEffect) {
      return _TeleportFields(
        effect: effect as TeleportEffect,
        onUpdate: onUpdate,
      );
    } else if (effect is RemoveComponentEffect) {
      return _RemoveComponentFields(
        effect: effect as RemoveComponentEffect,
        onUpdate: onUpdate,
      );
    }
    return const SizedBox.shrink();
  }
}

class _EffectType {
  final String id;
  final String name;
  final String description;

  const _EffectType(this.id, this.name, this.description);
}

/// Fields for TriggerTickEffect.
class _TriggerTickFields extends StatelessWidget {
  final TriggerTickEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _TriggerTickFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return _buildIntField(
      context: context,
      label: 'Number of Ticks',
      value: effect.count,
      onChanged: (value) {
        onUpdate(TriggerTickEffect(count: value));
      },
    );
  }
}

/// Fields for HealEffect.
class _HealFields extends StatelessWidget {
  final HealEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _HealFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: effect.fullHeal,
              onChanged: (value) {
                onUpdate(HealEffect(
                  fullHeal: value ?? false,
                  amount: effect.amount,
                  targetPlayer: effect.targetPlayer,
                ));
              },
            ),
            Text(
              'Full Heal',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ),
        if (!effect.fullHeal)
          _buildOptionalIntField(
            context: context,
            label: 'Heal Amount',
            value: effect.amount,
            onChanged: (value) {
              onUpdate(HealEffect(
                amount: value,
                fullHeal: effect.fullHeal,
                targetPlayer: effect.targetPlayer,
              ));
            },
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: effect.targetPlayer,
              onChanged: (value) {
                onUpdate(HealEffect(
                  amount: effect.amount,
                  fullHeal: effect.fullHeal,
                  targetPlayer: value ?? true,
                ));
              },
            ),
            Text(
              'Target Player (unchecked = NPC)',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fields for DamageEffect.
class _DamageFields extends StatelessWidget {
  final DamageEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _DamageFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildIntField(
          context: context,
          label: 'Damage Amount',
          value: effect.amount,
          onChanged: (value) {
            onUpdate(DamageEffect(
              amount: value,
              targetPlayer: effect.targetPlayer,
            ));
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: effect.targetPlayer,
              onChanged: (value) {
                onUpdate(DamageEffect(
                  amount: effect.amount,
                  targetPlayer: value ?? true,
                ));
              },
            ),
            Text(
              'Target Player (unchecked = NPC)',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fields for GiveItemEffect.
class _GiveItemFields extends StatelessWidget {
  final GiveItemEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _GiveItemFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildField(
          context: context,
          label: 'Item Name',
          value: effect.itemName,
          onChanged: (value) {
            onUpdate(GiveItemEffect(
              itemName: value,
              count: effect.count,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildIntField(
          context: context,
          label: 'Count',
          value: effect.count,
          onChanged: (value) {
            onUpdate(GiveItemEffect(
              itemName: effect.itemName,
              count: value,
            ));
          },
        ),
      ],
    );
  }
}

/// Fields for RemoveItemEffect.
class _RemoveItemFields extends StatelessWidget {
  final RemoveItemEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _RemoveItemFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildField(
          context: context,
          label: 'Item Name',
          value: effect.itemName,
          onChanged: (value) {
            onUpdate(RemoveItemEffect(
              itemName: value,
              count: effect.count,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildIntField(
          context: context,
          label: 'Count',
          value: effect.count,
          onChanged: (value) {
            onUpdate(RemoveItemEffect(
              itemName: effect.itemName,
              count: value,
            ));
          },
        ),
      ],
    );
  }
}

/// Fields for TeleportEffect.
class _TeleportFields extends StatelessWidget {
  final TeleportEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _TeleportFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildIntField(
                context: context,
                label: 'X',
                value: effect.x,
                onChanged: (value) {
                  onUpdate(TeleportEffect(
                    x: value,
                    y: effect.y,
                    targetParentId: effect.targetParentId,
                  ));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIntField(
                context: context,
                label: 'Y',
                value: effect.y,
                onChanged: (value) {
                  onUpdate(TeleportEffect(
                    x: effect.x,
                    y: value,
                    targetParentId: effect.targetParentId,
                  ));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildOptionalIntField(
          context: context,
          label: 'Target Parent ID (for room changes)',
          value: effect.targetParentId,
          onChanged: (value) {
            onUpdate(TeleportEffect(
              x: effect.x,
              y: effect.y,
              targetParentId: value,
            ));
          },
        ),
      ],
    );
  }
}

/// Fields for RemoveComponentEffect.
class _RemoveComponentFields extends StatelessWidget {
  final RemoveComponentEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _RemoveComponentFields({
    required this.effect,
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
          value: effect.componentType,
          onChanged: (value) {
            onUpdate(RemoveComponentEffect(
              componentType: value,
              targetPlayer: effect.targetPlayer,
            ));
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: effect.targetPlayer,
              onChanged: (value) {
                onUpdate(RemoveComponentEffect(
                  componentType: effect.componentType,
                  targetPlayer: value ?? true,
                ));
              },
            ),
            Text(
              'Target Player (unchecked = NPC)',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fields for MoveEntityEffect.
class _MoveEntityFields extends StatelessWidget {
  final MoveEntityEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _MoveEntityFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildIntField(
                context: context,
                label: 'X',
                value: effect.x,
                onChanged: (value) {
                  onUpdate(MoveEntityEffect(
                    x: value,
                    y: effect.y,
                    targetPlayer: effect.targetPlayer,
                  ));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIntField(
                context: context,
                label: 'Y',
                value: effect.y,
                onChanged: (value) {
                  onUpdate(MoveEntityEffect(
                    x: effect.x,
                    y: value,
                    targetPlayer: effect.targetPlayer,
                  ));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: effect.targetPlayer,
              onChanged: (value) {
                onUpdate(MoveEntityEffect(
                  x: effect.x,
                  y: effect.y,
                  targetPlayer: value ?? true,
                ));
              },
            ),
            Text(
              'Target Player (unchecked = dialog partner)',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

/// Fields for OpenDoorEffect.
class _OpenDoorFields extends StatelessWidget {
  final OpenDoorEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _OpenDoorFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return _buildIntField(
      context: context,
      label: 'Door Entity ID',
      value: effect.doorEntityId,
      onChanged: (value) {
        onUpdate(OpenDoorEffect(doorEntityId: value));
      },
    );
  }
}

/// Fields for CloseDoorEffect.
class _CloseDoorFields extends StatelessWidget {
  final CloseDoorEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _CloseDoorFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return _buildIntField(
      context: context,
      label: 'Door Entity ID',
      value: effect.doorEntityId,
      onChanged: (value) {
        onUpdate(CloseDoorEffect(doorEntityId: value));
      },
    );
  }
}

/// Fields for SetParentEffect.
class _SetParentFields extends StatelessWidget {
  final SetParentEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _SetParentFields({
    required this.effect,
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
            Checkbox(
              value: effect.targetPlayer,
              onChanged: (value) {
                onUpdate(SetParentEffect(
                  targetPlayer: value ?? true,
                  parentTarget: effect.parentTarget,
                  customParentId: effect.customParentId,
                ));
              },
            ),
            Text(
              'Set parent on Player (unchecked = dialog partner)',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Parent Target',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<ParentTarget>(
          value: effect.parentTarget,
          isExpanded: true,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: ParentTarget.player,
              child: Text('Player'),
            ),
            DropdownMenuItem(
              value: ParentTarget.npc,
              child: Text('Dialog Partner'),
            ),
            DropdownMenuItem(
              value: ParentTarget.customId,
              child: Text('Custom Entity ID'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onUpdate(SetParentEffect(
                targetPlayer: effect.targetPlayer,
                parentTarget: value,
                customParentId: effect.customParentId,
              ));
            }
          },
        ),
        if (effect.parentTarget == ParentTarget.customId) ...[
          const SizedBox(height: 8),
          _buildOptionalIntField(
            context: context,
            label: 'Custom Parent Entity ID',
            value: effect.customParentId,
            onChanged: (value) {
              onUpdate(SetParentEffect(
                targetPlayer: effect.targetPlayer,
                parentTarget: effect.parentTarget,
                customParentId: value,
              ));
            },
          ),
        ],
      ],
    );
  }
}

/// Fields for RemoveParentEffect.
class _RemoveParentFields extends StatelessWidget {
  final RemoveParentEffect effect;
  final void Function(DialogEffect) onUpdate;

  const _RemoveParentFields({
    required this.effect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Checkbox(
          value: effect.targetPlayer,
          onChanged: (value) {
            onUpdate(RemoveParentEffect(targetPlayer: value ?? true));
          },
        ),
        Text(
          'Remove parent from Player (unchecked = dialog partner)',
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
        ),
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
