import 'package:dio/dio.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/models/fase_cultivo_model.dart';
import 'package:smartmushroom_app/models/historico_fase_model.dart';
import 'package:smartmushroom_app/models/lote_model.dart';
import 'package:smartmushroom_app/models/parametro_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode) $message';
}

class EditarParametrosRemote {
  EditarParametrosRemote(this._client);
  final DioClient _client;

  Future<LoteModel> getLote(int idLote) async {
    try {
      final r = await _client.get('framework/lote/listarIdLote/$idLote');
      if (r.statusCode == 200 && r.data is Map<String, dynamic>) {
        return LoteModel.fromJson(r.data as Map<String, dynamic>);
      }
      throw ApiException('Erro ao buscar lote', statusCode: r.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Falha de rede',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<HistoricoFaseModel> getHistoricoFaseAtual(int idLote) async {
    try {
      final r = await _client.get(
        'framework/historico_fase/listarIdLote/$idLote',
      );
      if (r.statusCode == 200 && r.data is List) {
        final lista = (r.data as List).cast<dynamic>();
        if (lista.isEmpty) {
          throw ApiException(
            'Histórico vazio para o lote $idLote',
            statusCode: 404,
          );
        }
        final json0 = (lista.first as Map).cast<String, dynamic>();
        return HistoricoFaseModel.fromJson(json0);
      }
      throw ApiException(
        'Erro ao buscar histórico de fase',
        statusCode: r.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Falha de rede',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<FaseCultivoModel>> getFasesPorCogumelo(int idCogumelo) async {
    try {
      final r = await _client.get(
        'framework/faseCultivo/listarPorCogumelo/$idCogumelo',
      );
      if (r.statusCode == 200 && r.data is List) {
        final lista =
            (r.data as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => FaseCultivoModel.fromJson(e))
                .toList();
        return lista;
      }
      throw ApiException(
        'Erro ao buscar fase de cultivo',
        statusCode: r.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Falha de rede',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ParametroModel> getParametro(int idLote) async {
    try {
      final r = await _client.get('framework/parametros/listarIdLote/$idLote');

      if (r.statusCode == 200 && r.data is List) {
        final lista =
            (r.data as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => ParametroModel.fromJson(e))
                .toList();

        if (lista.isEmpty) {
          throw ApiException(
            'Sem parâmetros para o lote $idLote',
            statusCode: 404,
          );
        }

        return lista.first;
      }

      if (r.statusCode == 404) {
        throw ApiException(
          'Sem parâmetros para o lote $idLote',
          statusCode: 404,
        );
      }

      throw ApiException('Erro ao buscar parâmetros', statusCode: r.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Falha de rede',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ParametroModel?> getParametroMaisRecente(int idLote) async {
    final response = await _client.get(
      'framework/parametros/listarIdLote/$idLote',
    );

    if (response.statusCode == 200 && response.data is List) {
      final parametros =
          (response.data as List)
              .whereType<Map<String, dynamic>>()
              .map((json) => ParametroModel.fromJson(json))
              .toList();

      DateTime? parseData(String? dataString) =>
          dataString == null
              ? null
              : DateTime.tryParse(dataString.replaceFirst(' ', 'T'));

      parametros.sort((parametroAtual, parametroProximo) {
        final dataAtual =
            parseData(parametroAtual.dataCriacao) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final dataProxima =
            parseData(parametroProximo.dataCriacao) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return dataProxima.compareTo(dataAtual); // Ordem decrescente
      });

      return parametros.isEmpty ? null : parametros.first;
    }

    if (response.statusCode == 404) return null;
    throw ApiException(
      'Erro ao buscar parâmetros',
      statusCode: response.statusCode,
    );
  }
  Future<void> postHistoricoFase({
    required int idLote,
    required int idFaseCultivo,
  }) async {
    try {
      final form = FormData.fromMap({
        'idLote': idLote.toString(),
        'idFaseCultivo': idFaseCultivo.toString(),
      });

      final r = await _client.post(
        'framework/historico_fase/adicionar',
        data: form,
      );

      final sc = r.statusCode ?? 500;
      if (sc != 200 && sc != 201) {
        throw ApiException('Falha ao salvar histórico de fase', statusCode: sc);
      }
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data is Map && e.response?.data['error'] != null
            ? e.response?.data['error'].toString() ?? 'Erro'
            : (e.message ?? 'Falha de rede'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> postParametros({
    required int idLote,
    required double umidadeMin,
    required double umidadeMax,
    required double temperaturaMin,
    required double temperaturaMax,
    required double co2Max,
  }) async {
    try {
      final form = FormData.fromMap({
        'idLote': idLote.toString(),
        'umidadeMin': umidadeMin.toStringAsFixed(2),
        'umidadeMax': umidadeMax.toStringAsFixed(2),
        'temperaturaMin': temperaturaMin.toStringAsFixed(2),
        'temperaturaMax': temperaturaMax.toStringAsFixed(2),
        'co2Max': co2Max.toStringAsFixed(2),
      });

      final r = await _client.post(
        'framework/parametros/adicionar',
        data: form,
      );

      final sc = r.statusCode ?? 500;
      if (sc != 200 && sc != 201) {
        throw ApiException('Falha ao salvar parâmetros', statusCode: sc);
      }
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data is Map && e.response?.data['error'] != null
            ? e.response?.data['error'].toString() ?? 'Erro'
            : (e.message ?? 'Falha de rede'),
        statusCode: e.response?.statusCode,
      );
    }
  }

}
