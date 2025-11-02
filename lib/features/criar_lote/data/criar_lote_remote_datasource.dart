import 'package:dio/dio.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/models/Antigas/cogumelos_model.dart';
import 'package:smartmushroom_app/models/Antigas/fases_cultivo_model.dart';
import 'package:smartmushroom_app/models/Antigas/salas_disponiveis_model.dart';

class CriarLoteRemoteDataSource {
  CriarLoteRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<SalaDisponivel>> fetchSalasDisponiveis() async {
    final response = await _dioClient.get<dynamic>(
      'framework/lote/listarSalasDisponiveis',
    );

    return _parseSalaDisponivel(response.data);
  }

  Future<List<Cogumelos>> fetchCogumelos() async {
    final response = await _dioClient.get<dynamic>(
      'framework/cogumelo/listarTodos',
    );

    return _parseLista(response.data, 'Cogumelos', Cogumelos.fromJson);
  }

  Future<List<fases_cultivo>> fetchFasesPorCogumelo(int idCogumelo) async {
    final response = await _dioClient.get<dynamic>(
      'framework/faseCultivo/listarPorCogumelo/$idCogumelo',
    );

    return _parseLista(response.data, 'fases', fases_cultivo.fromJson);
  }

  Future<String> criarLote({
    required int idSala,
    required int idCogumelo,
    required int idFaseCultivo,
    required String dataInicio,
  }) async {
    final response = await _dioClient.post<dynamic>(
      'framework/lote/adicionar',
      data: {
        'idSala': idSala.toString(),
        'idCogumelo': idCogumelo.toString(),
        'dataInicio': dataInicio,
        'status': 'ativo',
        'faseCultivo': idFaseCultivo.toString(),
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: const {'Accept': 'application/json'},
      ),
    );

    final statusCode = response.statusCode ?? 500;
    if (statusCode != 201 && (statusCode < 200 || statusCode >= 300)) {
      throw ApiException('Erro ao criar lote.', statusCode: statusCode);
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['idLote']?.toString() ?? '';
    }

    throw ApiException('Resposta inesperada ao criar lote.');
  }

  List<SalaDisponivel> _parseSalaDisponivel(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(SalaDisponivel.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['success'] == true) {
        final dynamic innerData = data['data'] ?? data['salas_disponiveis'];
        if (innerData is List) {
          return innerData
              .whereType<Map<String, dynamic>>()
              .map(SalaDisponivel.fromJson)
              .toList();
        }
        if (innerData is Map<String, dynamic>) {
          final nested = innerData['salas_disponiveis'];
          if (nested is List) {
            return nested
                .whereType<Map<String, dynamic>>()
                .map(SalaDisponivel.fromJson)
                .toList();
          }
        }
      }
    }

    throw ApiException('Formato inesperado ao carregar salas disponíveis.');
  }

  List<T> _parseLista<T>(
    dynamic data,
    String key,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(mapper).toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['success'] == true) {
        final dynamic inner = data['data'] ?? data[key];
        if (inner is List) {
          return inner.whereType<Map<String, dynamic>>().map(mapper).toList();
        }
        if (inner is Map<String, dynamic>) {
          final nested = inner[key];
          if (nested is List) {
            return nested
                .whereType<Map<String, dynamic>>()
                .map(mapper)
                .toList();
          }
        }
      }
      if (data[key] is List) {
        return (data[key] as List)
            .whereType<Map<String, dynamic>>()
            .map(mapper)
            .toList();
      }
    }

    throw ApiException('Formato inesperado ao carregar $key.');
  }
}
