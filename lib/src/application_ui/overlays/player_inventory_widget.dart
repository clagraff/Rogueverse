import 'package:flutter/material.dart';

class InventoryItem {
  final String name;
  final int quantity;

  InventoryItem({
    required this.name,
    required this.quantity
  });
}

class PlayerInventoryWidget extends StatelessWidget {
  final List<InventoryItem> inventory;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double maxHeight;
  final double maxWidth;

  const PlayerInventoryWidget({
    super.key,
    required this.inventory,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(12.0),
    this.maxHeight = 300,
    this.maxWidth = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: margin,
        padding: padding,
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: inventory.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white))),
                    Text('x${item.quantity}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
