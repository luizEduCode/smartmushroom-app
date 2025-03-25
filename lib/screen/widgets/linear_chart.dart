import 'package:flutter/material.dart';

/// Painter responsável por desenhar o gráfico de barra linear
class LinearBarChartPainter extends CustomPainter {
  final double percentage; // valor entre 0.0 e 1.0
  final Color color; // cor do preenchimento
  final double barHeight; // altura da barra

  LinearBarChartPainter({
    required this.percentage,
    required this.color,
    this.barHeight = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calcula a posição vertical para centralizar a barra no widget
    final double top = (size.height - barHeight) / 2;

    // Retângulo de fundo (barra completa)
    final backgroundPaint =
        Paint()
          ..color = Colors.grey[300]!
          ..style = PaintingStyle.fill;

    final Rect backgroundRect = Rect.fromLTWH(0, top, size.width, barHeight);
    canvas.drawRect(backgroundRect, backgroundPaint);

    // Retângulo que representa a porcentagem preenchida
    final foregroundPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    double filledWidth = size.width * percentage;
    final Rect filledRect = Rect.fromLTWH(0, top, filledWidth, barHeight);
    canvas.drawRect(filledRect, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant LinearBarChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.color != color ||
        oldDelegate.barHeight != barHeight;
  }
}

/// Widget que encapsula o LinearBarChartPainter
class LinearBarChartWidget extends StatelessWidget {
  final double percentage;
  final double barHeight;
  final Color color;
  final double width;
  final double height;

  const LinearBarChartWidget({
    Key? key,
    required this.percentage,
    this.barHeight = 20.0,
    this.color = Colors.blue,
    this.width = 200.0,
    this.height = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: LinearBarChartPainter(
        percentage: percentage,
        color: color,
        barHeight: barHeight,
      ),
    );
  }
}
