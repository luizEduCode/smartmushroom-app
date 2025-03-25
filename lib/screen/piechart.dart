import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Piechart extends StatefulWidget {
  const Piechart({super.key});

  @override
  State<Piechart> createState() => _PiechartState();
}

class _PiechartState extends State<Piechart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Umidade', style: TextStyle(fontSize: 18)),
                        Icon(Icons.water_drop_outlined),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Definindo tamanho fixo para o gráfico
                    Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: PieChart(
                          PieChartData(
                            startDegreeOffset: 360,
                            sectionsSpace: 0,
                            centerSpaceRadius: 30,
                            sections: [
                              PieChartSectionData(
                                value: 50,
                                color: Colors.black,
                                showTitle: false,
                                radius: 15,
                              ),
                              PieChartSectionData(
                                value: 100,
                                color: Colors.grey,
                                showTitle: false,
                                radius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
