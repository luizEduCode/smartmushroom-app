// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smartmshroom_app/constants.dart';

class OnebarChart extends StatelessWidget {
  const OnebarChart({super.key});

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
                      OnebarChart(),
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
