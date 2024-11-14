import 'package:flutter/material.dart';
import 'level_selection_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Norinori'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildModeCard(context, '6x6', [
            {'name': 'Normal', 'route': '6normal'},
            {'name': 'Hard', 'route': '6hard'},
          ]),
          _buildModeCard(context, '8x8', [
            {'name': 'Normal', 'route': '8normal'},
            {'name': 'Hard', 'route': '8hard'},
          ]),
          _buildModeCard(context, '10x10', [
            {'name': 'Normal', 'route': '10normal'},
            {'name': 'Hard', 'route': '10hard'},
          ]),
          _buildModeCard(context, '15x15', [
            {'name': 'Normal', 'route': '15normal'},
            {'name': 'Hard', 'route': '15hard'},
          ]),
          _buildModeCard(context, '20x20', [
            {'name': 'Normal', 'route': '20normal'},
            {'name': 'Hard', 'route': '20hard'},
          ]),
          _buildModeCard(context, 'Special', [
            {'name': '30x30', 'route': '30'},
            {'name': '40x40', 'route': '40'},
            {'name': '50x50', 'route': '50'},
          ]),
        ],
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, String title, List<Map<String, String>> modes) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...modes.map((mode) => ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LevelSelectionScreen(
                    mode: mode['route']!,
                  ),
                ),
              );
            },
            child: Text(mode['name']!),
          )),
        ],
      ),
    );
  }
}