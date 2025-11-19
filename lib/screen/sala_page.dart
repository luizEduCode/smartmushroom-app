import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/sala/data/sala_remote_datasource.dart';
import 'package:smartmushroom_app/features/sala/presentation/viewmodels/sala_view_model.dart';
import 'package:smartmushroom_app/screen/chart/co2_linechart.dart';
import 'package:smartmushroom_app/screen/chart/humidity_linechart.dart';
import 'package:smartmushroom_app/screen/chart/ring_chart.dart';
import 'package:smartmushroom_app/screen/chart/temperature_linechart.dart';
import 'package:smartmushroom_app/features/editar_parametros/presentation/pages/editar_parametros_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

const double _salaPadding = 16.0;

enum ChartAggregation { last24h, daily, weekly, monthly }

extension ChartAggregationExt on ChartAggregation {
  String get label {
    switch (this) {
      case ChartAggregation.last24h:
        return '24h';
      case ChartAggregation.daily:
        return 'Diário';
      case ChartAggregation.weekly:
        return 'Semanal';
      case ChartAggregation.monthly:
        return 'Mensal';
    }
  }

  String get apiValue {
    switch (this) {
      case ChartAggregation.last24h:
        return '24h';
      case ChartAggregation.daily:
        return 'daily';
      case ChartAggregation.weekly:
        return 'weekly';
      case ChartAggregation.monthly:
        return 'monthly';
    }
  }
}

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
      child: _SalaView(fallbackNomeSala: nomeSala, idLote: idLote),
    );
  }
}

class _SalaView extends StatefulWidget {
  const _SalaView({required this.fallbackNomeSala, required this.idLote});

  final String fallbackNomeSala;
  final String idLote;

  @override
  State<_SalaView> createState() => _SalaViewState();
}

class _SalaViewState extends State<_SalaView> {
  ChartAggregation _aggregation = ChartAggregation.last24h;

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
          padding: const EdgeInsets.all(_salaPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Não foi possível carregar os dados da sala.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _salaPadding),
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
        final bool compactButtons = constraints.maxWidth < 520;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(_salaPadding),
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
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoItem('Cogumelo', lote?.nomeCogumelo),
                            SizedBox(height: _salaPadding / 2),
                            _buildInfoItem('Data Início', lote?.dataInicio),
                            SizedBox(height: _salaPadding / 2),
                            _buildInfoItem('Lote', lote?.idLote),
                            SizedBox(height: _salaPadding / 2),
                            _buildInfoItem(
                              'Sala',
                              lote?.nomeSala ?? widget.fallbackNomeSala,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Umidade',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: viewModel.humidityValue,
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getHumidityColor(
                                  Theme.of(context).colorScheme,
                                  leitura?.umidadeNum ?? 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text('${leitura?.umidade ?? '--'}%'),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nível CO²',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: viewModel.co2Value,
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCO2Color(
                                  Theme.of(context).colorScheme,
                                  leitura?.co2Num ?? 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text('${leitura?.co2 ?? '--'}ppm'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (index) {
                      final idAtuador = index + 1;
                      final isAtivo =
                          viewModel.atuadoresStatus[idAtuador] ?? false;
                      final buttonColor =
                          isAtivo
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.secondary;
                      final onPrimaryColor =
                          Theme.of(context).colorScheme.onPrimary;
                      final iconData = _getAtuadorIcon(idAtuador);
                      final label = _getAtuadorLabel(idAtuador);

                      return Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
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
                                    ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation(
                                          onPrimaryColor,
                                        ),
                                      ),
                                    )
                                    : Icon(
                                      iconData,
                                      color: onPrimaryColor,
                                      size: 26,
                                    ),
                          ),
                          SizedBox(height: 8),
                          Text(label, style: const TextStyle(fontSize: 12)),
                        ],
                      );
                    }),
                  ),
                  SizedBox(height: 24),
                  _buildActionButtons(context, compactButtons),
                  SizedBox(height: 24),
                  _buildAggregationToggle(context),
                  SizedBox(height: 16),
                  _buildChartSection(
                    context,
                    'Temperatura',
                    TemperatureLinechart(
                      idLote: widget.idLote,
                      aggregation: _aggregation.apiValue,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildChartSection(
                    context,
                    'Umidade',
                    HumidityLinechart(
                      idLote: widget.idLote,
                      aggregation: _aggregation.apiValue,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildChartSection(
                    context,
                    'CO?',
                    Co2Linechart(
                      idLote: widget.idLote,
                      aggregation: _aggregation.apiValue,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleToggleAtuador(BuildContext context, int idAtuador) async {
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

  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      barrierDismissible: false,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
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
        SizedBox(height: 2),
        Text(value?.toString() ?? '--', style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        chart,
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool compact) {
    final theme = Theme.of(context);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final buttons = <Widget>[
      FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          minimumSize: const Size(0, 48),
          shape: buttonShape,
        ),
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
      FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          minimumSize: const Size(0, 48),
          shape: buttonShape,
        ),
        onPressed: () => _showFinalizeDialog(context),
        icon: const Icon(Icons.flag),
        label: const Text('Finalizar'),
      ),
    ];

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < buttons.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == buttons.length - 1 ? 0 : 12,
              ),
              child: buttons[i],
            ),
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < buttons.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == buttons.length - 1 ? 0 : 12),
              child: buttons[i],
            ),
          ),
      ],
    );
  }

  Widget _buildAggregationToggle(BuildContext context) {
    return _AggregationSelector(
      selected: _aggregation,
      onChanged: (value) => setState(() => _aggregation = value),
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

  static Color _getHumidityColor(ColorScheme scheme, double humidity) {
    if (humidity < 30) return scheme.error;
    if (humidity < 60) return scheme.secondary;
    if (humidity < 80) return scheme.tertiary;
    return scheme.primary;
  }

  static Color _getCO2Color(ColorScheme scheme, double co2) {
    if (co2 < 400) return scheme.tertiary;
    if (co2 < 1000) return scheme.secondary;
    return scheme.error;
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

class _AggregationSelector extends StatelessWidget {
  const _AggregationSelector({required this.selected, required this.onChanged});

  final ChartAggregation selected;
  final ValueChanged<ChartAggregation> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children:
            ChartAggregation.values.map((aggregation) {
              final bool isSelected = aggregation == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(aggregation),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? scheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      aggregation.label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color:
                            isSelected
                                ? scheme.onPrimary
                                : scheme.onSurface.withValues(alpha: 0.8),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
