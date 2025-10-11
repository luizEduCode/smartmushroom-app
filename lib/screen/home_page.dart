// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:smartmushroom_app/constants.dart';
// import 'package:smartmushroom_app/models/salas_lotes_ativos.dart';
// import 'package:smartmushroom_app/screen/criarLote_page.dart';
// import 'package:smartmushroom_app/screen/ip_page.dart';
// import 'package:smartmushroom_app/screen/painelSalas_page.dart';
// import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';
// import 'package:smartmushroom_app/screen/widgets/salaHome_card.dart';
// import 'package:smartmushroom_app/screen/sala_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late Timer _timer;
//   List _salas = [];
//   bool _isLoading = true;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchSalas();
//     _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       fetchSalas();
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   Future<void> fetchSalas() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${getApiBaseUrl()}framework/sala/listarSalasComLotesAtivos'),
//         headers: {'Accept': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Parse usando o modelo
//         final salasAtivos = SalaLotesAtivos.fromJson(data);
//         final List<Salas> listaSalas = salasAtivos.salas ?? [];

//         if (mounted) {
//           setState(() {
//             _salas = listaSalas;
//             _isLoading = false;
//             _hasError = false;
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _hasError = true;
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//           _isLoading = false;
//         });
//       }
//       debugPrint('Error fetching salas: $e');
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
//       appBar: CustomAppBar(
//         title: 'Smartmushroom',
//         showBackButton: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.route_outlined, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ConfigIPPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(defaultPadding),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Column(
//                 children: [
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(width: defaultPadding),
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
//                             style: const TextStyle(
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
//                           gridDelegate:
//                               const SliverGridDelegateWithMaxCrossAxisExtent(
//                                 maxCrossAxisExtent: 200,
//                                 crossAxisSpacing: defaultPadding,
//                                 childAspectRatio: 1.07,
//                               ),
//                           itemCount: _salas.length,
//                           itemBuilder: (context, index) {
//                             final sala = _salas[index] as Salas;
//                             // Exibe um card para cada lote ativo na sala
//                             return Column(
//                               children: [
//                                 ...?sala.lotes?.map(
//                                   (lote) => GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder:
//                                               (context) => SalaPage(
//                                                 idSala:
//                                                     sala.idSala?.toString() ??
//                                                     '0',
//                                                 idLote:
//                                                     lote.idLote?.toString() ??
//                                                     '0',
//                                                 nomeSala:
//                                                     sala.nomeSala ?? 'Sem nome',
//                                               ),
//                                         ),
//                                       );
//                                     },
//                                     child: SalahomeCard(
//                                       idLote: lote.idLote?.toString() ?? '0',
//                                       nomeSala: sala.nomeSala ?? 'Sem nome',
//                                       nomeCogumelo: lote.nomeCogumelo ?? '',
//                                       faseCultivo:
//                                           lote.nomeFaseCultivo?.toString() ??
//                                           '',
//                                       temperatura:
//                                           lote.temperatura?.toString() ?? '--',
//                                       umidade: lote.umidade?.toString() ?? '--',
//                                       co2: lote.co2?.toString() ?? '--',
//                                       status: lote.status ?? '',
//                                       idCogumelo: lote.idCogumelo ?? 0,
//                                     ),
//                                   ),
//                                 ),
//                               ],
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
//                           builder: (context) => const PainelSalasPage(),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       height: 150,
//                       width: MediaQuery.of(context).size.width * 0.44,
//                       decoration: BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withAlpha(100),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                             offset: const Offset(4, 4),
//                           ),
//                         ],
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.all(defaultPadding),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.meeting_room_outlined,
//                                   size: 90,
//                                   color: Colors.white,
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               'Painel Salas',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const CriarLotePage(),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       height: 150,
//                       width: MediaQuery.of(context).size.width * 0.44,
//                       decoration: BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withAlpha(100),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                             offset: const Offset(4, 4),
//                           ),
//                         ],
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.all(defaultPadding),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add, size: 90, color: Colors.white),
//                               ],
//                             ),
//                             Text(
//                               'Criar Lote',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: defaultPadding),
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
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/home/data/home_remote_datasource.dart';
import 'package:smartmushroom_app/models/salas_lotes_ativos.dart';
import 'package:smartmushroom_app/screen/criarLote_page.dart';
import 'package:smartmushroom_app/screen/ip_page.dart';
import 'package:smartmushroom_app/screen/painelSalas_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';
import 'package:smartmushroom_app/screen/widgets/salaHome_card.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  late final HomeRemoteDataSource _dataSource;
  List<Salas> _salas = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _dataSource = HomeRemoteDataSource(DioClient());
    fetchSalas();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
      final salas = await _dataSource.fetchSalas();

      if (mounted) {
        setState(() {
          _salas = salas;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      debugPrint('Error fetching salas: $e');
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
      appBar: CustomAppBar(
        title: 'Smartmushroom',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.route_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigIPPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchSalas,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Olá Colaborador!',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    StreamBuilder<String>(
                      stream: getCurrentDateTimeStream(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? '',
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: defaultPadding * 1.5),
                  ],
                ),
              ),
            ),
            if (_isLoading || _hasError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Erro ao carregar dados'),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      _buildActionsRow(context),
                      const SizedBox(height: defaultPadding * 1.5),
                    ],
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: defaultPadding,
                    mainAxisSpacing: defaultPadding / 2,
                    childAspectRatio: 1.07,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final sala = _salas[index] as Salas;
                    return Column(
                      children: [
                        ...?sala.lotes?.map(
                          (lote) => GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SalaPage(
                                        idSala: sala.idSala?.toString() ?? '0',
                                        idLote: lote.idLote?.toString() ?? '0',
                                        nomeSala: sala.nomeSala ?? 'Sem nome',
                                      ),
                                ),
                              );
                            },
                            child: SalahomeCard(
                              idLote: lote.idLote?.toString() ?? '0',
                              nomeSala: sala.nomeSala ?? 'Sem nome',
                              nomeCogumelo: lote.nomeCogumelo ?? '',
                              faseCultivo:
                                  lote.nomeFaseCultivo?.toString() ?? '',
                              temperatura: lote.temperatura?.toString() ?? '--',
                              umidade: lote.umidade?.toString() ?? '--',
                              co2: lote.co2?.toString() ?? '--',
                              status: lote.status ?? '',
                              idCogumelo: lote.idCogumelo ?? 0,
                            ),
                          ),
                        ),
                      ],
                    );
                  }, childCount: _salas.length),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: defaultPadding / 4),
                      _buildActionsRow(context),
                      const SizedBox(height: defaultPadding * 1.5),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildActionsRow(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PainelSalasPage()),
          );
        },
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.42,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  size: 80,
                  color: Colors.white,
                ),
                Text(
                  'Painel Salas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: defaultPadding),
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CriarLotePage()),
          );
        },
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.42,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.add, size: 80, color: Colors.white),
                Text(
                  'Criar Lote',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
