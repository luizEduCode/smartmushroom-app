import 'package:flutter/material.dart';
import 'package:smartmushroom_app/src/features/sala/presentation/pages/sala_page.dart';

class SalaCard extends StatelessWidget {
  final String nomeSala;
  final String nomeCogumelo;
  final String faseCultivo;
  final String dataInicio;
  final String idLote;
  final String temperatura;
  final String umidade;
  final String co2;
  final String status;
  final Map<int, bool> atuadoresStatus;

  const SalaCard({
    super.key,
    required this.nomeSala,
    required this.nomeCogumelo,
    required this.faseCultivo,
    required this.dataInicio,
    required this.idLote,
    required this.temperatura,
    required this.umidade,
    required this.co2,
    required this.status,
    required this.atuadoresStatus,
    required String idSala, // novo parâmetro
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isFinalizado = status == 'finalizado';
    final Color backgroundColor =
        isFinalizado ? colorScheme.surfaceContainerHighest : colorScheme.primary;
    final Color foregroundColor =
        isFinalizado ? colorScheme.onSurface : colorScheme.onPrimary;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SalaPage(
                  nomeSala: nomeSala,
                  idLote:
                      idLote, // Passando o idLote para a SalaPage // Passando o idCogumelo para a SalaPage
                ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeSala,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                        ),
                      ),
                      Text(
                        dataInicio,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: foregroundColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(4, (index) {
                          final idAtuador = index + 1;
                          final bool isAtivo =
                              atuadoresStatus[idAtuador] ?? false;
                          final Color iconColor =
                              isAtivo
                                  ? foregroundColor
                                  : foregroundColor.withValues(alpha: 0.35);
                          return Padding(
                            padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                            child: Icon(
                              _getAtuadorIcon(idAtuador),
                              size: 22,
                              color: iconColor,
                            ),
                          );
                        }),
                      ),

                      Text(
                        'Lote: $idLote',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),

              //Row do cogumelo
              Row(
                children: [
                  Text(
                    '$nomeCogumelo | $faseCultivo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              //Row dos parâmetros
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        temperatura != '--'
                            ? '${double.parse(temperatura).toStringAsFixed(0)}°C'
                            : '--°C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                        ),
                      ),
                      Text(
                        'Temperatura',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        umidade != '--'
                            ? '${double.parse(umidade).toStringAsFixed(0)}%'
                            : '--%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                        ),
                      ),
                      Text(
                        'Umidade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        co2 != '--'
                            ? double.parse(co2).toStringAsFixed(0)
                            : '--',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                        ),
                      ),
                      Text(
                        'ppm',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _getAtuadorIcon(int idAtuador) {
    switch (idAtuador) {
      case 1:
        return Icons.water_drop;
      case 2:
        return Icons.thermostat_outlined;
      case 3:
        return Icons.air;
      case 4:
        return Icons.light_mode;
      default:
        return Icons.smart_button;
    }
  }
}
