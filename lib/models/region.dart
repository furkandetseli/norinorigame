import 'cell.dart';

class Region {
  final int id;
  List<Cell> cells;
  List<Cell> shadedCells;
  List<Cell> availableCells;

  Region(this.id)
      : cells = [],
        shadedCells = [],
        availableCells = [];

  void addCell(Cell cell) {
    cells.add(cell);
    availableCells.add(cell);
  }

  void shadeCell(Cell cell) {
    print("Attempting to shade cell in Region ${this.id}");
    if (cell.isShaded != true) {
      if (cell.isShaded == null) {
        availableCells.remove(cell);
      }
      cell.isShaded = true;
      shadedCells.add(cell);
      print("Region ${id} now has ${shadedCells.length} shaded cells");
    }
  }

  void crossCell(Cell cell) {
    print("Attempting to cross cell in Region ${this.id}");
    if (cell.isShaded == true) {
      shadedCells.remove(cell);
      print("Removed cell from shadedCells. Count: ${shadedCells.length}");
    }
    if (cell.isShaded == null) {
      availableCells.remove(cell);
    }
    cell.isShaded = false;
  }

  void emptyCell(Cell cell) {
    print("Attempting to empty cell in Region ${this.id}");
    if (cell.isShaded == true) {
      shadedCells.remove(cell);
      print("Removed cell from shadedCells. Count: ${shadedCells.length}");
    }
    cell.isShaded = null;
    if (!availableCells.contains(cell)) {
      availableCells.add(cell);
    }
  }

  bool isInvalid() {
    if (shadedCells.length < 2) {
      int cellsToShade = 2 - shadedCells.length;
      if (availableCells.length < cellsToShade) {
        return true;
      }
    }
    return false;
  }
}