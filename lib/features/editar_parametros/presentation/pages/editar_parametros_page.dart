import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/editar_parametros/data/editar_parametros_remote.dart';
import 'package:smartmushroom_app/features/editar_parametros/presentation/viewmodels/editar_parametros_view_model.dart';
import 'package:smartmushroom_app/features/editar_parametros/presentation/widgets/dropdown_fases_cultivo.dart';
import 'package:smartmushroom_app/features/editar_parametros/presentation/widgets/parametro_card_container.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class EditarParametrosPage extends StatelessWidget {
  const EditarParametrosPage({super.key, required this.idLote});

  final int idLote;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => EditarParametrosViewModel(
            remote: EditarParametrosRemote(DioClient()),
            idLote: idLote,
          )..initialize(),
      child: const _EditarParametrosView(),
    );
  }
}

class _EditarParametrosView extends StatelessWidget {
  const _EditarParametrosView();

  @override
  Widget build(BuildContext context) {
    return Consumer<EditarParametrosViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Scaffold(
            appBar: CustomAppBar(title: 'Editar Parâmetros'),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.errorMessage != null) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'Editar Parâmetros'),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(viewModel.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: viewModel.carregar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: const CustomAppBar(title: 'Editar Parâmetros'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderCard(context, viewModel),
                const SizedBox(height: 16),
                _buildProgressCard(context, viewModel),
                const SizedBox(height: 16),
                if (viewModel.rangesAvailable) ...[
                  _buildParametroCard(
                    context: context,
                    viewModel: viewModel,
                    tipo: ParametroTipo.temperatura,
                  ),
                  const SizedBox(height: 16),
                  _buildParametroCard(
                    context: context,
                    viewModel: viewModel,
                    tipo: ParametroTipo.umidade,
                  ),
                  const SizedBox(height: 16),
                  _buildParametroCard(
                    context: context,
                    viewModel: viewModel,
                    tipo: ParametroTipo.co2,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        viewModel.isSaving
                            ? null
                            : () => _onSalvar(context, viewModel),
                    icon:
                        viewModel.isSaving
                            ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                            : const Icon(Icons.save),
                    label: Text(
                      viewModel.isSaving ? 'Salvando...' : 'Salvar alterações',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSalvar(
    BuildContext context,
    EditarParametrosViewModel viewModel,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final message = await viewModel.salvar();
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Falha ao salvar: $e')));
    }
  }

  Widget _buildHeaderCard(
    BuildContext context,
    EditarParametrosViewModel viewModel,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lote: ${viewModel.lote?.idLote ?? '--'}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.settings,
                              color: scheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${viewModel.nomeCogumelo} • ${viewModel.nomeSala}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: scheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${viewModel.diasDesdeInicio}',
                        style: textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'dias',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: scheme.secondary, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data de Início',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        viewModel.dataInicioFormatada,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    EditarParametrosViewModel viewModel,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.settings, color: scheme.secondary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Progresso do Cultivo',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownFasesCultivo(
              fases: viewModel.fases,
              selectedId: viewModel.faseSelecionadaId,
              onChanged: viewModel.selecionarFase,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametroCard({
    required BuildContext context,
    required EditarParametrosViewModel viewModel,
    required ParametroTipo tipo,
  }) {
    final ranges = switch (tipo) {
      ParametroTipo.temperatura =>
        viewModel.autoTemp ? viewModel.defaultRanges : viewModel.activeRanges,
      ParametroTipo.umidade =>
        viewModel.autoUmid ? viewModel.defaultRanges : viewModel.activeRanges,
      ParametroTipo.co2 =>
        viewModel.autoCo2 ? viewModel.defaultRanges : viewModel.activeRanges,
    };

    final controller = switch (tipo) {
      ParametroTipo.temperatura => viewModel.tempController,
      ParametroTipo.umidade => viewModel.umidController,
      ParametroTipo.co2 => viewModel.co2Controller,
    };

    final autoMode = switch (tipo) {
      ParametroTipo.temperatura => viewModel.autoTemp,
      ParametroTipo.umidade => viewModel.autoUmid,
      ParametroTipo.co2 => viewModel.autoCo2,
    };

    final idealMin = switch (tipo) {
      ParametroTipo.temperatura => ranges.tMin,
      ParametroTipo.umidade => ranges.uMin,
      ParametroTipo.co2 => 0.0,
    };

    final idealMax = switch (tipo) {
      ParametroTipo.temperatura => ranges.tMax,
      ParametroTipo.umidade => ranges.uMax,
      ParametroTipo.co2 => ranges.co2Max,
    };

    final initialOverride = switch (tipo) {
      ParametroTipo.temperatura => viewModel.activeRanges.mediaTemp,
      ParametroTipo.umidade => viewModel.activeRanges.mediaUmid,
      ParametroTipo.co2 => viewModel.activeRanges.mediaCo2,
    };

    return ParametroCardContainer(
      idLote: viewModel.lote?.idLote?.toString() ?? '',
      tipo: tipo,
      autoMode: autoMode,
      onToggleAuto: () => viewModel.toggleAuto(tipo),
      idealMinOverride: idealMin,
      idealMaxOverride: idealMax,
      initialValueOverride: initialOverride,
      valueController: controller,
      onUserChanged: (value) => viewModel.onUserChanged(tipo, value),
    );
  }
}
