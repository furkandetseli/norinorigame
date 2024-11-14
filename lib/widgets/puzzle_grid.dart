import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/puzzle.dart';
import 'puzzle_cell.dart';
import '../widgets/game_controls.dart';

class PuzzleGrid extends StatefulWidget {
  final Puzzle puzzle;
  final Function(Cell) onCellTap;
  final PaintMode selectedMode;
  final bool isEnabled;

  const PuzzleGrid({
    Key? key,
    required this.puzzle,
    required this.onCellTap,
    required this.selectedMode,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<PuzzleGrid> createState() => _PuzzleGridState();
}

class _PuzzleGridState extends State<PuzzleGrid> {
  Cell? _lastModifiedCell;
  bool _isDragging = false;

  void _handleCellInteraction(Cell cell) {
    if (!widget.isEnabled) return;
    if (_lastModifiedCell == cell) return;

    _lastModifiedCell = cell;
    widget.onCellTap(cell);
  }

  Cell? _getCellFromOffset(Offset localPosition, BoxConstraints constraints) {
    final cellSize = constraints.maxWidth / widget.puzzle.size;
    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();

    if (row >= 0 && row < widget.puzzle.size && col >= 0 && col < widget.puzzle.size) {
      return widget.puzzle.cells[row][col];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onPanStart: (details) {
              _isDragging = true;
              final cell = _getCellFromOffset(details.localPosition, constraints);
              if (cell != null) {
                _handleCellInteraction(cell);
              }
            },
            onPanUpdate: (details) {
              if (!_isDragging) return;
              final cell = _getCellFromOffset(details.localPosition, constraints);
              if (cell != null) {
                _handleCellInteraction(cell);
              }
            },
            onPanEnd: (details) {
              _isDragging = false;
              _lastModifiedCell = null;
            },
            onPanCancel: () {
              _isDragging = false;
              _lastModifiedCell = null;
            },
            onTapUp: (details) {
              final cell = _getCellFromOffset(details.localPosition, constraints);
              if (cell != null) {
                _handleCellInteraction(cell);
              }
              _lastModifiedCell = null;
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.puzzle.size,
                ),
                itemCount: widget.puzzle.size * widget.puzzle.size,
                itemBuilder: (context, index) {
                  int row = index ~/ widget.puzzle.size;
                  int col = index % widget.puzzle.size;
                  Cell cell = widget.puzzle.cells[row][col];

                  return PuzzleCell(
                    cell: cell,
                    borders: widget.puzzle.borders,
                    size: widget.puzzle.size,
                    selectedMode: widget.selectedMode,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}