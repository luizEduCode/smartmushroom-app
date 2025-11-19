import 'package:smartmushroom_app/src/features/painel_salas/data/painel_salas_remote_datasource.dart';
import 'package:smartmushroom_app/src/features/painel_salas/domain/repositories/painel_salas_repository.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_lotes_ativos.dart';

class PainelSalasRepositoryImpl implements PainelSalasRepository {
  PainelSalasRepositoryImpl(this._remoteDataSource);

  final PainelSalasRemoteDataSource _remoteDataSource;

  @override
  Future<List<Salas>> fetchSalas() => _remoteDataSource.fetchSalas();
}
