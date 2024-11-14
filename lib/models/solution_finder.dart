
import 'package:norinorigame/models/puzzle.dart';
import 'package:norinorigame/models/cell.dart';
import 'package:norinorigame/models/region.dart';

class SolutionFinder {
  final Puzzle puzzle;
  Map<int, List<Cell>> solutions = {};

  SolutionFinder(this.puzzle) {
    _findAllSolutions();
  }

  void _findAllSolutions() {
    for (var region in puzzle.regions) {
      solutions[region.id] = _findRegionSolution(region);
    }
  }

  List<Cell> _findRegionSolution(Region region) {
    // Her bölgede 2 bitişik hücre olmalı
    List<Cell> result = [];

    // Tüm olası 2'li hücre kombinasyonlarını kontrol et
    for (var cell1 in region.cells) {
      for (var cell2 in region.cells) {
        if (cell1 != cell2 && _areAdjacent(cell1, cell2)) {
          // Bu iki hücre bitişik, diğer bölgelerin çözümleriyle çakışıp çakışmadığını kontrol et
          bool isValid = true;
          for (var otherRegion in puzzle.regions) {
            if (otherRegion.id != region.id) {
              var otherSolution = solutions[otherRegion.id];
              if (otherSolution != null) {
                // Diğer bölgenin çözümündeki hücrelerle bitişiklik kontrolü
                for (var otherCell in otherSolution) {
                  if (_areAdjacent(cell1, otherCell) || _areAdjacent(cell2, otherCell)) {
                    isValid = false;
                    break;
                  }
                }
              }
            }
          }

          if (isValid) {
            result = [cell1, cell2];
            return result;
          }
        }
      }
    }

    return result;
  }

  bool _areAdjacent(Cell cell1, Cell cell2) {
    return (cell1.row == cell2.row && (cell1.col - cell2.col).abs() == 1) ||
        (cell1.col == cell2.col && (cell1.row - cell2.row).abs() == 1);
  }

  Cell? findNextHint(Region region) {
    var solution = solutions[region.id];
    if (solution == null || solution.isEmpty) return null;

    // Eğer bölgede hiç boyalı hücre yoksa, çözümden birini öner
    if (region.shadedCells.isEmpty) {
      return solution[0];
    }

    // Eğer bir hücre zaten boyalıysa, çözümün diğer hücresini öner
    if (region.shadedCells.length == 1) {
      var shadedCell = region.shadedCells[0];
      // Çözüm kümesinde boyalı hücre varsa, diğerini öner
      if (solution.contains(shadedCell)) {
        return solution.firstWhere((cell) => cell != shadedCell);
      }
    }

    return null;
  }
}
