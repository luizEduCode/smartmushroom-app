import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/sala/data/sala_remote_datasource.dart';
import 'package:smartmushroom_app/models/chart_data_model.dart';

class TemperatureLinechart extends StatefulWidget {
  final String idLote;

  const TemperatureLinechart({super.key, required this.idLote});

  @override
  State<TemperatureLinechart> createState() => _TemperatureLinechartState();
}

class _TemperatureLinechartState extends State<TemperatureLinechart> {
  late SalaRemoteDataSource _dataSource;
  late Future<ChartDataModel> _chartDataFuture;

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
        metric: 'temperatura',
        aggregation: 'daily',
      );
    });
  }

  void refreshChart() {
    _fetchChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 214, 214, 214),
      surfaceTintColor: Colors.grey,
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
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final chartData = snapshot.data!;

              if (chartData.data.isEmpty) {
                return const SizedBox(
                  height: 175,
                  child: Center(
                    child: Text(
                      'Nenhum dado de temperatura disponível para o período.',
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
              minY = (minY - (minY * 0.1)).floorToDouble();
              maxY = (maxY + (maxY * 0.1)).ceilToDouble();
              if (minY == maxY) {
                minY -= 5;
                maxY += 5;
              }

              double minX = 0;
              double maxX = (spots.length - 1).toDouble();

              List<String> xLabels =
                  chartData.data.map((e) => e.label).toList();

              Color chartColor = Color(
                int.parse(chartData.metadata.color.replaceFirst('#', '0xFF')),
              );

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 175,
                    decoration: const BoxDecoration(),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            color: chartColor,
                            barWidth: 3,
                            isCurved: false,
                            isStrokeCapRound: true,
                            isStrokeJoinRound: false,
                            shadow: const Shadow(
                              color: Color.fromARGB(115, 254, 254, 254),
                              blurRadius: 4,
                            ),
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                        backgroundColor: Colors.white30,
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles()),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < xLabels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      xLabels[index],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              interval:
                                  (spots.length > 1)
                                      ? (spots.length / 5)
                                          .floor()
                                          .toDouble()
                                          .clamp(1, spots.length.toDouble())
                                      : 1,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                        minX: minX,
                        maxX: maxX,
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine:
                              (value) => const FlLine(
                                color: Colors.grey,
                                strokeWidth: 0.5,
                              ),
                        ),

                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor:
                                (spot) => Colors.blueGrey, // Changed here
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((
                                LineBarSpot touchedSpot,
                              ) {
                                final originalData =
                                    chartData.data[touchedSpot.spotIndex];
                                return LineTooltipItem(
                                  '${originalData.label}\n${touchedSpot.y.toStringAsFixed(1)} ${chartData.metadata.yAxisLabel.split(' ').last}',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
}
