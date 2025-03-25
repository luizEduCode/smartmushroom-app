import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';

class RingChart extends StatelessWidget {
  const RingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: primaryColor,
      surfaceTintColor: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperatura',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: defaultPadding,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.water_drop_outlined,
                  color: Colors.white,
                  size: defaultPadding,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: 90,
                          sectionsSpace: 0,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(
                              value: 50,
                              color: Color.fromARGB(255, 97, 247, 28),
                              showTitle: false,
                              radius: 5,
                            ),
                            PieChartSectionData(
                              value: 50,
                              color: Colors.grey,
                              showTitle: false,
                              radius: 5,
                            ),
                          ],
                        ),
                      ),
                      // Texto que ficará no centro do PieChart
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '22°',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Celcius',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
