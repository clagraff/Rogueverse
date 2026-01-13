import 'package:flutter/material.dart';
import 'package:rogueverse/game/game_area.dart';

/// A footer bar displayed at the bottom of the screen during editing mode.
/// Contains controls for selecting the edit target (initial state or save state).
class EditorFooterBar extends StatelessWidget {
  /// Notifier for the current edit target.
  final ValueNotifier<EditTarget> editTargetNotifier;

  const EditorFooterBar({
    super.key,
    required this.editTargetNotifier,
  });

  String _targetLabel(EditTarget target) {
    return switch (target) {
      EditTarget.initial => 'Initial State',
      EditTarget.save => 'Save State',
    };
  }

  String _targetFile(EditTarget target) {
    return switch (target) {
      EditTarget.initial => 'initial.json',
      EditTarget.save => 'save.patch.json',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 4,
      color: colorScheme.surface,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              'Editing:',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder<EditTarget>(
              valueListenable: editTargetNotifier,
              builder: (context, editTarget, _) {
                return PopupMenuButton<EditTarget>(
                  initialValue: editTarget,
                  onSelected: (value) {
                    editTargetNotifier.value = value;
                  },
                  tooltip: 'Select edit target',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _targetLabel(editTarget),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    for (final target in EditTarget.values)
                      PopupMenuItem(
                        value: target,
                        child: Text(_targetLabel(target)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<EditTarget>(
              valueListenable: editTargetNotifier,
              builder: (context, editTarget, _) {
                return Text(
                  '(${_targetFile(editTarget)})',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
