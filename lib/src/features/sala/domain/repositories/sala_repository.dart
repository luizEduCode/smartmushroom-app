import 'package:smartmushroom_app/src/features/sala/data/models/chart_data_model.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/controle_atuador_model.dart';
import 'package:smartmushroom_app/src/features/sala/data/models/leitura_model.dart';
import 'package:smartmushroom_app/src/shared/models/lote_model.dart';

abstract class SalaRepository {
  Future<LoteModel> getLote(String idLote);

  Future<LeituraModel?> getUltimaLeitura(String idLote);

  Future<List<ControleAtuadorModel>> getControleAtuadores(String idLote);

  Future<void> alterarStatusAtuador({
    required int idAtuador,
    required String idLote,
    required bool ativo,
  });

  Future<String> finalizarLote(String idLote);

  Future<String> excluirLote(String idLote);

  Future<ChartDataModel> getChartData({
    required String idLote,
    required String metric,
    required String aggregation,
    String? startDate,
    String? endDate,
  });
}
