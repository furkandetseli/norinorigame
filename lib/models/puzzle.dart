import 'cell.dart';
import 'region.dart';

class Puzzle {
  final int size;
  final Map<String, List<List<int>>> borders;
  List<List<Cell>> cells;
  List<Region> regions;

  static const List<List<int>> directions = [
    [0, -1], // Left
    [0, 1],  // Right
    [-1, 0], // Top
    [1, 0],  // Bottom
  ];

  Puzzle(this.size, this.borders)
      : cells = List.generate(
    size,
        (i) => List.generate(
      size,
          (j) => Cell(i, j),
    ),
  ),
        regions = [] {
    _initializeRegions();
  }

  void _initializeRegions() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (cells[i][j].regionId == null) {
          _groupRegion(cells[i][j]);
        }
      }
    }
  }

  void _groupRegion(Cell initCell) {
    Region region = Region(regions.length);
    regions.add(region);

    region.addCell(initCell);
    initCell.regionId = region.id;
    List<Cell> queue = [initCell];

    while (queue.isNotEmpty) {
      Cell cell = queue.removeAt(0);
      for (List<int> direction in directions) {
        int row = cell.row + direction[0];
        int col = cell.col + direction[1];
        bool cellIsValid = row >= 0 && row < size && col >= 0 && col < size;

        if (cellIsValid) {
          Cell adjacentCell = cells[row][col];
          String borderType = direction[0] == 0 ? 'vertical' : 'horizontal';
          int borderRow = direction.contains(-1) || borderType == 'vertical' ? row : row - 1;
          int borderCol = direction.contains(-1) || borderType == 'horizontal' ? col : col - 1;

          if (borders[borderType]![borderRow][borderCol] == 0 && adjacentCell.regionId == null) {
            region.addCell(adjacentCell);
            adjacentCell.regionId = region.id;
            queue.add(adjacentCell);
          }
        }
      }
    }
  }

  void updateConnectedShadedSquares(Cell cell) {
    if (cell.isShaded == true) {
      cell.connectedShadedSquares = [cell];
      List<Cell> queue = [cell];

      while (queue.isNotEmpty) {
        Cell currentCell = queue.removeAt(0);
        for (var direction in directions) {
          int newRow = currentCell.row + direction[0];
          int newCol = currentCell.col + direction[1];

          if (newRow >= 0 && newRow < size && newCol >= 0 && newCol < size) {
            Cell adjacentCell = cells[newRow][newCol];
            if (adjacentCell.isShaded == true &&
                !cell.connectedShadedSquares!.contains(adjacentCell)) {
              cell.connectedShadedSquares!.add(adjacentCell);
              queue.add(adjacentCell);
            }
          }
        }
      }

      for (var connectedCell in cell.connectedShadedSquares!) {
        if (connectedCell != cell) {
          connectedCell.connectedShadedSquares = cell.connectedShadedSquares;
        }
      }
    }
  }
}