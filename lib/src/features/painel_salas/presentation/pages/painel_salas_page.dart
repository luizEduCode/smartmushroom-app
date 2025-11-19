import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/src/core/di/app_dependencies.dart';
import 'package:smartmushroom_app/src/features/criar_lote/presentation/pages/criar_lote_page.dart';
import 'package:smartmushroom_app/src/features/painel_salas/presentation/viewmodels/painel_salas_view_model.dart';
import 'package:smartmushroom_app/src/features/sala/presentation/widgets/sala_card.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_lotes_ativos.dart';
import 'package:smartmushroom_app/src/shared/widgets/custom_app_bar.dart';

class PainelSalasPage extends StatelessWidget {
  const PainelSalasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.instance;
    return ChangeNotifierProvider(
      create:
          (_) => PainelSalasViewModel(
            repository: dependencies.painelSalasRepository,
            salaRepository: dependencies.salaRepository,
          )..initialize(),
      child: const _PainelSalasView(),
    );
  }
}

class _PainelSalasView extends StatelessWidget {
  const _PainelSalasView();

  Lotes? _getPrimeiroLoteAtivo(Salas sala) {
    if (sala.lotes == null || sala.lotes!.isEmpty) return null;
    return sala.lotes!.firstWhere(
      (lote) => (lote.status ?? '').toLowerCase() == 'ativo',
      orElse: () => sala.lotes!.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PainelSalasViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: const CustomAppBar(title: 'Painel de Salas'),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: RefreshIndicator(
              onRefresh: viewModel.refresh,
              child:
                  viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.hasError
                      ? _PainelErroState(message: viewModel.errorMessage)
                      : viewModel.salas.isEmpty
                      ? const _PainelEmptyState()
                      : ListView.builder(
                        itemCount: viewModel.salas.length,
                        itemBuilder: (context, index) {
                          final sala = viewModel.salas[index];
                          final lote = _getPrimeiroLoteAtivo(sala);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SalaCard(
                              nomeSala: sala.nomeSala ?? 'Sem nome',
                              nomeCogumelo:
                                  lote?.nomeCogumelo ?? 'Nenhum lote ativo',
                              faseCultivo: lote?.nomeFaseCultivo?.toString() ?? '--',
                              dataInicio: _formatDate(lote?.dataInicio),
                              idLote: lote?.idLote?.toString() ?? '0',
                              temperatura: lote?.temperatura?.toString() ?? '--',
                              umidade: lote?.umidade?.toString() ?? '--',
                              co2: lote?.co2?.toString() ?? '--',
                              status: lote?.status ?? 'inativo',
                              atuadoresStatus:
                                  viewModel.atuadoresStatus[lote?.idLote] ??
                                  const <int, bool>{},
                              idSala: sala.idSala?.toString() ?? '0',
                            ),
                          );
                        },
                      ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CriarLotePage()),
              );
            },
            tooltip: 'Criar Novo Lote',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '--';
    final text = value.toString();
    if (text.isEmpty || text == '--') return '--';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    return DateFormat('dd/MM/yyyy').format(parsed);
  }
}

class _PainelErroState extends StatelessWidget {
  const _PainelErroState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message ?? 'Erro ao carregar dados',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<PainelSalasViewModel>().refresh(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}

class _PainelEmptyState extends StatelessWidget {
  const _PainelEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhuma sala com lotes ativos',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
