// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:smartmushroom_app/constants.dart';
// import 'package:smartmushroom_app/screen/painelSalas_page.dart';
// import 'package:smartmushroom_app/screen/widgets/salaHome_card.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late Timer _timer;
//   List _salas = []; // Lista para armazenar os dados das salas
//   bool _isLoading = true; // Indica se está carregando os dados
//   bool _hasError = false; // Indica se houve erro na requisição

//   static const String apiBaseUrl = 'http://192.168.15.7/smartmushroom-api/';

//   @override
//   void initState() {
//     super.initState();
//     fetchSalas(); // Carrega os dados iniciais

//     // Atualiza automaticamente os dados a cada 10 segundos
//     _timer = Timer.periodic(Duration(seconds: 10), (timer) {
//       fetchSalas();
//     });
//   }

//   Future<void> fetchSalas() async {
//     try {
//       final response = await http.get(Uri.parse('${apiBaseUrl}salas.php'));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _salas = data['sala'] ?? [];
//           _isLoading = false;
//           _hasError = false;
//         });
//       } else {
//         setState(() {
//           _hasError = true;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//       });
//       debugPrint('Error fetching salas: $e');
//     }
//   }

//   Future<void> vincularLote(int idSala, int idLote) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://192.168.15.7/smartmushroom-api/salas.php'),
//         body: {'idSala': idSala.toString(), 'idLote': idLote.toString()},
//       );

//       if (response.statusCode == 200) {
//         // Atualiza a lista de salas
//         fetchSalas();
//       } else {
//         setState(() {
//           _hasError = true;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//       });
//     }
//   }

//   Stream<String> getCurrentDateTimeStream() async* {
//     while (true) {
//       await Future.delayed(const Duration(seconds: 1));
//       final now = DateTime.now();
//       yield DateFormat('dd MMMM yyyy', 'pt_BR').format(now);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset('assets/logo.png', height: 40),
//         backgroundColor: primaryColor,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(defaultPadding),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const SizedBox(width: defaultPadding),
//                       Text(
//                         'Olá Colaborador!',
//                         style: TextStyle(
//                           color: primaryColor,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: defaultPadding),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const SizedBox(width: defaultPadding),
//                       StreamBuilder<String>(
//                         stream: getCurrentDateTimeStream(),
//                         builder: (context, snapshot) {
//                           return Text(
//                             snapshot.data ?? '',
//                             style: TextStyle(
//                               color: primaryColor,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: defaultPadding),

//               RefreshIndicator(
//                 onRefresh: fetchSalas,
//                 child:
//                     _isLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : _hasError
//                         ? const Center(child: Text('Erro ao carregar dados'))
//                         : GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2, // 2 cards por linha
//                             crossAxisSpacing:
//                                 defaultPadding, // Espaço horizontal entre cards
//                             mainAxisSpacing:
//                                 defaultPadding, // Espaço vertical entre cards
//                             childAspectRatio:
//                                 0.9, // Proporção largura/altura (ajuste conforme necessário)
//                           ),
//                           itemCount: _salas.length,
//                           itemBuilder: (context, index) {
//                             final sala = _salas[index];
//                             return Padding(
//                               padding: const EdgeInsets.only(bottom: 10),
//                               child: SalahomeCard(
//                                 idLote: sala['idLote'].toString(),
//                                 nomeSala: sala['nomeSala'] ?? 'Sem nome',
//                                 nomeCogumelo: sala['nomeCogumelo'] ?? '',
//                                 faseCultivo: sala['nomeFaseCultivo'] ?? '',

//                                 temperatura:
//                                     sala['temperatura'] != null
//                                         ? (double.tryParse(
//                                                   sala['temperatura']
//                                                       .toString(),
//                                                 ) ??
//                                                 0)
//                                             .toStringAsFixed(0)
//                                         : '--',
//                                 umidade:
//                                     sala['umidade'] != null
//                                         ? (double.tryParse(
//                                                   sala['umidade'].toString(),
//                                                 ) ??
//                                                 0)
//                                             .toStringAsFixed(0)
//                                         : '--',
//                                 co2:
//                                     sala['co2'] != null
//                                         ? (double.tryParse(
//                                                   sala['co2'].toString(),
//                                                 ) ??
//                                                 0)
//                                             .toStringAsFixed(0)
//                                         : '--',
//                                 status: sala['status'] ?? '',
//                               ),
//                             );
//                           },
//                         ),
//               ),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => PainelsalasPage(),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       height: 150,
//                       width: 181,
//                       decoration: BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withAlpha(100),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                             offset: const Offset(4, 4),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 'assets/icone_Estufa.png',
//                                 width: 120,
//                               ),
//                             ],
//                           ),
//                           const Text(
//                             'Painel Salas',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: defaultPadding),
//                   Container(
//                     height: 150,
//                     width: 181,
//                     decoration: BoxDecoration(
//                       color: primaryColor,
//                       borderRadius: BorderRadius.circular(30),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withAlpha(100),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                           offset: const Offset(4, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [Image.asset('assets/icone_Relatorio.png')],
//                         ),
//                         const Text(
//                           'Relatórios',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/painelSalas_page.dart';
import 'package:smartmushroom_app/screen/widgets/salaHome_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  List _salas = [];
  bool _isLoading = true;
  bool _hasError = false;

  static const String apiBaseUrl = 'http://192.168.15.7/smartmushroom-api/';

  @override
  void initState() {
    super.initState();
    fetchSalas();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchSalas();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchSalas() async {
    try {
      final response = await http.get(Uri.parse('${apiBaseUrl}salas.php'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _salas = data['sala'] ?? [];
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Error fetching salas: $e');
    }
  }

  Future<void> vincularLote(int idSala, int idLote) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.15.7/smartmushroom-api/salas.php'),
        body: {'idSala': idSala.toString(), 'idLote': idLote.toString()},
      );

      if (response.statusCode == 200) {
        fetchSalas();
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  Stream<String> getCurrentDateTimeStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final now = DateTime.now();
      yield DateFormat('dd MMMM yyyy', 'pt_BR').format(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: defaultPadding),
                      Text(
                        'Olá Colaborador!',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: defaultPadding),
                      StreamBuilder<String>(
                        stream: getCurrentDateTimeStream(),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? '',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              RefreshIndicator(
                onRefresh: fetchSalas,
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _hasError
                        ? const Center(child: Text('Erro ao carregar dados'))
                        : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: defaultPadding,
                                mainAxisSpacing: defaultPadding,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: _salas.length,
                          itemBuilder: (context, index) {
                            final sala = _salas[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SalahomeCard(
                                idLote: sala['idLote'].toString(),
                                nomeSala: sala['nomeSala'] ?? 'Sem nome',
                                nomeCogumelo: sala['nomeCogumelo'] ?? '',
                                faseCultivo: sala['nomeFaseCultivo'] ?? '',
                                temperatura:
                                    sala['temperatura'] != null
                                        ? (double.tryParse(
                                                  sala['temperatura']
                                                      .toString(),
                                                ) ??
                                                0)
                                            .toStringAsFixed(0)
                                        : '--',
                                umidade:
                                    sala['umidade'] != null
                                        ? (double.tryParse(
                                                  sala['umidade'].toString(),
                                                ) ??
                                                0)
                                            .toStringAsFixed(0)
                                        : '--',
                                co2:
                                    sala['co2'] != null
                                        ? (double.tryParse(
                                                  sala['co2'].toString(),
                                                ) ??
                                                0)
                                            .toStringAsFixed(0)
                                        : '--',
                                status: sala['status'] ?? '',
                              ),
                            );
                          },
                        ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PainelsalasPage(),
                        ),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: 181,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(100),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icone_Estufa.png',
                                width: 120,
                              ),
                            ],
                          ),
                          const Text(
                            'Painel Salas',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Container(
                    height: 150,
                    width: 181,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Image.asset('assets/icone_Relatorio.png')],
                        ),
                        const Text(
                          'Relatórios',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
