import 'package:smartmushroom_app/src/features/criar_lote/data/criar_lote_remote_datasource.dart';
import 'package:smartmushroom_app/src/features/criar_lote/domain/repositories/criar_lote_repository.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/cogumelos_model.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/fases_cultivo_model.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_disponiveis_model.dart';

class CriarLoteRepositoryImpl implements CriarLoteRepository {
  CriarLoteRepositoryImpl(this._remoteDataSource);

  final CriarLoteRemoteDataSource _remoteDataSource;

  @override
  Future<String> criarLote({
    required int idSala,
    required int idCogumelo,
    required int idFaseCultivo,
    required String dataInicio,
  }) =>
      _remoteDataSource.criarLote(
        idSala: idSala,
        idCogumelo: idCogumelo,
        idFaseCultivo: idFaseCultivo,
        dataInicio: dataInicio,
      );

  @override
  Future<List<Cogumelos>> fetchCogumelos() =>
      _remoteDataSource.fetchCogumelos();

  @override
  Future<List<fases_cultivo>> fetchFasesPorCogumelo(int idCogumelo) =>
      _remoteDataSource.fetchFasesPorCogumelo(idCogumelo);

  @override
  Future<List<SalaDisponivel>> fetchSalasDisponiveis() =>
      _remoteDataSource.fetchSalasDisponiveis();
}
