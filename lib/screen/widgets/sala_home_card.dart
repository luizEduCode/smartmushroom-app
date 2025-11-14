import 'package:flutter/material.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';

const double _cardPadding = 16.0;

class SalahomeCard extends StatelessWidget {
  final String nomeSala;
  final String nomeCogumelo;
  final String faseCultivo;
  final String idLote;
  final String temperatura;
  final String umidade;
  final String co2;
  final String status;
  final int idCogumelo; // novo parâmetro

  const SalahomeCard({
    super.key,
    required this.nomeSala,
    required this.nomeCogumelo,
    required this.faseCultivo,
    required this.idLote,
    required this.temperatura,
    required this.umidade,
    required this.co2,
    required this.status, // novo parâmetro
    required this.idCogumelo, // novo parâmetro
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
            builder: (context) => SalaPage(nomeSala: nomeSala, idLote: idLote),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_cardPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      nomeSala,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: foregroundColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                //Row do cogumelo
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$nomeCogumelo | ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: foregroundColor,
                          ),
                        ),
                        Text(
                          faseCultivo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: foregroundColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14),
                //Row dos parâmetros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      temperatura != '--'
                          ? '${double.parse(temperatura).toStringAsFixed(0)}°C'
                          : '--°C',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: foregroundColor,
                      ),
                    ),
                    SizedBox(width: _cardPadding / 6),
                    Text(
                      umidade != '--'
                          ? '${double.parse(umidade).toStringAsFixed(0)}%'
                          : '--%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: foregroundColor,
                      ),
                    ),
                    SizedBox(width: _cardPadding / 6),
                    Text(
                      co2 != '--'
                          ? '${double.parse(co2).toStringAsFixed(0)} ppm'
                          : '--',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: foregroundColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
