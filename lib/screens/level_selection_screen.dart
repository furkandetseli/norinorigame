import 'package:flutter/material.dart';
import '../models/level_data.dart';
import '../services/level_service.dart';
import '../widgets/level_card.dart';
import 'puzzle_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  final String mode;

  const LevelSelectionScreen({
    Key? key,
    required this.mode,
  }) : super(key: key);

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  late Future<List<LevelData>> levels;
  final _levelService = LevelService();

  @override
  void initState() {
    super.initState();
  }

  String getModeTitle(String mode) {
    // Mode formatı: "6hard", "6normal", "10hard" vb.
    RegExp sizeRegex = RegExp(r'(\d+)(\w+)');
    var match = sizeRegex.firstMatch(mode);

    if (match == null) {
      return 'Invalid Mode';
    }

    int size = int.parse(match.group(1)!);
    String difficulty = match.group(2)!;
    String formattedDifficulty = difficulty.toLowerCase() == "normal" ? "Normal" : "Hard";

    return '${size}x$size $formattedDifficulty';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getModeTitle(widget.mode)),
      ),
      body: FutureBuilder<List<LevelData>>(
        future: levels,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No levels found'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final level = snapshot.data![index];
              return LevelCard(
                levelData: level,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PuzzleScreen(
                        levelId: level.id,              // Ekledik
                        size: level.size,
                        difficulty: level.difficulty,   // Ekledik
                        borders: level.getBorders(),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
