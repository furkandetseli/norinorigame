class Cell {
  final int row;
  final int col;
  int? regionId;
  bool? isShaded;
  List<Cell>? connectedShadedSquares;

  Cell(this.row, this.col) {
    regionId = null;
    isShaded = null;
    connectedShadedSquares = null;
  }
}
