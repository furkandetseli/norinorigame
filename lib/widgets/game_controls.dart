import 'package:flutter/material.dart';

enum PaintMode {
  paint,
  cross,
  empty
}

class GameControls extends StatelessWidget {
  final PaintMode selectedMode;
  final int remainingHints;
  final int remainingLives;
  final Duration elapsed;
  final VoidCallback onHintPressed;
  final Function(PaintMode) onModeChanged;

  const GameControls({
    Key? key,
    required this.selectedMode,
    required this.remainingHints,
    required this.remainingLives,
    required this.elapsed,
    required this.onHintPressed,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.02;
    final buttonSize = size.width * 0.12;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.brush,
                    isSelected: selectedMode == PaintMode.paint,
                    onPressed: () => onModeChanged(PaintMode.paint),
                    size: buttonSize,
                    isDarkMode: isDarkMode,
                  ),
                  _buildControlButton(
                    icon: Icons.close,
                    isSelected: selectedMode == PaintMode.cross,
                    onPressed: () => onModeChanged(PaintMode.cross),
                    size: buttonSize,
                    isDarkMode: isDarkMode,
                  ),
                  _buildControlButton(
                    icon: Icons.clear_all,
                    isSelected: selectedMode == PaintMode.empty,
                    onPressed: () => onModeChanged(PaintMode.empty),
                    size: buttonSize,
                    isDarkMode: isDarkMode,
                  ),
                  _buildHintButton(
                    size: buttonSize,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 2,
                    vertical: padding,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(padding * 2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: size.width * 0.05,
                        color: isDarkMode ? Colors.grey[300] : Colors.black87,
                      ),
                      SizedBox(width: padding),
                      Text(
                        '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    3,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
                      child: Icon(
                        Icons.favorite,
                        color: index < remainingLives
                            ? (isDarkMode ? Colors.red[300] : Colors.red)
                            : (isDarkMode ? const Color(0xFF3D3D3D) : Colors.grey),
                        size: size.width * 0.06,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
    required double size,
    required bool isDarkMode,
  }) {
    final backgroundColor = isSelected
        ? (isDarkMode ? Colors.blue[300] : Colors.blue)
        : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.white);
    final iconColor = isSelected
        ? Colors.white
        : (isDarkMode ? Colors.grey[300] : Colors.blue);

    return Material(
      elevation: isSelected ? 6 : 2,
      borderRadius: BorderRadius.circular(size * 0.2),
      color: backgroundColor,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Container(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildHintButton({
    required double size,
    required bool isDarkMode,
  }) {
    final buttonColor = remainingHints > 0
        ? (isDarkMode ? Colors.amber[300] : Colors.amber)
        : (isDarkMode ? const Color(0xFF3D3D3D) : Colors.grey);

    return Stack(
      children: [
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(size * 0.2),
          color: buttonColor,
          child: InkWell(
            onTap: remainingHints > 0 ? onHintPressed : null,
            borderRadius: BorderRadius.circular(size * 0.2),
            child: Container(
              width: size,
              height: size,
              child: Icon(
                Icons.lightbulb,
                color: Colors.white,
                size: size * 0.5,
              ),
            ),
          ),
        ),
        if (remainingHints > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(size * 0.15),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.red[300] : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                remainingHints.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}