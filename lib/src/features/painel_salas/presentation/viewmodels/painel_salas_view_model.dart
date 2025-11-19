import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartmushroom_app/src/features/painel_salas/domain/repositories/painel_salas_repository.dart';
import 'package:smartmushroom_app/src/features/sala/domain/repositories/sala_repository.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_lotes_ativos.dart';

class PainelSalasViewModel extends ChangeNotifier {
  PainelSalasViewModel({
    required this.repository,
    required this.salaRepository,
  });

  final PainelSalasRepository repository;
  final SalaRepository salaRepository;

  final List<Salas> _salas = [];
  List<Salas> get salas => List.unmodifiable(_salas);

  Map<int, Map<int, bool>> atuadoresStatus = {};

  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  bool _initialized = false;
  Timer? _timer;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await refresh();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
  }

  Future<void> refresh() async {
    try {
      if (!hasData) {
        isLoading = true;
        notifyListeners();
      }
      final List<Salas> result = await repository.fetchSalas();
      _salas
        ..clear()
        ..addAll(result);
      atuadoresStatus = await _carregarAtuadores(result);
      hasError = false;
      errorMessage = null;
    } catch (error) {
      hasError = true;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool get hasData => _salas.isNotEmpty;

  Future<Map<int, Map<int, bool>>> _carregarAtuadores(
    List<Salas> salas,
  ) async {
    final Map<int, Map<int, bool>> resultado = {};
    final futures = <Future<void>>[];

    for (final sala in salas) {
      final lote = _primeiroLoteAtivo(sala);
      final idLote = lote?.idLote;
      if (idLote == null) continue;

      futures.add(
        salaRepository.getControleAtuadores(idLote.toString()).then((registros) {
          resultado[idLote] = {
            for (final registro in registros)
              registro.idAtuador:
                  registro.statusAtuador.toLowerCase() == 'ativo',
          };
        }).catchError((_) {}),
      );
    }

    await Future.wait(futures);
    return resultado;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Lotes? _primeiroLoteAtivo(Salas sala) {
    final lotes = sala.lotes;
    if (lotes == null || lotes.isEmpty) return null;
    return lotes.firstWhere(
      (lote) => (lote.status ?? '').toLowerCase() == 'ativo',
      orElse: () => lotes.first,
    );
  }
}
