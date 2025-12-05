import 'package:flutter/material.dart';
import 'package:rogueverse/widgets/properties/properties.dart';


class InspectorOverlay extends StatefulWidget {
  const InspectorOverlay({super.key});

  @override
  State<InspectorOverlay> createState() => _InspectorOverlayState();
}

class _InspectorOverlayState extends State<InspectorOverlay> {
  bool isRoomBounding = true;
  double height = 8000;
  String topConstraint = 'Unconnected';
  String locationLine = 'Wall Centerline';

  @override
  Widget build(BuildContext context) {
    final sections = <PropertySectionData>[
      PropertySectionData(
        id: 'constraints',
        title: 'Constraints',
        items: [
          EnumPropertyItem<String>(
            id: 'locationLine',
            label: 'Location Line',
            value: locationLine,
            options: const [
              'Wall Centerline',
              'Finish Face: Exterior',
              'Finish Face: Interior',
            ],
            optionLabelBuilder: (v) => v,
            onChanged: (v) => setState(() {
              locationLine = v;
            }),
          ),
          EnumPropertyItem<String>(
            id: 'topConstraint',
            label: 'Top Constraint',
            value: topConstraint,
            options: const [
              'Unconnected',
              'Level 1',
              'Level 2',
            ],
            optionLabelBuilder: (v) => v,
            onChanged: (v) => setState(() {
              topConstraint = v;
            }),
          ),
          DoublePropertyItem(
            id: 'unconnectedHeight',
            label: 'Unconnected Height',
            value: height,
            suffixText: 'mm',
            onChanged: (v) => setState(() {
              height = v;
            }),
          ),
          BoolPropertyItem(
            id: 'roomBounding',
            label: 'Room Bounding',
            value: isRoomBounding,
            onChanged: (v) => setState(() {
              isRoomBounding = v;
            }),
          ),
        ],
      ),
      PropertySectionData(
        id: 'dimensions',
        title: 'Dimensions',
        items: const [
          ReadonlyPropertyItem(
            id: 'length',
            label: 'Length',
            value: '2800.0',
            suffixText: 'mm',
          ),
          ReadonlyPropertyItem(
            id: 'area',
            label: 'Area',
            value: '24.000 m²',
          ),
        ],
      ),
      PropertySectionData(
        id: 'custom',
        title: 'Custom',
        items: [
          CustomPropertyItem<Color>(
            id: 'debugColor',
            label: 'Debug Color',
            value: Colors.deepOrange,
            builder: (context, value, readOnly, onChanged) {
              // Simple example "custom" editor: tap to toggle between two colors.
              return InkWell(
                onTap: readOnly
                    ? null
                    : () {
                  final next =
                  value == Colors.deepOrange ? Colors.green : Colors.deepOrange;
                  onChanged(next);
                },
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    color: value,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ];

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


