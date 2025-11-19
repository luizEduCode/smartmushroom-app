import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/src/core/auth/auth_repository.dart';
import 'package:smartmushroom_app/src/core/di/app_dependencies.dart';
import 'package:smartmushroom_app/src/features/criar_lote/presentation/pages/criar_lote_page.dart';
import 'package:smartmushroom_app/src/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:smartmushroom_app/src/features/painel_salas/presentation/pages/painel_salas_page.dart';
import 'package:smartmushroom_app/src/features/sala/presentation/pages/sala_page.dart';
import 'package:smartmushroom_app/src/features/sala/presentation/widgets/sala_home_card.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_lotes_ativos.dart';
import 'package:smartmushroom_app/src/shared/widgets/app_menu_drawer.dart';
import 'package:smartmushroom_app/src/shared/widgets/custom_app_bar.dart';

const double _homePadding = 16.0;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => HomeViewModel(
            repository: AppDependencies.instance.homeRepository,
          )..initialize(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<String> _dateStream() =>
      Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ).map((date) => DateFormat('dd/MM/yyyy', 'pt_BR').format(date));

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final rawName = authRepository.user?.nome ?? '';
    final greetingName =
        rawName.trim().isEmpty ? 'Colaborador' : rawName.trim();
    final greetingText = 'Olá $greetingName!';

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppMenuDrawer(),
          appBar: CustomAppBar(
            title: 'Smartmushroom',
            showBackButton: false,
            showMenuButton: true,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          body: RefreshIndicator(
            onRefresh: viewModel.refresh,
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
                          greetingText,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: _homePadding / 2),
                        StreamBuilder<String>(
                          stream: _dateStream(),
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
                if (viewModel.isLoading || viewModel.hasError)
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
                                  viewModel.isLoading
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: _homePadding,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        crossAxisSpacing: _homePadding * 1.5,
                        mainAxisSpacing: _homePadding / 2,
                        childAspectRatio: _homeGridAspectRatio(context),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sala = viewModel.salas[index];
                          return _HomeSalaGridItem(sala: sala);
                        },
                        childCount: viewModel.salas.length,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _homePadding,
                    ),
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
      },
    );
  }
}

class _HomeSalaGridItem extends StatelessWidget {
  const _HomeSalaGridItem({required this.sala});

  final Salas sala;

  @override
  Widget build(BuildContext context) {
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
              faseCultivo: lote.nomeFaseCultivo?.toString() ?? '',
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
  }
}

Widget _buildActionsRow(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final Color foreground = colorScheme.onPrimary;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PainelSalasPage()),
          );
        },
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.42,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_homePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.meeting_room_outlined, size: 80, color: foreground),
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
            MaterialPageRoute(builder: (_) => const CriarLotePage()),
          );
        },
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.42,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
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

double _homeGridAspectRatio(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 340) return 0.72;
  if (width < 420) return 0.82;
  if (width < 600) return 0.92;
  return 1.05;
}
