import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/sala/data/sala_remote_datasource.dart';
import 'package:smartmushroom_app/models/chart_data_model.dart';

class Co2Linechart extends StatefulWidget {
  final String idLote;
  final String aggregation;

  const Co2Linechart({
    super.key,
    required this.idLote,
    required this.aggregation,
  });

  @override
  State<Co2Linechart> createState() => _Co2LinechartState();
}

class _Co2LinechartState extends State<Co2Linechart> {
  late SalaRemoteDataSource _dataSource;
  late Future<ChartDataModel> _chartDataFuture;
  final DateFormat _dailyLabelFormat = DateFormat('d MMM', 'pt_BR');
  final DateFormat _dailyWithTimeFormat = DateFormat('d MMM HH:mm', 'pt_BR');
  final DateFormat _weeklyLabelFormat = DateFormat('dd/MM', 'pt_BR');
  final DateFormat _monthlyLabelFormat = DateFormat('MMM yy', 'pt_BR');
  final DateFormat _hourLabelFormat = DateFormat('HH:mm', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _dataSource = SalaRemoteDataSource(DioClient());
    _fetchChartData();
  }

  void _fetchChartData() {
    setState(() {
      _chartDataFuture = _dataSource.fetchChartData(
        idLote: widget.idLote,
        metric: 'co2',
        aggregation: widget.aggregation,
      );
    });
  }

  @override
  void didUpdateWidget(covariant Co2Linechart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aggregation != widget.aggregation) {
      _fetchChartData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final axisTextStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return Card(
      color: theme.cardColor,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<ChartDataModel>(
          future: _chartDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 175,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 175,
                child: Center(
                  child: Text(
                    'Erro ao carregar o gráfico: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final chartData = snapshot.data!;

              if (chartData.data.isEmpty) {
                return SizedBox(
                  height: 175,
                  child: Center(
                    child: Text(
                      'Nenhum dado de CO² disponível para o período.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              List<FlSpot> spots =
                  chartData.data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.y);
                  }).toList();

              double minY = spots
                  .map((e) => e.y)
                  .reduce((a, b) => a < b ? a : b);
              double maxY = spots
                  .map((e) => e.y)
                  .reduce((a, b) => a > b ? a : b);
              minY = (minY - (minY * 0.2)).floorToDouble();
              maxY = (maxY + (maxY * 0.2)).ceilToDouble();
              if (minY == maxY) {
                minY -= 200;
                maxY += 200;
              }

              double minX = 0;
              double maxX = (spots.length - 1).toDouble();

              List<String> xLabels =
                  chartData.data.map((e) => e.label).toList();

              Color chartColor;
              try {
                chartColor = Color(
                  int.parse(
                    chartData.metadata.color.replaceFirst('#', '0xFF'),
                  ),
                );
              } catch (_) {
                chartColor = scheme.secondary;
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
                                          .clamp(100, double.infinity)
                                      : 100,
                            ),
                          ),
                        ),
                        minX: minX,
                        maxX: maxX,
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
                              return touchedSpots.map((spot) {
                                final originalData = chartData.data[spot.spotIndex];
                                return LineTooltipItem(
                                  '${originalData.label}\n${spot.y.toStringAsFixed(0)} ppm',
                                  TextStyle(color: scheme.onPrimary),
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
            } else {
              return const SizedBox(
                height: 175,
                child: Center(child: Text('Carregando dados do gráfico...')),
              );
            }
          },
        ),
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
      switch (widget.aggregation) {
        case 'weekly':
          return _weeklyLabelFormat.format(parsed);
        case 'monthly':
          return _monthlyLabelFormat.format(parsed);
        case '24h':
          return _hourLabelFormat.format(parsed);
        default:
          final includeTime = normalized.contains(' ') || normalized.contains('T');
          final format = includeTime ? _dailyWithTimeFormat : _dailyLabelFormat;
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
    if (widget.aggregation == 'weekly' || widget.aggregation == 'monthly') {
      return 40;
    }
    if (widget.aggregation == '24h') {
      return 52;
    }
    return 48;
  }
}
