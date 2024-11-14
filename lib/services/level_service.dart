import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_data.dart';

class LevelService {
  Future<Map<String, dynamic>?> getSavedLevelInfo(String levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_info_$levelId';
    final levelInfoJson = prefs.getString(key);

    if (levelInfoJson != null) {
      return json.decode(levelInfoJson);
    }
    return null;
  }

  Future<void> saveLevelInfo(String levelId, int size, String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_info_$levelId';
    final levelInfo = {
      'size': size,
      'difficulty': difficulty,
    };
    await prefs.setString(key, json.encode(levelInfo));
  }

  Future<String> getRandomLevel(int size, String difficulty) async {
    try {
      String folderPath = '${size}$difficulty';

      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final levelFiles = manifestMap.keys
          .where((String key) => key.contains('data/levels/$folderPath/'))
          .toList();

      if (levelFiles.isEmpty) {
        throw Exception('No levels found for $folderPath');
      }

      final random = Random();
      final randomFile = levelFiles[random.nextInt(levelFiles.length)];
      final levelId = randomFile.split('/').last.replaceAll('.json', '');

      await saveLevelInfo(levelId, size, difficulty);

      return levelId;
    } catch (e) {
      print('Error getting random level: $e');
      throw Exception('Failed to get random level');
    }
  }

  Future<LevelData> getLevelData(String levelId, int size, String difficulty) async {
    try {
      final savedInfo = await getSavedLevelInfo(levelId);
      if (savedInfo != null) {
        size = savedInfo['size'];
        difficulty = savedInfo['difficulty'];
      }

      if (size <= 0 || difficulty.isEmpty) {
        throw Exception('Invalid size or difficulty for level $levelId');
      }

      String folderPath = '${size}$difficulty';
      String jsonPath = 'assets/data/levels/$folderPath/$levelId.json';

      final String jsonString = await rootBundle.loadString(jsonPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> levels = jsonData['levels'];

      final levelData = levels.firstWhere(
            (level) => level['id'] == levelId,
        orElse: () => throw Exception('Level not found'),
      );

      return LevelData.fromJson(levelData);
    } catch (e) {
      print('Error loading level data: $e');
      throw Exception('Failed to load level data');
    }
  }
}