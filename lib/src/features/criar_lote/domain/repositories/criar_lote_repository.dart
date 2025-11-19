import 'package:smartmushroom_app/src/shared/models/Antigas/cogumelos_model.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/fases_cultivo_model.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_disponiveis_model.dart';

abstract class CriarLoteRepository {
  Future<List<SalaDisponivel>> fetchSalasDisponiveis();

  Future<List<Cogumelos>> fetchCogumelos();

  Future<List<fases_cultivo>> fetchFasesPorCogumelo(int idCogumelo);

  Future<String> criarLote({
    required int idSala,
    required int idCogumelo,
    required int idFaseCultivo,
    required String dataInicio,
  });
}
