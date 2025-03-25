import 'package:flutter/material.dart';
import 'dart:math';

/// Painter responsável por desenhar o gráfico donut
class DonutChartPainter extends CustomPainter {
  final double percentage;   // valor entre 0.0 e 1.0
  final Color color;         // cor do arco
  final double strokeWidth;  // espessura do anel

  DonutChartPainter({
    required this.percentage,
    required this.color,
    this.strokeWidth = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - strokeWidth;

    // Círculo de fundo (cinza claro)
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Arco que representa a porcentagem
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double sweepAngle = 2 * pi * percentage; // converte porcentagem para radianos

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,    // começa do topo
      sweepAngle, // ângulo do arco
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    // Re-renderiza caso alguma propriedade mude
    return oldDelegate.percentage != percentage ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Widget que encapsula o DonutChartPainter
class DonutChartWidget extends StatelessWidget {
  final double percentage;
  final double strokeWidth;
  final Color color;
  final double size;

  const DonutChartWidget({
    Key? key,
    required this.percentage,
    this.strokeWidth = 20.0,
    this.color = Colors.blue,
    this.size = 150.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DonutChartPainter(
        percentage: percentage,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
