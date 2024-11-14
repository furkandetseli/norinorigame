import 'dart:convert';

class GameStatistics {
  int totalGamesPlayed;
  int gamesCompleted;
  int totalHintsUsed;
  int totalTimePlayed; // seconds
  int bestTime; // seconds
  int currentStreak;
  int bestStreak;
  Map<String, int> completedBySize; // "6x6": 5, "8x8": 3, etc.
  Map<String, int> completedByDifficulty; // "normal": 5, "hard": 3

  GameStatistics({
    this.totalGamesPlayed = 0,
    this.gamesCompleted = 0,
    this.totalHintsUsed = 0,
    this.totalTimePlayed = 0,
    this.bestTime = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    Map<String, int>? completedBySize,
    Map<String, int>? completedByDifficulty,
  })  : completedBySize = completedBySize ?? {
    "6x6": 0,
    "8x8": 0,
    "10x10": 0,
    "15x15": 0,
  },
        completedByDifficulty = completedByDifficulty ?? {
          "normal": 0,
          "hard": 0,
        };

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'gamesCompleted': gamesCompleted,
      'totalHintsUsed': totalHintsUsed,
      'totalTimePlayed': totalTimePlayed,
      'bestTime': bestTime,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'completedBySize': completedBySize,
      'completedByDifficulty': completedByDifficulty,
    };
  }

  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      gamesCompleted: json['gamesCompleted'] ?? 0,
      totalHintsUsed: json['totalHintsUsed'] ?? 0,
      totalTimePlayed: json['totalTimePlayed'] ?? 0,
      bestTime: json['bestTime'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      completedBySize: Map<String, int>.from(json['completedBySize'] ?? {}),
      completedByDifficulty: Map<String, int>.from(json['completedByDifficulty'] ?? {}),
    );
  }
}