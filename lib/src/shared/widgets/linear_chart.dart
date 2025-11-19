import 'package:flutter/material.dart';

/// Painter responsável por desenhar o gráfico de barra linear
class LinearBarChartPainter extends CustomPainter {
  final double percentage; // valor entre 0.0 e 1.0
  final Color color; // cor do preenchimento
  final double barHeight; // altura da barra
  final Color backgroundColor;

  LinearBarChartPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
    this.barHeight = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calcula a posição vertical para centralizar a barra no widget
    final double top = (size.height - barHeight) / 2;

    // Retângulo de fundo (barra completa)
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
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
  final Color? color;
  final Color? backgroundColor;
  final double width;
  final double height;

  const LinearBarChartWidget({
    super.key,
    required this.percentage,
    this.barHeight = 20.0,
    this.color,
    this.backgroundColor,
    this.width = 200.0,
    this.height = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: Size(width, height),
      painter: LinearBarChartPainter(
        percentage: percentage,
        color: color ?? scheme.tertiary,
        backgroundColor:
            backgroundColor ?? scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        barHeight: barHeight,
      ),
    );
  }
}
