import 'package:flutter/material.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: Column(
        children: [
          RadioListTile(
            value: 1,
            groupValue: 1,
            onChanged: (val) {},
            title: const Text('Dark'),
          ),
          RadioListTile(
            value: 2,
            groupValue: 1,
            onChanged: (val) {},
            title: const Text('Light'),
          ),
          RadioListTile(
            value: 3,
            groupValue: 1,
            onChanged: (val) {},
            title: const Text('System'),
          ),
        ],
      ),
    );
  }
}