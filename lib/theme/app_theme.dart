import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      margin: EdgeInsets.zero,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      margin: EdgeInsets.zero,
    ),
    // Puzzle hücreleri için renk ayarları
    extensions: [
      _CustomColors(
        puzzleBorderColor: Colors.grey[400]!, // Bulmaca çizgileri için
        puzzleBackgroundColor: Colors.grey[850]!, // Bulmaca arka planı için
        puzzleShadedColor: Colors.blue[300]!, // Boyalı hücreler için
      ),
    ],
  );
}

// Özel renkler için extension
class _CustomColors extends ThemeExtension<_CustomColors> {
  final Color puzzleBorderColor;
  final Color puzzleBackgroundColor;
  final Color puzzleShadedColor;

  _CustomColors({
    required this.puzzleBorderColor,
    required this.puzzleBackgroundColor,
    required this.puzzleShadedColor,
  });

  @override
  ThemeExtension<_CustomColors> copyWith({
    Color? puzzleBorderColor,
    Color? puzzleBackgroundColor,
    Color? puzzleShadedColor,
  }) {
    return _CustomColors(
      puzzleBorderColor: puzzleBorderColor ?? this.puzzleBorderColor,
      puzzleBackgroundColor: puzzleBackgroundColor ?? this.puzzleBackgroundColor,
      puzzleShadedColor: puzzleShadedColor ?? this.puzzleShadedColor,
    );
  }

  @override
  ThemeExtension<_CustomColors> lerp(
      ThemeExtension<_CustomColors>? other,
      double t,
      ) {
    if (other is! _CustomColors) {
      return this;
    }
    return _CustomColors(
      puzzleBorderColor: Color.lerp(puzzleBorderColor, other.puzzleBorderColor, t)!,
      puzzleBackgroundColor: Color.lerp(puzzleBackgroundColor, other.puzzleBackgroundColor, t)!,
      puzzleShadedColor: Color.lerp(puzzleShadedColor, other.puzzleShadedColor, t)!,
    );
  }
}