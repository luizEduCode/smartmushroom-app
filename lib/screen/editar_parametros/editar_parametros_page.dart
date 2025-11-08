import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';

import 'package:smartmushroom_app/models/Historico_Fase_Model.dart';
import 'package:smartmushroom_app/models/Lote_Model.dart';
import 'package:smartmushroom_app/models/Parametro_Model.dart';
import 'package:smartmushroom_app/models/Fase_Cultivo_Model.dart';

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
      return const Scaffold(
        appBar: CustomAppBar(title: 'Editar Parâmetros'),
        body: Center(child: CircularProgressIndicator()),
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
                ElevatedButton(
                  onPressed: _carregar,
                  child: const Text('Tentar novamente'),
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

    return Scaffold(
      // backgroundColor: Colors.green,
      appBar: const CustomAppBar(title: 'Editar Parâmetros'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ===== Cabeçalho do lote =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.spa,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$nomeCogumelo • $nomeSala',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
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
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$dias',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'dias',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data de Início',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                dataInicioBr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
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

              const SizedBox(height: 16),

              // ===== Progresso / Fase =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.settings,
                            size: 24,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Progresso do Cultivo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
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
                            tMin: _toDouble(
                              novaFase.temperaturaMin,
                              _ranges!.tMin,
                            ),
                            tMax: _toDouble(
                              novaFase.temperaturaMax,
                              _ranges!.tMax,
                            ),
                            uMin: _toDouble(novaFase.umidadeMin, _ranges!.uMin),
                            uMax: _toDouble(novaFase.umidadeMax, _ranges!.uMax),
                            co2Max: _toDouble(novaFase.co2Max, _ranges!.co2Max),
                          );

                          // Ativa AUTO e volta sliders para as novas médias
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

              const SizedBox(height: 16),

              // ===== Parâmetros =====
              if (_ranges != null) ...[
                // Temperatura
                ParametroCardContainer(
                  idLote: '$_idLote',
                  tipo: ParametroTipo.temperatura,
                  autoMode: _autoTemp,
                  onToggleAuto: () {
                    setState(() {
                      _autoTemp = !_autoTemp;
                      if (_autoTemp) {
                        _tempCtrl.value = _ranges!.mediaTemp; // volta à média
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

                // Umidade
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

                // CO₂
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

              // ===== Botão Salvar =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _salvar,
                  icon:
                      _saving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 16,
                          ),
                  label: Text(
                    _saving ? 'Salvando...' : 'Salvar alterações',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
