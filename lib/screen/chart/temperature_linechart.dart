import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperatureLinechart extends StatelessWidget {
  const TemperatureLinechart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 214, 214, 214),
      surfaceTintColor: Colors.grey, // Correção aqui
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Substituindo `defaultPadding`
        child: Column(
          children: [
            Container(
              width: 350,
              height: 175,
              decoration: const BoxDecoration(),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(1, 28),
                        FlSpot(2, 29),
                        FlSpot(3, 26),
                        FlSpot(4, 17),
                        FlSpot(5, 22),
                        FlSpot(6, 26),
                        FlSpot(7, 24),
                        FlSpot(8, 26),
                        FlSpot(9, 19),
                        FlSpot(10, 27),
                        FlSpot(11, 25),
                        FlSpot(12, 26),
                        FlSpot(13, 28),
                        FlSpot(14, 28),
                        FlSpot(15, 30),
                        FlSpot(16, 25),
                        FlSpot(17, 21),
                        FlSpot(18, 30),
                      ],
                      color: const Color.fromARGB(255, 36, 91, 136),
                      barWidth: 3,
                      isCurved: false,
                      isStrokeCapRound: true,
                      isStrokeJoinRound: false,
                      shadow: const Shadow(
                        color: Color.fromARGB(115, 254, 254, 254),
                        blurRadius: 4,
                      ),
                    ),
                  ],
                  backgroundColor: Colors.white30,
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Temperatura',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    topTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Analises Periodicas',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ),
                  minX: 1,
                  maxX: 18,
                  minY: 15,
                  maxY: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
