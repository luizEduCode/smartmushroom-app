import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/sala/data/sala_remote_datasource.dart';
import 'package:smartmushroom_app/features/sala/presentation/viewmodels/sala_view_model.dart';
import 'package:smartmushroom_app/screen/chart/co2_linechart.dart';
import 'package:smartmushroom_app/screen/chart/humidity_linechart.dart';
import 'package:smartmushroom_app/screen/chart/ring_chart.dart';
import 'package:smartmushroom_app/screen/chart/temperature_linechart.dart';
import 'package:smartmushroom_app/screen/editar_parametros/editar_parametros_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class SalaPage extends StatelessWidget {
  final String nomeSala;
  final String idLote;
  final String? idSala;

  const SalaPage({
    super.key,
    required this.nomeSala,
    required this.idLote,
    this.idSala,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => SalaViewModel(
            dataSource: SalaRemoteDataSource(DioClient()),
            idLote: idLote,
            nomeSala: nomeSala,
          )..initialize(),
      child: _SalaView(
        fallbackNomeSala: nomeSala,
        idLote: idLote,
      ),
    );
  }
}

class _SalaView extends StatefulWidget {
  const _SalaView({
    required this.fallbackNomeSala,
    required this.idLote,
  });

  final String fallbackNomeSala;
  final String idLote;

  @override
  State<_SalaView> createState() => _SalaViewState();
}

class _SalaViewState extends State<_SalaView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SalaViewModel>(
      builder: (context, viewModel, _) {
        final nomeSala = viewModel.lote?.nomeSala ?? widget.fallbackNomeSala;

        return Scaffold(
          appBar: CustomAppBar(title: nomeSala),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SalaViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Não foi possível carregar os dados da sala.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding),
              FilledButton.icon(
                onPressed: viewModel.loadAll,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final leitura = viewModel.leitura;
    final lote = viewModel.lote;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: RingChart(
                    temperatura: leitura?.temperatura ?? '--',
                    valor: leitura?.temperaturaNum ?? 0.0,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('Cogumelo', lote?.nomeCogumelo),
                      const SizedBox(height: defaultPadding / 2),
                      _buildInfoItem('Data Início', lote?.dataInicio),
                      const SizedBox(height: defaultPadding / 2),
                      _buildInfoItem('Lote', lote?.idLote),
                      const SizedBox(height: defaultPadding / 2),
                      _buildInfoItem(
                        'Sala',
                        lote?.nomeSala ?? widget.fallbackNomeSala,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Umidade',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: viewModel.humidityValue,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getHumidityColor(leitura?.umidadeNum ?? 0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('${leitura?.umidade ?? '--'}%'),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nível CO²',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: viewModel.co2Value,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCO2Color(leitura?.co2Num ?? 0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('${leitura?.co2 ?? '--'}ppm'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) {
                final idAtuador = index + 1;
                final isAtivo = viewModel.atuadoresStatus[idAtuador] ?? false;
                final buttonColor = isAtivo
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.secondary;
                final iconData = _getAtuadorIcon(idAtuador);
                final label = _getAtuadorLabel(idAtuador);

                return Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed:
                          viewModel.isAtuadorLoading
                              ? null
                              : () => _handleToggleAtuador(
                                context,
                                idAtuador,
                              ),
                      child:
                          viewModel.isAtuadorLoading
                              ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                              : Icon(iconData, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditarParametrosPage(
                                idLote: int.tryParse(widget.idLote) ?? 0,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => _showFinalizeDialog(context),
                    icon: const Icon(Icons.flag),
                    label: const Text('Finalizar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _showExcluirDialog(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildChartSection(
              context,
              'Temperatura',
              TemperatureLinechart(idLote: widget.idLote),
            ),
            const SizedBox(height: 20),
            _buildChartSection(
              context,
              'Umidade',
              HumidityLinechart(idLote: widget.idLote),
            ),
            const SizedBox(height: 20),
            _buildChartSection(
              context,
              'Co²',
              Co2Linechart(idLote: widget.idLote),
            ),
            const SizedBox(height: 16),
          ],
        ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleToggleAtuador(
    BuildContext context,
    int idAtuador,
  ) async {
    final viewModel = context.read<SalaViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    try {
      await viewModel.alterarStatusAtuador(idAtuador);
      if (!mounted) return;
      _showSnack(messenger, theme, 'Status alterado com sucesso!');
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(messenger, theme, e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(messenger, theme, 'Erro: $e', isError: true);
    }
  }

  Future<void> _showFinalizeDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<SalaViewModel>();

    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Deseja finalizar o Lote?',
      description:
          'Essa é uma ação que não poderá ser revertida e os dados serão mantidos apenas para consulta.',
      confirmLabel: 'Finalizar',
      confirmColor: theme.colorScheme.error,
    );

    if (confirmed != true || !mounted) return;

    try {
      final message = await viewModel.finalizarLote();
      if (!mounted) return;
      _showSnack(
        messenger,
        theme,
        message.isEmpty ? 'Lote finalizado com sucesso!' : message,
      );
      navigator.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(messenger, theme, e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(messenger, theme, 'Erro: $e', isError: true);
    }
  }

  Future<void> _showExcluirDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<SalaViewModel>();

    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Deseja excluir o Lote?',
      description:
          'Essa ação removerá definitivamente todos os dados relacionados ao lote.',
      confirmLabel: 'Excluir',
      confirmColor: theme.colorScheme.error,
    );

    if (confirmed != true || !mounted) return;

    try {
      final message = await viewModel.excluirLote();
      if (!mounted) return;
      _showSnack(
        messenger,
        theme,
        message.isEmpty ? 'Lote excluído com sucesso!' : message,
      );
      navigator.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(messenger, theme, e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(messenger, theme, 'Erro: $e', isError: true);
    }
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(120),
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: confirmColor),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(value?.toString() ?? '--', style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    String title,
    Widget chart,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        chart,
      ],
    );
  }

  void _showSnack(
    ScaffoldMessengerState messenger,
    ThemeData theme,
    String message, {
    bool isError = false,
  }) {
    messenger.showSnackBar(
      SnackBar(
        backgroundColor:
            isError ? theme.colorScheme.error : theme.colorScheme.primary,
        content: Text(message),
      ),
    );
  }

  static Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.red;
    if (humidity < 60) return Colors.orange;
    if (humidity < 80) return const Color(0xFF4CAF50);
    return Colors.blue;
  }

  static Color _getCO2Color(double co2) {
    if (co2 < 400) return const Color(0xFF4CAF50);
    if (co2 < 1000) return Colors.orange;
    return Colors.red;
  }

  static IconData _getAtuadorIcon(int idAtuador) {
    switch (idAtuador) {
      case 1:
        return Icons.water_drop;
      case 2:
        return Icons.thermostat_outlined;
      case 3:
        return Icons.air;
      case 4:
        return Icons.light_mode;
      default:
        return Icons.smart_button;
    }
  }

  static String _getAtuadorLabel(int idAtuador) {
    switch (idAtuador) {
      case 1:
        return 'Umidade';
      case 2:
        return 'Temperatura';
      case 3:
        return 'Ventilação';
      case 4:
        return 'Iluminação';
      default:
        return 'Atuador';
    }
  }
}
