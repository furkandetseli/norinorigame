import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../widgets/game_controls.dart';

class PuzzleCell extends StatelessWidget {
  final Cell cell;
  final Map<String, List<List<int>>> borders;
  final int size;
  final PaintMode selectedMode;

  const PuzzleCell({
    Key? key,
    required this.cell,
    required this.borders,
    required this.size,
    required this.selectedMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cellColor = Colors.white;
    Widget? cellContent;

    if (cell.isShaded == true) {
      cellColor = Colors.blue;
    } else if (cell.isShaded == false) {
      cellColor = Colors.white;
      cellContent = Center(
        child: Text(
          'X',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        border: Border(
          top: _getBorder(cell.row == 0 || borders['horizontal']![cell.row - 1][cell.col] == 1),
          bottom: _getBorder(cell.row == size - 1 || borders['horizontal']![cell.row][cell.col] == 1),
          left: _getBorder(cell.col == 0 || borders['vertical']![cell.row][cell.col - 1] == 1),
          right: _getBorder(cell.col == size - 1 || borders['vertical']![cell.row][cell.col] == 1),
        ),
      ),
      child: cellContent,
    );
  }

  BorderSide _getBorder(bool hasBorder) {
    return BorderSide(
      color: Colors.black,
      width: hasBorder ? 4.0 : 0.5,
    );
  }
}