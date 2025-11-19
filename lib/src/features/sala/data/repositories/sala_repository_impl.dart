import 'package:smartmushroom_app/src/features/sala/data/datasources/sala_remote_data_source.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/chart_data_model.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/controle_atuador_model.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/leitura_model.dart';
import 'package:smartmushroom_app/src/features/sala/domain/repositories/sala_repository.dart';
import 'package:smartmushroom_app/src/shared/models/lote_model.dart';

class SalaRepositoryImpl implements SalaRepository {
  SalaRepositoryImpl(this._remoteDataSource);

  final SalaRemoteDataSource _remoteDataSource;

  @override
  Future<void> alterarStatusAtuador({
    required int idAtuador,
    required String idLote,
    required bool ativo,
  }) =>
      _remoteDataSource.alterarStatusAtuador(
        idAtuador: idAtuador,
        idLote: idLote,
        ativo: ativo,
      );

  @override
  Future<String> excluirLote(String idLote) =>
      _remoteDataSource.excluirLote(idLote);

  @override
  Future<List<ControleAtuadorModel>> getControleAtuadores(String idLote) =>
      _remoteDataSource.fetchControleAtuadores(idLote);

  @override
  Future<ChartDataModel> getChartData({
    required String idLote,
    required String metric,
    required String aggregation,
    String? startDate,
    String? endDate,
  }) =>
      _remoteDataSource.fetchChartData(
        idLote: idLote,
        metric: metric,
        aggregation: aggregation,
        startDate: startDate,
        endDate: endDate,
      );

  @override
  Future<LoteModel> getLote(String idLote) => _remoteDataSource.fetchLote(
        idLote,
      );

  @override
  Future<LeituraModel?> getUltimaLeitura(String idLote) =>
      _remoteDataSource.fetchUltimaLeitura(idLote);

  @override
  Future<String> finalizarLote(String idLote) =>
      _remoteDataSource.finalizarLote(idLote);
}
