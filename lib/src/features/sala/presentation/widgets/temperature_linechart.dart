import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/chart_data_model.dart';
import 'package:smartmushroom_app/src/features/sala/presentation/viewmodels/chart_aggregation.dart';

class TemperatureLinechart extends StatelessWidget {
  const TemperatureLinechart({
    super.key,
    required this.aggregation,
    required this.data,
    required this.isLoading,
    required this.errorMessage,
  });

  final ChartAggregation aggregation;
  final ChartDataModel? data;
  final bool isLoading;
  final String? errorMessage;

  static final DateFormat _dailyLabelFormat = DateFormat('d MMM', 'pt_BR');
  static final DateFormat _dailyWithTimeFormat =
      DateFormat('d MMM HH:mm', 'pt_BR');
  static final DateFormat _weeklyLabelFormat = DateFormat('dd/MM', 'pt_BR');
  static final DateFormat _monthlyLabelFormat = DateFormat('MMM yy', 'pt_BR');
  static final DateFormat _hourLabelFormat = DateFormat('HH:mm', 'pt_BR');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final axisTextStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    Widget child;
    if (isLoading) {
      child = const _ChartLoading();
    } else if (errorMessage != null) {
      child = _ChartMessage(
        message: 'Erro ao carregar o gráfico: $errorMessage',
        color: scheme.error,
      );
    } else if (data == null || data!.data.isEmpty) {
      child = _ChartMessage(
        message: 'Nenhum dado de temperatura disponível para o período.',
        color: scheme.onSurfaceVariant,
      );
    } else {
      child = _buildChart(
        scheme: scheme,
        axisTextStyle: axisTextStyle,
        chartData: data!,
      );
    }

    return Card(
      color: theme.cardColor,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildChart({
    required ColorScheme scheme,
    required TextStyle? axisTextStyle,
    required ChartDataModel chartData,
  }) {
    final spots = chartData.data
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.y))
        .toList();

    double minY = spots
        .map((e) => e.y)
        .reduce((a, b) => a < b ? a : b);
    double maxY = spots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);
    minY = (minY - (minY * 0.1)).floorToDouble();
    maxY = (maxY + (maxY * 0.1)).ceilToDouble();
    if (minY == maxY) {
      minY -= 5;
      maxY += 5;
    }

    final xLabels = chartData.data.map((e) => e.label).toList();

    Color chartColor;
    try {
      chartColor = Color(
        int.parse(chartData.metadata.color.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      chartColor = scheme.tertiary;
    }

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelStep = _labelStepForWidth(
            constraints.maxWidth,
            xLabels.length,
          );
          final slotWidth = _labelSlotWidth(
            constraints.maxWidth,
            xLabels.length,
            labelStep,
          );
          return LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: chartColor,
                  barWidth: 3,
                  isCurved: false,
                  isStrokeCapRound: true,
                  isStrokeJoinRound: false,
                  shadow: Shadow(
                    color: scheme.onSurface.withValues(alpha: 0.15),
                    blurRadius: 4,
                  ),
                  dotData: const FlDotData(show: false),
                ),
              ],
              backgroundColor:
                  scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles()),
                topTitles: const AxisTitles(sideTitles: SideTitles()),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _bottomLabelReserve,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      return _buildBottomTitle(
                        index: index,
                        labels: xLabels,
                        style: axisTextStyle,
                        step: labelStep,
                        slotWidth: slotWidth,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: axisTextStyle,
                      );
                    },
                    interval:
                        (maxY > minY)
                            ? ((maxY - minY) / 4)
                                .ceilToDouble()
                                .clamp(1, double.infinity)
                            : 1,
                  ),
                ),
              ),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: scheme.outlineVariant,
                  strokeWidth: 0.5,
                ),
              ),
              clipData: const FlClipData.all(),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (spot) => scheme.primary,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      final originalData =
                          chartData.data[touchedSpot.spotIndex];
                      final suffix =
                          chartData.metadata.yAxisLabel.split(' ').last;
                      return LineTooltipItem(
                        '${originalData.label}\n${touchedSpot.y.toStringAsFixed(1)} $suffix',
                        TextStyle(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomTitle({
    required int index,
    required List<String> labels,
    required TextStyle? style,
    required int step,
    required double slotWidth,
  }) {
    if (index < 0 || index >= labels.length) {
      return const SizedBox.shrink();
    }

    final bool isBoundary = index == labels.length - 1;
    if (!isBoundary && index % step != 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: slotWidth,
        child: Text(
          _formatLabel(labels[index]),
          style: style,
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  int _labelStepForWidth(double width, int labelCount) {
    if (labelCount <= 1) return 1;
    const double minSpacing = 72;
    final maxLabels = math.max(1, (width / minSpacing).floor());
    final allowedLabels = math.min(labelCount, maxLabels);
    return math.max(1, (labelCount / allowedLabels).ceil());
  }

  double _labelSlotWidth(double width, int labelCount, int step) {
    final visibleLabels = math.max(1, (labelCount / step).ceil());
    final slot = width / visibleLabels;
    return slot.clamp(48.0, 90.0);
  }

  String _formatLabel(String raw) {
    final normalized = raw.trim();
    final parsed = DateTime.tryParse(normalized.replaceFirst(' ', 'T'));
    if (parsed != null) {
      switch (_aggregationKey) {
        case 'weekly':
          return _weeklyLabelFormat.format(parsed);
        case 'monthly':
          return _monthlyLabelFormat.format(parsed);
        case '24h':
          return _hourLabelFormat.format(parsed);
        default:
          final includeTime = normalized.contains(' ') ||
              normalized.contains('T');
          final format =
              includeTime ? _dailyWithTimeFormat : _dailyLabelFormat;
          return format.format(parsed);
      }
    }

    if (normalized.contains(' de ')) {
      final parts = normalized.split(' de ');
      if (parts.length >= 2) {
        final day = parts[0].trim();
        final month = parts[1].split(' ').first;
        return '$day ${_shortenLabel(month)}';
      }
    }

    if (normalized.contains('/')) {
      final pieces = normalized.split('/');
      if (pieces.length >= 2) {
        return '${pieces[0]}/${pieces[1]}';
      }
    }

    if (normalized.length > 8) {
      return '${normalized.substring(0, 7)}…';
    }

    return normalized;
  }

  String _shortenLabel(String value) {
    if (value.length <= 3) return value;
    return value.substring(0, 3);
  }

  double get _bottomLabelReserve {
    if (_aggregationKey == 'weekly' || _aggregationKey == 'monthly') {
      return 40;
    }
    if (_aggregationKey == '24h') {
      return 52;
    }
    return 48;
  }

  String get _aggregationKey => aggregation.apiValue;
}

class _ChartLoading extends StatelessWidget {
  const _ChartLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 175,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
        ),
      ),
    );
  }
}
