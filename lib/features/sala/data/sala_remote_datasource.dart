import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/models/Chart_Data_Model.dart';
import 'package:smartmushroom_app/models/Controle_Atuador_Model.dart';
import 'package:smartmushroom_app/models/Leitura_Model.dart';
import 'package:smartmushroom_app/models/Lote_Model.dart';

class SalaRemoteDataSource {
  SalaRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<LoteModel> fetchLote(String idLote) async {
    final response = await _dioClient.get<dynamic>(
      'framework/lote/listarIdLote/$idLote',
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return LoteModel.fromJson(data);
    }

    throw ApiException('Formato inesperado ao buscar dados do lote.');
  }

  Future<LeituraModel?> fetchUltimaLeitura(String idLote) async {
    final response = await _dioClient.get<dynamic>(
      'framework/leitura/listarUltimaLeitura/$idLote',
    );

    final data = response.data;

    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) {
        return LeituraModel.fromJson(first);
      }
    }

    if (data is Map<String, dynamic>) {
      return LeituraModel.fromJson(data);
    }

    return null;
  }

  Future<List<ControleAtuadorModel>> fetchControleAtuadores(
    String idLote,
  ) async {
    final response = await _dioClient.get<dynamic>(
      'framework/controleAtuador/listarIdLote/$idLote',
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ControleAtuadorModel.fromJson)
          .toList();
    }

    throw ApiException('Formato inesperado ao buscar atuadores.');
  }

  Future<void> alterarStatusAtuador({
    required int idAtuador,
    required String idLote,
    required bool ativo,
  }) async {
    final response = await _dioClient.post<dynamic>(
      'framework/controleAtuador/adicionar',
      data: {
        'idAtuador': idAtuador.toString(),
        'idLote': idLote,
        'statusAtuador': ativo ? 'ativo' : 'inativo',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: const {'Accept': 'application/json'},
      ),
    );

    final statusCode = response.statusCode ?? 500;
    if (statusCode < 200 || statusCode >= 300) {
      throw ApiException(
        'Falha ao alterar status do atuador.',
        statusCode: statusCode,
      );
    }
  }

  Future<String> finalizarLote(String idLote) async {
    final response = await _dioClient.delete<dynamic>(
      'framework/lote/deletar/$idLote',
      options: Options(
        headers: const {'Content-Type': Headers.formUrlEncodedContentType},
      ),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? '';
    }

    throw ApiException('Resposta inesperada ao finalizar lote.');
  }

  Future<String> excluirLote(String idLote) async {
    final response = await _dioClient.delete<dynamic>(
      'framework/lote/deletar_fisico/$idLote',
      options: Options(
        headers: const {'Content-Type': Headers.formUrlEncodedContentType},
      ),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? '';
    }

    throw ApiException('Resposta inesperada ao excluir lote.');
  }

  /// Busca os dados agregados do gráfico da API `framework/leitura/grafico`.
  ///
  /// [aggregation] aceita `daily` ou `weekly`, refletindo o comportamento
  /// suportado pelo backend. O endpoint responde com um JSON estruturado com
  /// as chaves `chart_type`, `data` (lista de pontos contendo `x`, `y` e
  /// `label`) e `metadata` com detalhes de título e eixos.

  Future<ChartDataModel> fetchChartData({
    required String idLote,
    required String metric,
    String aggregation = 'weekly', // ou 'weekly'
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'metric': metric,
        'aggregation': aggregation,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get<dynamic>(
        'framework/leitura/grafico/$idLote',
        queryParameters: queryParams,
      );
      final statusCode = response.statusCode ?? 500;
      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException(
          'Falha ao buscar dados do gráfico. Detalhes: '
          '${_stringifyResponseData(response.data)}',
          statusCode: statusCode,
        );
      }

      final data = _normaliseChartResponse(response.data);
      if (data != null) {
        return ChartDataModel.fromJson(data);
      }

      throw ApiException('A API retornou uma resposta vazia inesperada.');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Erro desconhecido ao buscar dados do gráfico: $e');
    }
  }

  Map<String, dynamic>? _normaliseChartResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        return null;
      }

      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        // Ignored to fall-through to the error below.
      }
    }

    throw ApiException(
      'Formato inesperado ao buscar dados do gráfico: tipo '
      '${data.runtimeType} recebido, esperado Map<String, dynamic>. '
      'Conteúdo: ${_stringifyResponseData(data)}',
    );
  }

  String _stringifyResponseData(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }
}
