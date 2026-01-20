import 'package:flutter/material.dart';
import 'package:rogueverse/ecs/ecs.dart';
import 'package:rogueverse/app/screens/game/template_variables_screen.dart';
import 'package:rogueverse/app/screens/text_editor_screen.dart';
import 'package:rogueverse/app/widgets/overlays/inspector/component_registry.dart';
import 'package:rogueverse/app/widgets/properties.dart';

/// Asset type enum for the UI selector.
enum _AssetType { image, text }

/// Metadata for the Renderable component, which specifies the visual appearance of an entity.
class RenderableMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'Renderable';

  @override
  bool hasComponent(Entity entity) => entity.has<Renderable>();

  /// Available rotation options (in degrees).
  static const _rotationOptions = [0.0, 90.0, 180.0, 270.0];

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<Renderable>(entity.id),
      builder: (context, snapshot) {
        final renderable = entity.get<Renderable>();
        if (renderable == null) return const SizedBox.shrink();

        final asset = renderable.asset;
        final currentType = asset is ImageAsset ? _AssetType.image : _AssetType.text;

        return Column(
          children: [
            // Asset type selector
            PropertyRow(
              key: ValueKey('renderable_type_$currentType'),
              item: EnumPropertyItem<_AssetType>(
                id: "assetType",
                label: "Asset Type",
                value: currentType,
                options: _AssetType.values,
                optionLabelBuilder: (t) => t == _AssetType.image ? 'Image' : 'Text',
                onChanged: (newType) => _switchAssetType(entity, newType),
              ),
              theme: _theme,
            ),

            // Conditional fields based on asset type
            if (asset is ImageAsset) ..._buildImageFields(entity, asset),
            if (asset is TextAsset) ..._buildTextFields(context, entity, asset),
          ],
        );
      },
    );
  }

  /// Switches between ImageAsset and TextAsset.
  void _switchAssetType(Entity entity, _AssetType newType) {
    final newAsset = switch (newType) {
      _AssetType.image => ImageAsset('images/default.svg'),
      _AssetType.text => TextAsset(text: 'Text'),
    };
    entity.upsert(Renderable(newAsset));
  }

  /// Builds property rows for ImageAsset fields.
  List<Widget> _buildImageFields(Entity entity, ImageAsset img) {
    return [
      PropertyRow(
        key: ValueKey('renderable_path_${img.svgAssetPath}'),
        item: AssetPathPropertyItem(
          id: "svgAssetPath",
          label: "Asset Path",
          value: img.svgAssetPath,
          onChanged: (String newPath) {
            entity.upsert(Renderable(img.copyWith(svgAssetPath: newPath)));
          },
        ),
        theme: _theme,
      ),
      PropertyRow(
        key: ValueKey('renderable_flipH_${img.flipHorizontal}'),
        item: BoolPropertyItem(
          id: "flipHorizontal",
          label: "Flip Horizontal",
          value: img.flipHorizontal,
          onChanged: (bool newValue) {
            entity.upsert(Renderable(img.copyWith(flipHorizontal: newValue)));
          },
        ),
        theme: _theme,
      ),
      PropertyRow(
        key: ValueKey('renderable_flipV_${img.flipVertical}'),
        item: BoolPropertyItem(
          id: "flipVertical",
          label: "Flip Vertical",
          value: img.flipVertical,
          onChanged: (bool newValue) {
            entity.upsert(Renderable(img.copyWith(flipVertical: newValue)));
          },
        ),
        theme: _theme,
      ),
      PropertyRow(
        key: ValueKey('renderable_rotation_${img.rotationDegrees}'),
        item: EnumPropertyItem<double>(
          id: "rotationDegrees",
          label: "Rotation",
          value: _rotationOptions.contains(img.rotationDegrees)
              ? img.rotationDegrees
              : 0.0,
          options: _rotationOptions,
          optionLabelBuilder: (v) => '${v.toInt()}°',
          onChanged: (double newValue) {
            entity.upsert(Renderable(img.copyWith(rotationDegrees: newValue)));
          },
        ),
        theme: _theme,
      ),
    ];
  }

  /// Builds property rows for TextAsset fields.
  List<Widget> _buildTextFields(BuildContext context, Entity entity, TextAsset txt) {
    return [
      PropertyRow(
        key: ValueKey('renderable_text_${txt.text}'),
        item: StringPropertyItem(
          id: "text",
          label: "Text",
          // Show escaped newlines in preview
          value: txt.text.replaceAll('\n', r'\n'),
          onChanged: (String newValue) {
            // Convert escaped newlines back to actual newlines
            entity.upsert(Renderable(txt.copyWith(text: newValue.replaceAll(r'\n', '\n'))));
          },
        ),
        theme: _theme,
        trailing: _TextFieldTrailingButtons(
          text: txt.text,
          onTextChanged: (String newValue) {
            entity.upsert(Renderable(txt.copyWith(text: newValue)));
          },
        ),
      ),
      PropertyRow(
        key: ValueKey('renderable_fontSize_${txt.fontSize}'),
        item: DoublePropertyItem(
          id: "fontSize",
          label: "Font Size",
          value: txt.fontSize,
          onChanged: (double newValue) {
            entity.upsert(Renderable(txt.copyWith(fontSize: newValue)));
          },
        ),
        theme: _theme,
      ),
      PropertyRow(
        key: ValueKey('renderable_color_${txt.color}'),
        item: IntPropertyItem(
          id: "color",
          label: "Color (ARGB)",
          value: txt.color,
          onChanged: (int newValue) {
            entity.upsert(Renderable(txt.copyWith(color: newValue)));
          },
        ),
        theme: _theme,
      ),
    ];
  }

  @override
  Component createDefault() => Renderable(ImageAsset('images/default.svg'));

  @override
  void removeComponent(Entity entity) => entity.remove<Renderable>();
}

/// Metadata for the EditorRenderable component, which provides an alternate visual for editor mode.
class EditorRenderableMetadata extends ComponentMetadata {
  /// Theme used for property panel layout.
  static const _theme = PropertyPanelThemeData(labelColumnWidth: 140);

  @override
  String get componentName => 'EditorRenderable';

  @override
  bool hasComponent(Entity entity) => entity.has<EditorRenderable>();

  /// Available rotation options (in degrees).
  static const _rotationOptions = [0.0, 90.0, 180.0, 270.0];

  @override
  Widget buildContent(Entity entity) {
    return StreamBuilder<Change>(
      stream: entity.parentCell.componentChanges.onEntityOnComponent<EditorRenderable>(entity.id),
      builder: (context, snapshot) {
        final editorRenderable = entity.get<EditorRenderable>();
        if (editorRenderable == null) return const SizedBox.shrink();

        final asset = editorRenderable.asset;
        final currentType = asset is ImageAsset ? _AssetType.image : _AssetType.text;

        return Column(
          children: [
            // Asset type selector
            PropertyRow(
              key: ValueKey('editor_renderable_type_$currentType'),
              item: EnumPropertyItem<_AssetType>(
                id: "assetType",
                label: "Asset Type",
                value: currentType,
                options: _AssetType.values,
                optionLabelBuilder: (t) => t == _AssetType.image ? 'Image' : 'Text',
                onChanged: (newType) => _switchAssetType(entity, newType),
              ),
              theme: _theme,
            ),

            // Conditional fields based on asset type
            if (asset is ImageAsset) ..._buildImageFields(entity, asset),
            if (asset is TextAsset) ..._buildTextFields(context, entity, asset),
          ],
        );
      },
    );
  }

  /// Switches between ImageAsset and TextAsset.
  void _switchAssetType(Entity entity, _AssetType newType) {
    final newAsset = switch (newType) {
      _AssetType.image => ImageAsset('images/default.svg'),
      _AssetType.text => TextAsset(text: 'Text'),
    };
    entity.upsert(EditorRenderable(newAsset));
  }

  /// Builds property rows for ImageAsset fields.
  List<Widget> _buildImageFields(Entity entity, ImageAsset img) {
    return [
      PropertyRow(
        key: ValueKey('editor_renderable_path_${img.svgAssetPath}'),
        item: AssetPathPropertyItem(
          id: "svgAssetPath",
          label: "Asset Path",
          value: img.svgAssetPath,
          onChanged: (String newPath) {
            entity.upsert(EditorRenderable(img.copyWith(svgAssetPath: newPath)));
          },
        ),
        theme: _theme,
      ),
      PropertyRow(
        key: ValueKey('editor_renderable_flipH_${img.flipHorizontal}'),
        item: BoolPropertyItem(
          id: "flipHorizontal",
          label: "Flip Horizontal",
          value: img.flipHorizontal,
          onChanged: (bool newValue) {
            entity.upsert(EditorRenderable(img.copyWith(flipHorizontal: newValue)));
          },
        ),
        theme: _theme,
      ),
      PropertyRow(
        key: ValueKey('editor_renderable_flipV_${img.flipVertical}'),
        item: BoolPropertyItem(
          id: "flipVertical",
          label: "Flip Vertical",
          value: img.flipVertical,
          onChanged: (bool newValue) {
            entity.upsert(EditorRenderable(img.copyWith(flipVertical: newValue)));
          },
        ),
        theme: _theme,
      ),
      PropertyRow(
        key: ValueKey('editor_renderable_rotation_${img.rotationDegrees}'),
        item: EnumPropertyItem<double>(
          id: "rotationDegrees",
          label: "Rotation",
          value: _rotationOptions.contains(img.rotationDegrees)
              ? img.rotationDegrees
              : 0.0,
          options: _rotationOptions,
          optionLabelBuilder: (v) => '${v.toInt()}°',
          onChanged: (double newValue) {
            entity.upsert(EditorRenderable(img.copyWith(rotationDegrees: newValue)));
          },
        ),
        theme: _theme,
      ),
    ];
  }

  /// Builds property rows for TextAsset fields.
  List<Widget> _buildTextFields(BuildContext context, Entity entity, TextAsset txt) {
    return [
      PropertyRow(
        key: ValueKey('editor_renderable_text_${txt.text}'),
        item: StringPropertyItem(
          id: "text",
          label: "Text",
          // Show escaped newlines in preview
          value: txt.text.replaceAll('\n', r'\n'),
          onChanged: (String newValue) {
            // Convert escaped newlines back to actual newlines
            entity.upsert(EditorRenderable(txt.copyWith(text: newValue.replaceAll(r'\n', '\n'))));
          },
        ),
        theme: _theme,
        trailing: _TextFieldTrailingButtons(
          text: txt.text,
          onTextChanged: (String newValue) {
            entity.upsert(EditorRenderable(txt.copyWith(text: newValue)));
          },
        ),
      ),
      PropertyRow(
        key: ValueKey('editor_renderable_fontSize_${txt.fontSize}'),
        item: DoublePropertyItem(
          id: "fontSize",
          label: "Font Size",
          value: txt.fontSize,
          onChanged: (double newValue) {
            entity.upsert(EditorRenderable(txt.copyWith(fontSize: newValue)));
          },
        ),
        theme: _theme,
      ),
      PropertyRow(
        key: ValueKey('editor_renderable_color_${txt.color}'),
        item: IntPropertyItem(
          id: "color",
          label: "Color (ARGB)",
          value: txt.color,
          onChanged: (int newValue) {
            entity.upsert(EditorRenderable(txt.copyWith(color: newValue)));
          },
        ),
        theme: _theme,
      ),
    ];
  }

  @override
  Component createDefault() => EditorRenderable(ImageAsset('images/default.svg'));

  @override
  void removeComponent(Entity entity) => entity.remove<EditorRenderable>();
}

/// Trailing buttons for text property field: template variables and expand to multiline editor.
class _TextFieldTrailingButtons extends StatelessWidget {
  final String text;
  final ValueChanged<String> onTextChanged;

  const _TextFieldTrailingButtons({
    required this.text,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Template Variables button
        IconButton(
          icon: Icon(
            Icons.data_object,
            size: 18,
            color: colorScheme.primary,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TemplateVariablesScreen(),
              ),
            );
          },
          tooltip: 'Template Variables',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        // Expand to multiline editor button
        IconButton(
          icon: Icon(
            Icons.open_in_full,
            size: 16,
            color: colorScheme.primary,
          ),
          onPressed: () async {
            final result = await TextEditorScreen.show(
              context,
              title: 'Edit Text',
              initialValue: text,
            );
            if (result != null) {
              onTextChanged(result);
            }
          },
          tooltip: 'Edit multiline text',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}
