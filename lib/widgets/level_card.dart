import 'package:flutter/material.dart';
import '../models/level_data.dart';

class LevelCard extends StatelessWidget {
  final LevelData levelData;
  final VoidCallback onTap;

  const LevelCard({
    Key? key,
    required this.levelData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                levelData.id,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
