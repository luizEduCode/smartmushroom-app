import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/chart_data_model.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/controle_atuador_model.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/leitura_model.dart';
import 'package:smartmushroom_app/src/features/sala/domain/repositories/sala_repository.dart';
import 'package:smartmushroom_app/src/features/sala/presentation/viewmodels/chart_aggregation.dart';
import 'package:smartmushroom_app/src/shared/models/lote_model.dart';

class SalaViewModel extends ChangeNotifier {
  SalaViewModel({
    required this.repository,
    required this.idLote,
    required this.nomeSala,
  });

  final SalaRepository repository;
  final String idLote;
  final String nomeSala;

  Timer? _timer;
  bool _initialized = false;
  bool _isDisposed = false;

  bool isLoading = true;
  bool hasError = false;
  bool isAtuadorLoading = false;
  String? errorMessage;
  bool chartsLoading = true;
  String? chartsError;
  ChartAggregation aggregation = ChartAggregation.last24h;

  LoteModel? lote;
  LeituraModel? leitura;
  Map<int, bool> atuadoresStatus = {};
  final Map<String, ChartDataModel> _chartData = {};

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await loadAll();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => refreshRealtime(),
    );
  }

  Future<void> loadAll() async {
    isLoading = true;
    hasError = false;
    _safeNotifyListeners();
    try {
      await Future.wait([
        _fetchLote(),
        _fetchUltimaLeitura(),
        _fetchAtuadores(),
      ]);
      await _loadCharts();
      isLoading = false;
    } catch (error) {
      hasError = true;
      errorMessage = error.toString();
      isLoading = false;
    } finally {
      _safeNotifyListeners();
    }
  }

  Future<void> refreshRealtime() async {
    try {
      await Future.wait([_fetchUltimaLeitura(), _fetchAtuadores()]);
    } finally {
      _safeNotifyListeners();
    }
  }

  ChartDataModel? chartFor(String metric) => _chartData[metric];

  Future<void> changeAggregation(ChartAggregation value) async {
    if (aggregation == value) return;
    aggregation = value;
    await _loadCharts();
  }

  Future<void> _fetchLote() async {
    lote = await repository.getLote(idLote);
  }

  Future<void> _fetchUltimaLeitura() async {
    leitura = await repository.getUltimaLeitura(idLote);
  }

  Future<void> _fetchAtuadores() async {
    final registros = await repository.getControleAtuadores(idLote);
    atuadoresStatus = _buildAtuadoresStatus(registros);
  }

  Future<void> _loadCharts() async {
    chartsLoading = true;
    chartsError = null;
    _safeNotifyListeners();
    try {
      final results = await Future.wait([
        repository.getChartData(
          idLote: idLote,
          metric: 'temperatura',
          aggregation: aggregation.apiValue,
        ),
        repository.getChartData(
          idLote: idLote,
          metric: 'umidade',
          aggregation: aggregation.apiValue,
        ),
        repository.getChartData(
          idLote: idLote,
          metric: 'co2',
          aggregation: aggregation.apiValue,
        ),
      ]);
      _chartData
        ..clear()
        ..addAll({
          'temperatura': results[0],
          'umidade': results[1],
          'co2': results[2],
        });
    } catch (error) {
      chartsError = error.toString();
    } finally {
      chartsLoading = false;
      _safeNotifyListeners();
    }
  }

  Map<int, bool> _buildAtuadoresStatus(List<ControleAtuadorModel> registros) {
    final Map<int, ControleAtuadorModel> latest = {};
    for (final registro in registros) {
      final id = registro.idAtuador;
      final current = latest[id];
      if (current == null) {
        latest[id] = registro;
      } else {
        final newDate = _parseDateTime(registro.dataCriacao);
        final currentDate = _parseDateTime(current.dataCriacao);
        if (newDate.isAfter(currentDate)) {
          latest[id] = registro;
        }
      }
    }

    return latest.map(
      (id, model) =>
          MapEntry(id, (model.statusAtuador).toLowerCase() == 'ativo'),
    );
  }

  Future<void> alterarStatusAtuador(int idAtuador) async {
    if (isAtuadorLoading) return;
    final bool atual = atuadoresStatus[idAtuador] ?? false;
    final bool novo = !atual;

    isAtuadorLoading = true;
    atuadoresStatus[idAtuador] = novo;
    _safeNotifyListeners();

    try {
      await repository.alterarStatusAtuador(
        idAtuador: idAtuador,
        idLote: idLote,
        ativo: novo,
      );
      await _fetchAtuadores();
    } catch (error) {
      atuadoresStatus[idAtuador] = atual;
      rethrow;
    } finally {
      isAtuadorLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<String> finalizarLote() async {
    final response = await repository.finalizarLote(idLote);
    debugPrint('[SalaViewModel] Finalizar lote ($idLote) -> $response');
    return response;
  }

  Future<String> excluirLote() => repository.excluirLote(idLote);

  double get humidityValue => (leitura?.umidadeNum ?? 0).clamp(0, 100) / 100.0;

  double get co2Value => (leitura?.co2Num ?? 0).clamp(0, 5000) / 5000.0;

  @override
  void dispose() {
    _timer?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  DateTime _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    try {
      return DateTime.parse(value.replaceFirst(' ', 'T'));
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
