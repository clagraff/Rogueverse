import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Theme
/// ---------------------------------------------------------------------------

class PropertyPanelThemeData {
  final double minWidth;
  final double maxWidth;
  final double labelColumnWidth;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry rowPadding;

  const PropertyPanelThemeData({
    this.minWidth = 200,
    this.maxWidth = 320,
    this.labelColumnWidth = 100,
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.rowPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });
}

/// ---------------------------------------------------------------------------
/// Data model
/// ---------------------------------------------------------------------------

class PropertySectionData {
  final String id;
  final String title;
  final List<PropertyItem> items;
  final bool initiallyExpanded;

  const PropertySectionData({
    required this.id,
    required this.title,
    required this.items,
    this.initiallyExpanded = false,
  });
}

/// Base class for a property item.
/// Concrete subclasses carry their typed value and callbacks.
abstract class PropertyItem {
  final String id;
  final String label;
  final bool readOnly;

  const PropertyItem({
    required this.id,
    required this.label,
    this.readOnly = false,
  });

  Widget buildEditor(BuildContext context);

  /// Override if you want to show a suffix (units, etc.).
  String? get suffixText => null;
}

/// String property
class StringPropertyItem extends PropertyItem {
  final String value;
  final bool multiline;
  final String? hintText;
  @override
  final String? suffixText;
  final ValueChanged<String>? onChanged;

  const StringPropertyItem({
    required super.id,
    required super.label,
    required this.value,
    this.onChanged,
    this.multiline = false,
    this.hintText,
    this.suffixText,
    super.readOnly,
  });

  @override
  Widget buildEditor(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: readOnly,
      enabled: !readOnly,
      maxLines: multiline ? null : 1,
      decoration: _inputDecoration(context, suffixText: suffixText, hintText: hintText),
      style: const TextStyle(fontSize: 12),
      onFieldSubmitted: onChanged,
    );
  }
}

/// int property
class IntPropertyItem extends PropertyItem {
  final int value;
  @override
  final String? suffixText;
  final ValueChanged<int>? onChanged;

  const IntPropertyItem({
    required super.id,
    required super.label,
    required this.value,
    this.onChanged,
    this.suffixText,
    super.readOnly,
  });

  @override
  Widget buildEditor(BuildContext context) {
    return TextFormField(
      initialValue: value.toString(),
      readOnly: readOnly,
      enabled: !readOnly,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(context, suffixText: suffixText),
      style: const TextStyle(fontSize: 12),
      onFieldSubmitted: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null) {
          onChanged?.call(parsed);
        }
      },
    );
  }
}

/// double property
class DoublePropertyItem extends PropertyItem {
  final double value;
  @override
  final String? suffixText;
  final ValueChanged<double>? onChanged;

  const DoublePropertyItem({
    required super.id,
    required super.label,
    required this.value,
    this.onChanged,
    this.suffixText,
    super.readOnly,
  });

  @override
  Widget buildEditor(BuildContext context) {
    return TextFormField(
      initialValue: value.toString(),
      readOnly: readOnly,
      enabled: !readOnly,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(context, suffixText: suffixText),
      style: const TextStyle(fontSize: 12),
      onFieldSubmitted: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null) {
          onChanged?.call(parsed);
        }
      },
    );
  }
}

/// bool property (checkbox)
class BoolPropertyItem extends PropertyItem {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const BoolPropertyItem({
    required super.id,
    required super.label,
    required this.value,
    this.onChanged,
    super.readOnly,
  });

  @override
  Widget buildEditor(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Checkbox(
        value: value,
        onChanged: readOnly ? null : (v) => onChanged?.call(v ?? false),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Enum / dropdown property
class EnumPropertyItem<T> extends PropertyItem {
  final T value;
  final List<T> options;
  final String Function(T) optionLabelBuilder;
  final ValueChanged<T>? onChanged;

  const EnumPropertyItem({
    required super.id,
    required super.label,
    required this.value,
    required this.options,
    required this.optionLabelBuilder,
    this.onChanged,
    super.readOnly,
  });

  @override
  Widget buildEditor(BuildContext context) {
    final current =
    options.contains(value) ? value : (options.isNotEmpty ? options.first : value);

    return DropdownButtonFormField<T>(
      value: current,
      isDense: true,
      isExpanded: true, // avoid internal overflow
      style: const TextStyle(fontSize: 12, color: Colors.white),
      items: options
          .map(
            (o) => DropdownMenuItem<T>(
          value: o,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              optionLabelBuilder(o),
              style: const TextStyle(fontSize: 12),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      )
          .toList(),
      onChanged: readOnly ? null : (v) {
        if (v != null) {
          onChanged?.call(v);
        }
      },
      decoration: _inputDecoration(context),
    );
  }
}

/// Read-only text
class ReadonlyPropertyItem extends PropertyItem {
  final String value;
  @override
  final String? suffixText;

  const ReadonlyPropertyItem({
    required super.id,
    required super.label,
    required this.value,
    this.suffixText,
  }) : super(readOnly: true);

  @override
  Widget buildEditor(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      enabled: false,
      decoration: _inputDecoration(context, suffixText: suffixText),
      style: const TextStyle(fontSize: 12),
    );
  }
}

/// Custom user-defined editor
class CustomPropertyItem<T> extends PropertyItem {
  final T value;
  final Widget Function(
      BuildContext context,
      T value,
      bool readOnly,
      ValueChanged<T> onChanged,
      ) builder;
  final ValueChanged<T>? onChanged;

  const CustomPropertyItem({
    required super.id,
    required super.label,
    required this.value,
    required this.builder,
    this.onChanged,
    super.readOnly,
  });

  @override
  Widget buildEditor(BuildContext context) {
    return builder(
      context,
      value,
      readOnly,
          (v) => onChanged?.call(v),
    );
  }
}

/// Shared input decoration helper
InputDecoration _inputDecoration(
    BuildContext context, {
      String? suffixText,
      String? hintText,
    }) {
  final scheme = Theme.of(context).colorScheme;

  return InputDecoration(
    isDense: true,
    hintText: hintText,
    hintStyle: const TextStyle(fontSize: 12),
    suffixText: suffixText,
    suffixStyle: const TextStyle(fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: scheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: scheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: scheme.primary, width: 1.2),
    ),
  );
}

/// ---------------------------------------------------------------------------
/// Widgets: panel, sections, rows
/// ---------------------------------------------------------------------------

class PropertyPanel extends StatelessWidget {
  final List<PropertySectionData> sections;
  final PropertyPanelThemeData theme;

  const PropertyPanel({
    super.key,
    required this.sections,
    this.theme = const PropertyPanelThemeData(),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: theme.minWidth,
        maxWidth: theme.maxWidth,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: scheme.outlineVariant, width: 0.5),
          ),
          color: scheme.surface,
        ),
        child: Column(
          children: [
            Container(
              padding: theme.headerPadding,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: scheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: const Text(
                'Properties',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return PropertySection(
                    section: section,
                    theme: theme,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertySection extends StatefulWidget {
  final PropertySectionData section;
  final PropertyPanelThemeData theme;

  const PropertySection({
    super.key,
    required this.section,
    required this.theme,
  });

  @override
  State<PropertySection> createState() => _PropertySectionState();
}

class _PropertySectionState extends State<PropertySection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.section.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: scheme.surfaceContainerHighest.withOpacity(0.6),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.section.title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Column(
            children: widget.section.items
                .map(
                  (item) => PropertyRow(
                item: item,
                theme: widget.theme,
              ),
            )
                .toList(),
          ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}

class PropertyRow extends StatelessWidget {
  final PropertyItem item;
  final PropertyPanelThemeData theme;

  const PropertyRow({
    super.key,
    required this.item,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(
      fontSize: 12,
      color: scheme.onSurface.withOpacity(0.9),
    );

    return Container(
      padding: theme.rowPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: theme.labelColumnWidth,
            child: Text(
              item.label,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: item.buildEditor(context),
          ),
        ],
      ),
    );
  }
}