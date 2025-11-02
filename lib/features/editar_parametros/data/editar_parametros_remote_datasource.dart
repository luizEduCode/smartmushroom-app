import 'package:dio/dio.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/models/Fase_Cultivo_Model.dart';
import 'package:smartmushroom_app/models/Parametro_Model.dart';

class EditarParametrosRemoteDataSource {
  EditarParametrosRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<ParametroModel> fetchParametros(String idLote) async {
    final response = await _dioClient.get<dynamic>(
      'framework/parametros/listarIdParametro/$idLote',
    );

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    if (statusCode == 200 && data is Map<String, dynamic>) {
      return ParametroModel.fromJson(data);
    }

    if (statusCode == 404 && data is Map<String, dynamic>) {
      final message = data['error']?.toString() ?? 'Configuração não existe';
      throw ApiException(message, statusCode: statusCode);
    }

    throw ApiException('Erro ao carregar parâmetros.', statusCode: statusCode);
  }

  Future<FaseCultivoModel?> fetchParametrosPorFase(String idFase) async {
    final response = await _dioClient.get<dynamic>(
      'framework/faseCultivo/listarIdFaseCultivo/$idFase',
    );

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    if (statusCode == 200 && data is Map<String, dynamic>) {
      return FaseCultivoModel.fromJson(data);
    }

    throw ApiException(
      'Erro ao carregar parâmetros da fase.',
      statusCode: statusCode,
    );
  }

  Future<List<FaseCultivoModel>> fetchFasesPorCogumelo(int idCogumelo) async {
    final response = await _dioClient.get<dynamic>(
      'framework/faseCultivo/listarPorCogumelo/$idCogumelo',
    );

    return _parseFases(response.data);
  }

  Future<void> salvarParametros({
    required String idLote,
    required double temperaturaMin,
    required double temperaturaMax,
    required double umidadeMin,
    required double umidadeMax,
    required double co2Max,
    int? idFaseCultivo,
  }) async {
    final response = await _dioClient.put<dynamic>(
      'configuracao.php',
      data: {
        'idLote': idLote,
        'temperaturaMin': temperaturaMin,
        'temperaturaMax': temperaturaMax,
        'umidadeMin': umidadeMin,
        'umidadeMax': umidadeMax,
        'co2Max': co2Max,
        'idFaseCultivo': idFaseCultivo,
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    final statusCode = response.statusCode ?? 500;
    if (statusCode != 200) {
      final data = response.data;
      final message =
          data is Map<String, dynamic> ? data['message']?.toString() : null;
      throw ApiException(
        message ?? 'Erro ao salvar parâmetros.',
        statusCode: statusCode,
      );
    }
  }

  List<FaseCultivoModel> _parseFases(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(FaseCultivoModel.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['success'] == true) {
        final dynamic inner = data['data'] ?? data['fases'];
        if (inner is List) {
          return inner
              .whereType<Map<String, dynamic>>()
              .map(FaseCultivoModel.fromJson)
              .toList();
        }
        if (inner is Map<String, dynamic>) {
          final nested = inner['fases'];
          if (nested is List) {
            return nested
                .whereType<Map<String, dynamic>>()
                .map(FaseCultivoModel.fromJson)
                .toList();
          }
        }
      }
      if (data['fases'] is List) {
        return (data['fases'] as List)
            .whereType<Map<String, dynamic>>()
            .map(FaseCultivoModel.fromJson)
            .toList();
      }
    }

    throw ApiException('Formato inesperado ao carregar fases.');
  }
}
