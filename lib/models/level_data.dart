class LevelData {
  final String id;
  final int size;
  final String difficulty;
  final String horizontalBorders;
  final String verticalBorders;

  LevelData({
    required this.id,
    required this.size,
    required this.difficulty,
    required this.horizontalBorders,
    required this.verticalBorders,
  });

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      id: json['id'],
      size: json['size'],
      difficulty: json['difficulty'],
      horizontalBorders: json['horizontalBorders'],
      verticalBorders: json['verticalBorders'],
    );
  }

  Map<String, List<List<int>>> getBorders() {
    return {
      'horizontal': _convertBordersString(horizontalBorders, size),
      'vertical': _convertBordersString(verticalBorders, size - 1),
    };
  }

  List<List<int>> _convertBordersString(String borders, int width) {
    List<List<int>> result = [];
    for (int i = 0; i < borders.length; i += width) {
      List<int> row = borders
          .substring(i, i + width)
          .split('')
          .map((e) => int.parse(e))
          .toList();
      result.add(row);
    }
    return result;
  }
}
