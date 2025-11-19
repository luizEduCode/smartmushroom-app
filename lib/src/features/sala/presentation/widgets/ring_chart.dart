import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
const double _chartPadding = 16.0;

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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onPrimary = colorScheme.onPrimary;

    return Card(
      color: colorScheme.primary,
      surfaceTintColor: colorScheme.primary,
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
                  Icons
                      .thermostat_outlined, // Ícone mais apropriado para temperatura
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
                                colorScheme,
                              ), // Cor baseada na temperatura
                              showTitle: false,
                              radius: 5,
                            ),
                            PieChartSectionData(
                              value: (1 - porcentagem) * 100, // Valor restante
                              color: onPrimary.withValues(alpha: 0.2),
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
                                ? '${double.parse(temperatura).toStringAsFixed(0)}°C'
                                : '--°C',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: onPrimary,
                            ),
                          ),
                          Text(
                            'Celcius',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: onPrimary.withValues(alpha: 0.8),
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
  Color _getTemperatureColor(double temp, ColorScheme scheme) {
    if (temp < 15) return scheme.error;
    if (temp < 25) return scheme.tertiary;
    if (temp < 35) return scheme.secondary;
    return scheme.error.withValues(alpha: 0.8);
  }
}
