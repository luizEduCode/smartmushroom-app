import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/src/core/di/app_dependencies.dart';
import 'package:smartmushroom_app/src/core/network/api_exception.dart';
import 'package:smartmushroom_app/src/features/criar_lote/presentation/viewmodels/criar_lote_view_model.dart';
import 'package:smartmushroom_app/src/features/sala/presentation/pages/sala_page.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/cogumelos_model.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/fases_cultivo_model.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_disponiveis_model.dart';
import 'package:smartmushroom_app/src/shared/widgets/custom_app_bar.dart';

const double _pagePadding = 20.0;

class CriarLotePage extends StatelessWidget {
  const CriarLotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => CriarLoteViewModel(
            repository: AppDependencies.instance.criarLoteRepository,
          )..initialize(),
      child: const _CriarLoteView(),
    );
  }
}

class _CriarLoteView extends StatefulWidget {
  const _CriarLoteView();

  @override
  State<_CriarLoteView> createState() => _CriarLoteViewState();
}

class _CriarLoteViewState extends State<_CriarLoteView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CriarLoteViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: const CustomAppBar(title: 'Criar Novo Lote'),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: viewModel.refreshAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(_pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crie um novo lote selecionando sala, cogumelo e fase.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSalaDropdown(context, viewModel),
                            const SizedBox(height: 20),
                            _buildCogumeloDropdown(context, viewModel),
                            const SizedBox(height: 20),
                            _buildFaseDropdown(context, viewModel),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            viewModel.isSubmitting
                                ? null
                                : () => _criarLote(context, viewModel),
                        icon:
                            viewModel.isSubmitting
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: Text(
                          viewModel.isSubmitting
                              ? 'Criando lote...'
                              : 'Criar lote',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalaDropdown(
    BuildContext context,
    CriarLoteViewModel viewModel,
  ) {
    if (viewModel.isLoadingSalas) {
      return _buildLoadingState('Carregando salas disponíveis...');
    }

    if (viewModel.salasErro != null) {
      return _buildErrorState(viewModel.salasErro!);
    }

    if (viewModel.salas.isEmpty) {
      return _buildInfoState(
        'Nenhuma sala disponível para novos lotes no momento.',
      );
    }

    return DropdownButtonFormField<SalaDisponivel>(
      key: ValueKey('sala_${viewModel.salaSelecionada?.idSala ?? 'none'}'),
      decoration: _inputDecoration(
        context,
        label: 'Sala disponível',
        icon: Icons.meeting_room,
      ),
      initialValue: viewModel.salaSelecionada,
      items:
          viewModel.salas.map((sala) {
            return DropdownMenuItem<SalaDisponivel>(
              value: sala,
              child: Text(sala.nomeSala),
            );
          }).toList(),
      onChanged: viewModel.selecionarSala,
      validator: (value) => value == null ? 'Selecione uma sala.' : null,
      hint: const Text('Selecione uma sala'),
    );
  }

  Widget _buildCogumeloDropdown(
    BuildContext context,
    CriarLoteViewModel viewModel,
  ) {
    if (viewModel.isLoadingCogumelos) {
      return _buildLoadingState('Carregando cogumelos disponíveis...');
    }

    if (viewModel.cogumelosErro != null) {
      return _buildErrorState(viewModel.cogumelosErro!);
    }

    if (viewModel.cogumelos.isEmpty) {
      return _buildInfoState('Nenhum cogumelo cadastrado.');
    }

    return DropdownButtonFormField<Cogumelos>(
      key: ValueKey('cogumelo_${viewModel.cogumeloSelecionado?.idCogumelo ?? 'none'}'),
      decoration: _inputDecoration(
        context,
        label: 'Tipo de cogumelo',
        icon: Icons.grass,
      ),
      initialValue: viewModel.cogumeloSelecionado,
      items:
          viewModel.cogumelos.map((cogumelo) {
            return DropdownMenuItem<Cogumelos>(
              value: cogumelo,
              child: Text(cogumelo.nomeCogumelo),
            );
          }).toList(),
      onChanged:
          (value) =>
              value == null ? null : viewModel.carregarFases(value),
      validator: (value) => value == null ? 'Selecione um cogumelo.' : null,
      hint: const Text('Selecione um cogumelo'),
    );
  }

  Widget _buildFaseDropdown(
    BuildContext context,
    CriarLoteViewModel viewModel,
  ) {
    if (viewModel.cogumeloSelecionado == null) {
      return _buildInfoState(
        'Primeiro selecione um cogumelo para liberar as fases de cultivo.',
      );
    }

    if (viewModel.isLoadingFases) {
      return _buildLoadingState('Carregando fases disponíveis...');
    }

    if (viewModel.fasesErro != null) {
      return _buildErrorState(viewModel.fasesErro!);
    }

    if (viewModel.fases.isEmpty) {
      return _buildInfoState(
        'Nenhuma fase disponível para o cogumelo selecionado. Escolha outra espécie.',
      );
    }

    return DropdownButtonFormField<fases_cultivo>(
      key: ValueKey('fase_${viewModel.faseSelecionada?.idFaseCultivo ?? 'none'}'),
      decoration: _inputDecoration(
        context,
        label: 'Fase de cultivo',
        icon: Icons.timeline,
      ),
      initialValue: viewModel.faseSelecionada,
      items:
          viewModel.fases.map((fase) {
            return DropdownMenuItem<fases_cultivo>(
              value: fase,
              child: Text(fase.nomeFaseCultivo ?? 'Fase sem nome'),
            );
          }).toList(),
      onChanged: viewModel.selecionarFase,
      validator: (value) => value == null ? 'Selecione uma fase.' : null,
      hint: const Text('Selecione uma fase'),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildInfoState(String message) {
    return Text(
      message,
      style: const TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.start,
    );
  }

  Future<void> _criarLote(
    BuildContext context,
    CriarLoteViewModel viewModel,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showSnack(context, 'Preencha todas as informações para continuar.');
      return;
    }

    try {
      final idLote = await viewModel.criarLote();
      if (!context.mounted) return;
      _showSnack(context, 'Lote criado com sucesso!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => SalaPage(
                idLote: idLote.isEmpty ? '0' : idLote,
                nomeSala: viewModel.salaSelecionada?.nomeSala ?? 'Sala',
              ),
        ),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      _showSnack(
        context,
        'Erro ao criar lote: ${e.message}',
        isError: true,
      );
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, 'Erro ao criar lote: $e', isError: true);
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
