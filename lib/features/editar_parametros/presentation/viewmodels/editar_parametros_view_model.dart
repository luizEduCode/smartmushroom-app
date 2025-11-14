import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartmushroom_app/features/editar_parametros/data/editar_parametros_remote.dart';
import 'package:smartmushroom_app/models/fase_cultivo_model.dart';
import 'package:smartmushroom_app/models/historico_fase_model.dart';
import 'package:smartmushroom_app/models/lote_model.dart';
import 'package:smartmushroom_app/models/parametro_model.dart';
import 'package:smartmushroom_app/features/editar_parametros/presentation/widgets/parametro_card_container.dart';

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
  double get mediaCo2 => co2Max / 2;
}

class EditarParametrosViewModel extends ChangeNotifier {
  EditarParametrosViewModel({
    required this.remote,
    required this.idLote,
  });

  final EditarParametrosRemote remote;
  final int idLote;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  LoteModel? _lote;
  HistoricoFaseModel? _faseAtual;
  List<FaseCultivoModel> _fases = [];
  int? _faseSelecionadaId;

  Ranges? _ranges;
  Ranges? _fasePadrao;

  bool autoTemp = true;
  bool autoUmid = true;
  bool autoCo2 = true;

  final ValueNotifier<double> tempController = ValueNotifier<double>(0);
  final ValueNotifier<double> umidController = ValueNotifier<double>(0);
  final ValueNotifier<double> co2Controller = ValueNotifier<double>(0);

  double? _spTemp;
  double? _spUmid;
  double? _spCo2;

  Ranges get _fallbackRanges => const Ranges(
        tMin: 0,
        tMax: 0,
        uMin: 0,
        uMax: 0,
        co2Max: 0,
      );

  Ranges get activeRanges => _ranges ?? _fasePadrao ?? _fallbackRanges;
  Ranges get defaultRanges => _fasePadrao ?? _ranges ?? _fallbackRanges;
  bool get rangesAvailable => _ranges != null || _fasePadrao != null;

  List<FaseCultivoModel> get fases => _fases;
  int? get faseSelecionadaId => _faseSelecionadaId;
  LoteModel? get lote => _lote;

  String get nomeCogumelo => _lote?.nomeCogumelo ?? '—';
  String get nomeSala => _lote?.nomeSala ?? '—';

  int get diasDesdeInicio {
    final data = _lote?.dataInicio;
    if (data == null || data.isEmpty) return 0;
    final parsed = DateTime.tryParse(data);
    if (parsed == null) return 0;
    return DateTime.now().difference(parsed).inDays;
  }

  String get dataInicioFormatada {
    final data = _lote?.dataInicio;
    if (data == null || data.isEmpty) return '--';
    final parsed = DateTime.tryParse(data);
    if (parsed == null) return '--';
    return DateFormat('d \'de\' MMMM \'de\' y', 'pt_BR').format(parsed);
  }

  Future<void> initialize() async {
    await carregar();
  }

  Future<void> carregar() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final lote = await remote.getLote(idLote);
      final fases = await remote.getFasesPorCogumelo(lote.idCogumelo ?? 0);
      final faseAtual = await remote.getHistoricoFaseAtual(idLote);
      final ParametroModel? parametroMaisRecente =
          await remote.getParametroMaisRecente(idLote);

      final fasePadrao = Ranges(
        tMin: _toDouble(faseAtual.temperaturaMin),
        tMax: _toDouble(faseAtual.temperaturaMax),
        uMin: _toDouble(faseAtual.umidadeMin),
        uMax: _toDouble(faseAtual.umidadeMax),
        co2Max: _toDouble(faseAtual.co2Max),
      );

      final parametrosRange = Ranges(
        tMin: _toDouble(parametroMaisRecente?.temperaturaMin, fasePadrao.tMin),
        tMax: _toDouble(parametroMaisRecente?.temperaturaMax, fasePadrao.tMax),
        uMin: _toDouble(parametroMaisRecente?.umidadeMin, fasePadrao.uMin),
        uMax: _toDouble(parametroMaisRecente?.umidadeMax, fasePadrao.uMax),
        co2Max: _toDouble(parametroMaisRecente?.co2Max, fasePadrao.co2Max),
      );

      final DateTime? dHistorico = _parseDateTime(faseAtual.dataMudanca);
      final DateTime? dParametro =
          _parseDateTime(parametroMaisRecente?.dataCriacao);
      final usarParametros =
          (dParametro != null && dHistorico != null)
              ? dParametro.isAfter(dHistorico)
              : parametroMaisRecente != null;

      _lote = lote;
      _faseAtual = faseAtual;
      _fases = fases;
      _faseSelecionadaId = faseAtual.idFaseCultivo;
      _fasePadrao = fasePadrao;
      _ranges = usarParametros ? parametrosRange : fasePadrao;

      autoTemp = autoUmid = autoCo2 = true;
      tempController.value = activeRanges.mediaTemp;
      umidController.value = activeRanges.mediaUmid;
      co2Controller.value = activeRanges.mediaCo2;
      _spTemp = _spUmid = _spCo2 = null;

      isLoading = false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
    }
    notifyListeners();
  }

  void toggleAuto(ParametroTipo tipo) {
    switch (tipo) {
      case ParametroTipo.temperatura:
        autoTemp = !autoTemp;
        if (autoTemp) {
          tempController.value = defaultRanges.mediaTemp;
          _spTemp = null;
        }
        break;
      case ParametroTipo.umidade:
        autoUmid = !autoUmid;
        if (autoUmid) {
          umidController.value = defaultRanges.mediaUmid;
          _spUmid = null;
        }
        break;
      case ParametroTipo.co2:
        autoCo2 = !autoCo2;
        if (autoCo2) {
          co2Controller.value = defaultRanges.mediaCo2;
          _spCo2 = null;
        }
        break;
    }
    notifyListeners();
  }

  void onUserChanged(ParametroTipo tipo, double value) {
    switch (tipo) {
      case ParametroTipo.temperatura:
        if (autoTemp) autoTemp = false;
        _spTemp = value;
        tempController.value = value;
        break;
      case ParametroTipo.umidade:
        if (autoUmid) autoUmid = false;
        _spUmid = value;
        umidController.value = value;
        break;
      case ParametroTipo.co2:
        if (autoCo2) autoCo2 = false;
        _spCo2 = value;
        co2Controller.value = value;
        break;
    }
    notifyListeners();
  }

  Future<void> selecionarFase(FaseCultivoModel? novaFase) async {
    if (novaFase == null) return;
    _faseSelecionadaId = novaFase.idFaseCultivo;
    final novaFaixa = Ranges(
      tMin: _toDouble(novaFase.temperaturaMin, defaultRanges.tMin),
      tMax: _toDouble(novaFase.temperaturaMax, defaultRanges.tMax),
      uMin: _toDouble(novaFase.umidadeMin, defaultRanges.uMin),
      uMax: _toDouble(novaFase.umidadeMax, defaultRanges.uMax),
      co2Max: _toDouble(novaFase.co2Max, defaultRanges.co2Max),
    );
    _fasePadrao = novaFaixa;
    _ranges = novaFaixa;

    autoTemp = autoUmid = autoCo2 = true;
    tempController.value = novaFaixa.mediaTemp;
    umidController.value = novaFaixa.mediaUmid;
    co2Controller.value = novaFaixa.mediaCo2;
    _spTemp = _spUmid = _spCo2 = null;
    notifyListeners();
  }

  Future<String> salvar() async {
    if (_lote == null) {
      return 'Dados do lote indisponíveis.';
    }

    const double dTemp = 0.5;
    const double dUmid = 2.0;
    final Ranges baseRanges = activeRanges;
    final Ranges defaults = defaultRanges;

    final double tMinPost =
        autoTemp ? defaults.tMin : ((_spTemp ?? baseRanges.mediaTemp) - dTemp);
    final double tMaxPost =
        autoTemp ? defaults.tMax : ((_spTemp ?? baseRanges.mediaTemp) + dTemp);

    final double uMinPost =
        autoUmid
            ? defaults.uMin
            : ((_spUmid ?? baseRanges.mediaUmid) - dUmid);
    final double uMaxPost =
        autoUmid
            ? defaults.uMax
            : ((_spUmid ?? baseRanges.mediaUmid) + dUmid);

    final double co2MaxPost =
        autoCo2 ? defaults.co2Max : (_spCo2 ?? baseRanges.mediaCo2);

    final bool mudouFase =
        (_faseSelecionadaId != null) &&
        (_faseSelecionadaId != _faseAtual?.idFaseCultivo);

    isSaving = true;
    notifyListeners();
    try {
      if (mudouFase) {
        await remote.postHistoricoFase(
          idLote: _lote!.idLote!,
          idFaseCultivo: _faseSelecionadaId!,
        );
      }

      await remote.postParametros(
        idLote: _lote!.idLote!,
        umidadeMin: uMinPost,
        umidadeMax: uMaxPost,
        temperaturaMin: tMinPost,
        temperaturaMax: tMaxPost,
        co2Max: co2MaxPost,
      );

      await carregar();
      return mudouFase
          ? 'Fase e parâmetros salvos com sucesso!'
          : 'Parâmetros salvos com sucesso!';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  double _toDouble(String? value, [double fallback = 0]) {
    return double.tryParse((value ?? '').replaceAll(',', '.')) ?? fallback;
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value.replaceFirst(' ', 'T'));
  }

  @override
  void dispose() {
    tempController.dispose();
    umidController.dispose();
    co2Controller.dispose();
    super.dispose();
  }
}
