import 'package:flutter/material.dart';
const double _chartPadding = 16.0;

class OnebarChart extends StatelessWidget {
  const OnebarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    return Card(
      color: theme.colorScheme.primary,
      surfaceTintColor: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(_chartPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperatura',
                  style: TextStyle(
                    color: onPrimary,
                    fontSize: _chartPadding,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.water_drop_outlined,
                  color: onPrimary,
                  size: _chartPadding,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(_chartPadding),
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
                              color: onPrimary,
                            ),
                          ),
                          Text(
                            'Celcius',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              color: onPrimary,
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
