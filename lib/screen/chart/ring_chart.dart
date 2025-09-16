import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';

class RingChart extends StatelessWidget {
  final String temperatura;
  final double valor; // Adicione esta propriedade

  const RingChart({
    super.key,
    required this.temperatura,
    required this.valor, // Adicione este parâmetro
  });

  @override
  Widget build(BuildContext context) {
    // Calcular a porcentagem baseada em uma faixa razoável de temperatura (ex: 0-50°C)
    double porcentagem = (valor.clamp(0, 50) / 50); // Limita entre 0% e 100%

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
                  Icons
                      .thermostat_outlined, // Ícone mais apropriado para temperatura
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
                              value: porcentagem * 100, // Valor preenchido
                              color: _getTemperatureColor(
                                valor,
                              ), // Cor baseada na temperatura
                              showTitle: false,
                              radius: 5,
                            ),
                            PieChartSectionData(
                              value: (1 - porcentagem) * 100, // Valor restante
                              color: Colors.grey,
                              showTitle: false,
                              radius: 5,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            temperatura != '--'
                                ? '${double.parse(temperatura).toStringAsFixed(1)}°C'
                                : '--°C',
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

  // Função para determinar a cor baseada na temperatura
  Color _getTemperatureColor(double temp) {
    if (temp < 15) return Colors.blue; // Frio
    if (temp < 25) return Colors.green; // Ideal
    if (temp < 35) return Colors.orange; // Quente
    return Colors.red; // Muito quente
  }
}
