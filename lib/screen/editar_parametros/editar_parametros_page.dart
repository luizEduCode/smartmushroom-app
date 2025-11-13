import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';

import 'package:smartmushroom_app/models/historico_fase_model.dart';
import 'package:smartmushroom_app/models/lote_model.dart';
import 'package:smartmushroom_app/models/parametro_model.dart';
import 'package:smartmushroom_app/models/fase_cultivo_model.dart';

import 'package:smartmushroom_app/screen/editar_parametros/data/editar_parametros_remote.dart';
import 'package:smartmushroom_app/screen/editar_parametros/presentation/widgets/parametro_card_container.dart';
import 'package:smartmushroom_app/screen/editar_parametros/widgets/dropdown_fases_cultivo.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

/// Faixas ideais ativas na tela
class Ranges {
  final double tMin;
  final double tMax;
  final double uMin;
  final double uMax;
  final double co2Max;

  const Ranges({
    required this.tMin,
    required this.tMax,
    required this.uMin,
    required this.uMax,
    required this.co2Max,
  });

  double get mediaTemp => (tMin + tMax) / 2;
  double get mediaUmid => (uMin + uMax) / 2;
  double get mediaCo2 => (0 + co2Max) / 2;
}

class EditarParametrosPage extends StatefulWidget {
  const EditarParametrosPage({super.key, required this.idLote});

  final int idLote;

  @override
  State<EditarParametrosPage> createState() => _EditarParametrosPageState();
}

class _EditarParametrosPageState extends State<EditarParametrosPage> {
  late final int _idLote;
  late EditarParametrosRemote _remote = EditarParametrosRemote(DioClient());
  LoteModel? _lote;
  HistoricoFaseModel? _faseAtual;
  Ranges? _ranges;
  int? _faseSelecionadaId;
  bool _loading = true;
  String? _error;
  bool _saving = false;
  bool _autoTemp = true, _autoUmid = true, _autoCo2 = true;
  late final ValueNotifier<double> _tempCtrl = ValueNotifier<double>(0);
  late final ValueNotifier<double> _umidCtrl = ValueNotifier<double>(0);
  late final ValueNotifier<double> _co2Ctrl = ValueNotifier<double>(0);

  double? _spTemp, _spUmid, _spCo2;

  @override
  void initState() {
    super.initState();
    _idLote = widget.idLote;
    _remote = EditarParametrosRemote(DioClient());
    _carregar();
  }

  // -------- Helpers numéricos --------
  double _toDouble(String? s, [double def = 0]) =>
      double.tryParse((s ?? '').replaceAll(',', '.')) ?? def;

  DateTime? _parseDateTime(String? s) =>
      (s == null || s.isEmpty)
          ? null
          : DateTime.tryParse(s.replaceFirst(' ', 'T'));

  int _diasDesde(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 0;
    final d = DateTime.tryParse(isoDate);
    if (d == null) return 0;
    return DateTime.now().difference(d).inDays;
  }

  String _formatarDataBr(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '--';
    final d = DateTime.tryParse(isoDate);
    if (d == null) return '--';
    return DateFormat('d \'de\' MMMM \'de\' y', 'pt_BR').format(d);
  }

  // -------- Carregamento inicial com regra mista --------
  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final lote = await _remote.getLote(_idLote);
      final faseAtual = await _remote.getHistoricoFaseAtual(
        _idLote,
      ); // posição 0
      final ParametroModel? paramMaisRecente = await _remote
          .getParametroMaisRecente(_idLote);

      // datas para decidir fonte principal
      final dHistorico = _parseDateTime(faseAtual.dataMudanca);
      final dParam = _parseDateTime(paramMaisRecente?.dataCriacao);

      // Faixas a partir do histórico (fallback)
      double fTmin = _toDouble(faseAtual.temperaturaMin);
      double fTmax = _toDouble(faseAtual.temperaturaMax);
      double fUmin = _toDouble(faseAtual.umidadeMin);
      double fUmax = _toDouble(faseAtual.umidadeMax);
      double fCmax = _toDouble(faseAtual.co2Max);

      // Faixas a partir do último parâmetro (se existir)
      double pTmin = _toDouble(paramMaisRecente?.temperaturaMin, fTmin);
      double pTmax = _toDouble(paramMaisRecente?.temperaturaMax, fTmax);
      double pUmin = _toDouble(paramMaisRecente?.umidadeMin, fUmin);
      double pUmax = _toDouble(paramMaisRecente?.umidadeMax, fUmax);
      double pCmax = _toDouble(paramMaisRecente?.co2Max, fCmax);

      final usarParametros =
          (dParam != null && dHistorico != null)
              ? dParam.isAfter(dHistorico)
              : (paramMaisRecente != null);

      final ranges =
          usarParametros
              ? Ranges(
                tMin: pTmin,
                tMax: pTmax,
                uMin: pUmin,
                uMax: pUmax,
                co2Max: pCmax,
              )
              : Ranges(
                tMin: fTmin,
                tMax: fTmax,
                uMin: fUmin,
                uMax: fUmax,
                co2Max: fCmax,
              );

      setState(() {
        _lote = lote;
        _faseAtual = faseAtual;
        _faseSelecionadaId = faseAtual.idFaseCultivo;
        _ranges = ranges;

        // inicia em AUTO = ON e sliders na média
        _autoTemp = _autoUmid = _autoCo2 = true;
        _tempCtrl.value = ranges.mediaTemp;
        _umidCtrl.value = ranges.mediaUmid;
        _co2Ctrl.value = ranges.mediaCo2;

        _spTemp = _spUmid = _spCo2 = null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // -------- Salvar (POSTs) --------
  Future<void> _salvar() async {
    if (_ranges == null || _lote == null) return;

    // janelas em torno do setpoint quando AUTO=OFF
    const double dTemp = 0.5; // ±0.5 °C
    const double dUmid = 2.0; // ±2 %

    // Temperatura
    final double tMinPost =
        _autoTemp ? _ranges!.tMin : ((_spTemp ?? _ranges!.mediaTemp) - dTemp);
    final double tMaxPost =
        _autoTemp ? _ranges!.tMax : ((_spTemp ?? _ranges!.mediaTemp) + dTemp);

    // Umidade
    final double uMinPost =
        _autoUmid ? _ranges!.uMin : ((_spUmid ?? _ranges!.mediaUmid) - dUmid);
    final double uMaxPost =
        _autoUmid ? _ranges!.uMax : ((_spUmid ?? _ranges!.mediaUmid) + dUmid);

    // CO2 (somente teto; sem mínimo)
    final double co2MaxPost =
        _autoCo2 ? _ranges!.co2Max : (_spCo2 ?? _ranges!.mediaCo2);

    final mudouFase =
        (_faseSelecionadaId != null) &&
        (_faseSelecionadaId != _faseAtual?.idFaseCultivo);

    setState(() => _saving = true);
    try {
      if (mudouFase) {
        await _remote.postHistoricoFase(
          idLote: _lote!.idLote!,
          idFaseCultivo: _faseSelecionadaId!,
        );
      }

      await _remote.postParametros(
        idLote: _lote!.idLote!,
        umidadeMin: uMinPost,
        umidadeMax: uMaxPost,
        temperaturaMin: tMinPost,
        temperaturaMax: tMaxPost,
        co2Max: co2MaxPost,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mudouFase
                ? 'Fase e parâmetros salvos com sucesso!'
                : 'Parâmetros salvos com sucesso!',
          ),
        ),
      );

      await _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      final scheme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: const CustomAppBar(title: 'Editar Parâmetros'),
        body: Center(
          child: SizedBox(
            height: 42,
            width: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Editar Parâmetros'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _carregar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final lote = _lote!;
    final dias = _diasDesde(lote.dataInicio);
    final dataInicioBr = _formatarDataBr(lote.dataInicio);
    final nomeCogumelo = lote.nomeCogumelo ?? '—';
    final nomeSala = lote.nomeSala ?? '—';

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Editar Parâmetros'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(
              scheme: scheme,
              textTheme: textTheme,
              lote: lote,
              nomeCogumelo: nomeCogumelo,
              nomeSala: nomeSala,
              dataInicio: dataInicioBr,
              dias: dias,
            ),
            const SizedBox(height: 16),
            _buildProgressCard(
              scheme: scheme,
              textTheme: textTheme,
              lote: lote,
            ),
            const SizedBox(height: 16),
            if (_ranges != null) ...[
              ParametroCardContainer(
                idLote: '$_idLote',
                tipo: ParametroTipo.temperatura,
                autoMode: _autoTemp,
                onToggleAuto: () {
                  setState(() {
                    _autoTemp = !_autoTemp;
                    if (_autoTemp) {
                      _tempCtrl.value = _ranges!.mediaTemp;
                      _spTemp = null;
                    }
                  });
                },
                idealMinOverride: _ranges!.tMin,
                idealMaxOverride: _ranges!.tMax,
                initialValueOverride: _ranges!.mediaTemp,
                valueController: _tempCtrl,
                onUserChanged: (v) {
                  if (_autoTemp) setState(() => _autoTemp = false);
                  _spTemp = v;
                },
              ),
              const SizedBox(height: 16),
              ParametroCardContainer(
                idLote: '$_idLote',
                tipo: ParametroTipo.umidade,
                autoMode: _autoUmid,
                onToggleAuto: () {
                  setState(() {
                    _autoUmid = !_autoUmid;
                    if (_autoUmid) {
                      _umidCtrl.value = _ranges!.mediaUmid;
                      _spUmid = null;
                    }
                  });
                },
                idealMinOverride: _ranges!.uMin,
                idealMaxOverride: _ranges!.uMax,
                initialValueOverride: _ranges!.mediaUmid,
                valueController: _umidCtrl,
                onUserChanged: (v) {
                  if (_autoUmid) setState(() => _autoUmid = false);
                  _spUmid = v;
                },
              ),
              const SizedBox(height: 16),
              ParametroCardContainer(
                idLote: '$_idLote',
                tipo: ParametroTipo.co2,
                autoMode: _autoCo2,
                onToggleAuto: () {
                  setState(() {
                    _autoCo2 = !_autoCo2;
                    if (_autoCo2) {
                      _co2Ctrl.value = _ranges!.mediaCo2;
                      _spCo2 = null;
                    }
                  });
                },
                idealMinOverride: 0,
                idealMaxOverride: _ranges!.co2Max,
                initialValueOverride: _ranges!.mediaCo2,
                valueController: _co2Ctrl,
                onUserChanged: (v) {
                  if (_autoCo2) setState(() => _autoCo2 = false);
                  _spCo2 = v;
                },
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _salvar,
                icon:
                    _saving
                        ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              scheme.onPrimary,
                            ),
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(
                  _saving ? 'Salvando...' : 'Salvar alterações',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard({
    required ColorScheme scheme,
    required TextTheme textTheme,
    required LoteModel lote,
    required String nomeCogumelo,
    required String nomeSala,
    required String dataInicio,
    required int dias,
  }) {
    final titleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: scheme.primary,
    );

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
                        'Lote: ${lote.idLote ?? '--'}',
                        style: titleStyle,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.spa,
                              size: 16,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$nomeCogumelo • $nomeSala',
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
                        '$dias',
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
                        dataInicio,
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

  Widget _buildProgressCard({
    required ColorScheme scheme,
    required TextTheme textTheme,
    required LoteModel lote,
  }) {
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
              idCogumelo: lote.idCogumelo ?? 0,
              idFaseSelecionada: _faseSelecionadaId,
              onChanged: (FaseCultivoModel? novaFase) {
                if (novaFase == null || _ranges == null) return;
                setState(() {
                  _faseSelecionadaId = novaFase.idFaseCultivo;

                  _ranges = Ranges(
                    tMin: _toDouble(novaFase.temperaturaMin, _ranges!.tMin),
                    tMax: _toDouble(novaFase.temperaturaMax, _ranges!.tMax),
                    uMin: _toDouble(novaFase.umidadeMin, _ranges!.uMin),
                    uMax: _toDouble(novaFase.umidadeMax, _ranges!.uMax),
                    co2Max: _toDouble(novaFase.co2Max, _ranges!.co2Max),
                  );

                  _autoTemp = _autoUmid = _autoCo2 = true;
                  _tempCtrl.value = _ranges!.mediaTemp;
                  _umidCtrl.value = _ranges!.mediaUmid;
                  _co2Ctrl.value = _ranges!.mediaCo2;

                  _spTemp = _spUmid = _spCo2 = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
