import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Co2Linechart extends StatelessWidget {
  const Co2Linechart({super.key});

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
                        FlSpot(1, 420),
                        FlSpot(2, 880),
                        FlSpot(3, 610),
                        FlSpot(4, 370),
                        FlSpot(5, 750),
                        FlSpot(6, 480),
                        FlSpot(7, 890),
                        FlSpot(8, 500),
                        FlSpot(9, 455),
                        FlSpot(10, 660),
                        FlSpot(11, 590),
                        FlSpot(12, 710),
                        FlSpot(13, 620),
                        FlSpot(14, 580),
                        FlSpot(15, 900),
                        FlSpot(16, 540),
                        FlSpot(17, 490),
                        FlSpot(18, 770),
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
                  minY: 200,
                  maxY: 1200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
