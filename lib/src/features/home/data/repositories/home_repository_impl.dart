import 'package:smartmushroom_app/src/features/home/data/home_remote_datasource.dart';
import 'package:smartmushroom_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_lotes_ativos.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<List<Salas>> fetchSalas() => _remoteDataSource.fetchSalas();
}
