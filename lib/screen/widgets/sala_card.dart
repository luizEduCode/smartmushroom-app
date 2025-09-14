import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';

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
    required String idSala, // novo parâmetro
  });

  // @override
  // Widget build(BuildContext context) {
  //   // return InkWell(
  //   //   onTap: () {
  //   //     Navigator.push(
  //   //       context,
  //   //       MaterialPageRoute(builder: (context) => SalaPage(nomeSala: nomeSala)),
  //   //     );
  //   //   },
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
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        dataInicio,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, size: 22, color: Colors.white),
                          Icon(Icons.lightbulb, size: 22, color: Colors.white),
                          Icon(Icons.lightbulb, size: 22, color: Colors.white),
                          Icon(Icons.lightbulb, size: 22, color: Colors.white),
                        ],
                      ),

                      Text(
                        'Lote: $idLote',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
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
                      color: Colors.white,
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
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Temperatura',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Umidade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ppm',
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
            ],
          ),
        ),
      ),
    );
  }
}
