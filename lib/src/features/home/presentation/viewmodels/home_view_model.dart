import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartmushroom_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_lotes_ativos.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.repository});

  final HomeRepository repository;

  final List<Salas> _salas = [];
  List<Salas> get salas => List.unmodifiable(_salas);

  bool isLoading = true;
  bool hasError = false;
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
      final result = await repository.fetchSalas();
      _salas
        ..clear()
        ..addAll(result);
      hasError = false;
    } catch (_) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool get hasData => _salas.isNotEmpty;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
