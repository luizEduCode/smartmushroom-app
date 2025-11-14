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
//               const SizedBox(height: _homePadding),
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
//                                 crossAxisSpacing: _homePadding,
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
//                         padding: EdgeInsets.all(_homePadding),
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
//                         padding: EdgeInsets.all(_homePadding),
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
//               const SizedBox(height: _homePadding),
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
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/home/data/home_remote_datasource.dart';
import 'package:smartmushroom_app/models/Antigas/salas_lotes_ativos.dart';
import 'package:smartmushroom_app/screen/criar_lote_page.dart';
import 'package:smartmushroom_app/screen/ip_page.dart';
import 'package:smartmushroom_app/screen/painel_salas_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';
import 'package:smartmushroom_app/screen/widgets/sala_home_card.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';

const double _homePadding = 16.0;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onPrimary = colorScheme.onPrimary;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Smartmushroom',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.route_outlined,
              color: theme.appBarTheme.foregroundColor ?? onPrimary,
            ),
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
              padding: const EdgeInsets.all(_homePadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá Colaborador!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: _homePadding / 2),
                    StreamBuilder<String>(
                      stream: getCurrentDateTimeStream(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? '',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                    const SizedBox(height: _homePadding * 1.5),
                  ],
                ),
              ),
            ),
            if (_isLoading || _hasError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _homePadding,
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
                      const SizedBox(height: _homePadding),
                      _buildActionsRow(context),
                      const SizedBox(height: _homePadding * 1.5),
                    ],
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: _homePadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: _homePadding,
                    mainAxisSpacing: _homePadding / 2,
                    childAspectRatio: 1.07,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final sala = _salas[index];
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
                padding: const EdgeInsets.symmetric(horizontal: _homePadding),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: _homePadding / 4),
                      _buildActionsRow(context),
                      const SizedBox(height: _homePadding * 1.5),
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
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final Color foreground = colorScheme.onPrimary;
  final Color shadowColor = theme.shadowColor.withValues(alpha: 0.25);

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
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(_homePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  size: 80,
                  color: foreground,
                ),
                Text(
                  'Painel Salas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: _homePadding),
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
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(_homePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.add, size: 80, color: foreground),
                Text(
                  'Criar Lote',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.bold,
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
