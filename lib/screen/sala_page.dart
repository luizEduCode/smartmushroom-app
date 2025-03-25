import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/chart/bar_indicator.dart';
import 'package:smartmushroom_app/screen/chart/oneBar_chart.dart';
import 'package:smartmushroom_app/screen/chart/ring_chart.dart';

class SalaPage extends StatefulWidget {
  const SalaPage({super.key});

  @override
  State<SalaPage> createState() => _SalaPageState();
}

class _SalaPageState extends State<SalaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 234, 234, 1),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Sala 01',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        // ...
      ),

      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: RingChart()),

                SizedBox(width: 16),

                //Descritivo do Lote
                Expanded(
                  child: Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cogumelo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Shimeji Branco',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Fase',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Colonização',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Data Início',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '01/01/2025',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Lote',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'P49000101',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            //Gráficos de Umidade e CO2
            Row(
              children: [
                BarIndicator(
                  label: 'Umidade',
                  icon: Icons.water_drop_outlined,
                  percentage: 50,
                  valueLabel: '88%',
                  color: Colors.blueAccent,
                ),
                SizedBox(width: defaultPadding),
                BarIndicator(
                  label: 'Nível CO²',
                  icon: Icons.cloud_outlined,
                  percentage: 50, // Ex: 1500ppm de um total de 2000
                  valueLabel: '1500 ppm',
                  color: Colors.orangeAccent,
                ),
              ],
            ),

            SizedBox(height: 16),

            // Barra de atuadores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: secontaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Icon(Icons.ac_unit_rounded, color: Colors.white),
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: secontaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Icon(Icons.ac_unit_rounded, color: Colors.white),
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: secontaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Icon(Icons.ac_unit_rounded, color: Colors.white),
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: secontaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Icon(Icons.ac_unit_rounded, color: Colors.white),
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: secontaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Icon(Icons.ac_unit_rounded, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
          ],
        ),
      ),
    );
  }
}
