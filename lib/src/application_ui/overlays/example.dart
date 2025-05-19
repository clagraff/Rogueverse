import 'package:flutter/material.dart';

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Hello, World!'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            print('Click!');
          },
          child: const Text('A button'),
        ),
      ],
    );
  }
}
