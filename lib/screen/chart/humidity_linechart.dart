import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HumidityLinechart extends StatelessWidget {
  const HumidityLinechart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 214, 214, 214),
      surfaceTintColor: Colors.grey, // Correção aqui
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: 350,
              height: 175,
              decoration: const BoxDecoration(),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(1, 55),
                        FlSpot(2, 72),
                        FlSpot(3, 60),
                        FlSpot(4, 41),
                        FlSpot(5, 67),
                        FlSpot(6, 48),
                        FlSpot(7, 74),
                        FlSpot(8, 50),
                        FlSpot(9, 45),
                        FlSpot(10, 66),
                        FlSpot(11, 59),
                        FlSpot(12, 70),
                        FlSpot(13, 62),
                        FlSpot(14, 58),
                        FlSpot(15, 75),
                        FlSpot(16, 54),
                        FlSpot(17, 49),
                        FlSpot(18, 71),
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
                        'Umidade',
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
                  minY: 1,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
