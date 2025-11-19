import 'package:flutter/material.dart';
import 'package:smartmushroom_app/src/core/network/api_exception.dart';
import 'package:smartmushroom_app/src/features/criar_lote/domain/repositories/criar_lote_repository.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/cogumelos_model.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/fases_cultivo_model.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_disponiveis_model.dart';

class CriarLoteViewModel extends ChangeNotifier {
  CriarLoteViewModel({required this.repository});

  final CriarLoteRepository repository;

  bool isSubmitting = false;

  List<SalaDisponivel> salas = [];
  SalaDisponivel? salaSelecionada;
  bool isLoadingSalas = true;
  String? salasErro;

  List<Cogumelos> cogumelos = [];
  Cogumelos? cogumeloSelecionado;
  bool isLoadingCogumelos = true;
  String? cogumelosErro;

  List<fases_cultivo> fases = [];
  fases_cultivo? faseSelecionada;
  bool isLoadingFases = false;
  String? fasesErro;

  Future<void> initialize() async {
    await Future.wait([
      carregarSalas(),
      carregarCogumelos(),
    ]);
  }

  Future<void> carregarSalas() async {
    isLoadingSalas = true;
    salasErro = null;
    notifyListeners();
    try {
      salas = await repository.fetchSalasDisponiveis();
      if (salaSelecionada != null) {
        final selectedId = salaSelecionada!.idSala;
        salaSelecionada =
            salas.firstWhere(
              (sala) => sala.idSala == selectedId,
              orElse: () => salaSelecionada!,
            );
      }
    } catch (error) {
      salasErro = error.toString();
    } finally {
      isLoadingSalas = false;
      notifyListeners();
    }
  }

  Future<void> carregarCogumelos() async {
    isLoadingCogumelos = true;
    cogumelosErro = null;
    notifyListeners();
    try {
      cogumelos = await repository.fetchCogumelos();
      if (cogumeloSelecionado != null) {
        final id = cogumeloSelecionado!.idCogumelo;
        cogumeloSelecionado =
            cogumelos.firstWhere(
              (c) => c.idCogumelo == id,
              orElse: () => cogumeloSelecionado!,
            );
      }
      if (cogumeloSelecionado != null) {
        await carregarFases(cogumeloSelecionado!);
      }
    } catch (error) {
      cogumelosErro = error.toString();
    } finally {
      isLoadingCogumelos = false;
      notifyListeners();
    }
  }

  Future<void> carregarFases(Cogumelos cogumelo) async {
    cogumeloSelecionado = cogumelo;
    fases = [];
    faseSelecionada = null;
    fasesErro = null;
    isLoadingFases = true;
    notifyListeners();
    try {
      fases = await repository.fetchFasesPorCogumelo(cogumelo.idCogumelo);
    } catch (error) {
      fasesErro = error.toString();
    } finally {
      isLoadingFases = false;
      notifyListeners();
    }
  }

  void selecionarSala(SalaDisponivel? sala) {
    salaSelecionada = sala;
    notifyListeners();
  }

  void selecionarFase(fases_cultivo? fase) {
    faseSelecionada = fase;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      carregarSalas(),
      carregarCogumelos(),
      if (cogumeloSelecionado != null) carregarFases(cogumeloSelecionado!),
    ]);
  }

  Future<String> criarLote() async {
    final sala = salaSelecionada;
    final cogumelo = cogumeloSelecionado;
    final fase = faseSelecionada;
    if (sala == null || cogumelo == null || fase == null) {
      throw ApiException('Preencha todos os campos para continuar.');
    }

    if (isSubmitting) return '';
    isSubmitting = true;
    notifyListeners();
    try {
      final agora = DateTime.now();
      final dataInicio =
          '${agora.year}-${agora.month.toString().padLeft(2, '0')}-${agora.day.toString().padLeft(2, '0')}';
      final id = await repository.criarLote(
        idSala: sala.idSala,
        idCogumelo: cogumelo.idCogumelo,
        idFaseCultivo: fase.idFaseCultivo ?? 0,
        dataInicio: dataInicio,
      );
      return id;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
