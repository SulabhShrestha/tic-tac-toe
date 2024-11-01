import 'package:flutter/material.dart';

enum WinLineType {
  horizontal,
  vertical,
  diagonalLeft, // Top-left to bottom-right
  diagonalRight, // Top-right to bottom-left
}

class CustomLinePainter extends StatelessWidget {
  final WinLineType lineType;
  final int row; // For horizontal lines
  final int column; // For vertical lines

  const CustomLinePainter({
    Key? key,
    required this.lineType,
    this.row = 0,
    this.column = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: LinePainter(
        winType: lineType,
        row: row,
        column: column,
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final WinLineType winType;
  final int row;
  final int column;

  LinePainter({
    required this.winType,
    required this.row,
    required this.column,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final halfHeight = size.height / 2;
    final halfWidth = size.width / 2;

    switch (winType) {
      case WinLineType.horizontal:
        canvas.drawLine(
          Offset(0, halfHeight),
          Offset(size.width, halfHeight),
          paint,
        );
        break;

      case WinLineType.vertical:
        canvas.drawLine(
          Offset(halfWidth, 0),
          Offset(halfWidth, size.height),
          paint,
        );
        break;

      case WinLineType.diagonalLeft:
        canvas.drawLine(
          Offset(0, 0),
          Offset(size.width, size.height),
          paint,
        );
        break;

      case WinLineType.diagonalRight:
        canvas.drawLine(
          Offset(size.width, 0),
          Offset(0, size.height),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
