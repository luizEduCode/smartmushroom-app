import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';

class SalahomeCard extends StatelessWidget {
  final String nomeSala;
  final String nomeCogumelo;
  final String faseCultivo;
  final String idLote;
  final String temperatura;
  final String umidade;
  final String co2;
  final String status;

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
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SalaPage(
                  nomeSala: nomeSala,
                  idLote: idLote, // Passando o idLote para a SalaPage
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: status == 'finalizado' ? Colors.grey : primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomeSala,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        faseCultivo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: defaultPadding / 6),
                  Text(
                    umidade != '--'
                        ? '${double.parse(umidade).toStringAsFixed(0)}%'
                        : '--%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: defaultPadding / 6),
                  Text(
                    co2 != '--'
                        ? '${double.parse(co2).toStringAsFixed(0)} ppm'
                        : '--',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
