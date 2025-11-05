import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/sala/data/sala_remote_datasource.dart';
import 'package:smartmushroom_app/models/Chart_Data_Model.dart';

class Co2Linechart extends StatefulWidget {
  final String idLote;

  const Co2Linechart({super.key, required this.idLote});

  @override
  State<Co2Linechart> createState() => _Co2LinechartState();
}

class _Co2LinechartState extends State<Co2Linechart> {
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
        metric: 'co2',
        aggregation: 'daily',
      );
    });
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
                      'Nenhum dado de CO² disponível para o período.',
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

              Color chartColor = Color(
                int.parse(chartData.metadata.color.replaceFirst('#', '0xFF')),
              );

              return SizedBox(
                height: 175,
                child: LineChart(
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
                    backgroundColor: Colors.white30,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles()),
                      topTitles: const AxisTitles(sideTitles: SideTitles()),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval:
                              (spots.length > 1)
                                  ? (spots.length / 5).floor().toDouble().clamp(
                                    1,
                                    spots.length.toDouble(),
                                  )
                                  : 1,
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
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval:
                              (maxY > minY)
                                  ? ((maxY - minY) / 4).ceilToDouble().clamp(
                                    100,
                                    double.infinity,
                                  )
                                  : 100,
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
                        getTooltipColor: (spot) => Colors.blueGrey, // Changed here
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final originalData = chartData.data[spot.spotIndex];
                            return LineTooltipItem(
                              '${originalData.label}\n${spot.y.toStringAsFixed(0)} ppm',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
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
}