import 'package:flutter/material.dart';

class LinePainter extends CustomPainter{
  final Offset start;
  final Offset end;
  final double width;
  final Color color;

  LinePainter({required this.start, required this.end, required this.width, this.color = Colors.red});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color// 선 색상
      ..strokeWidth = width; // 선 두께

    // 캔버스에 선을 그림
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}