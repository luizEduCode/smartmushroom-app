import 'package:dio/dio.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
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

  Future<List<ControleAtuadorModel>> fetchControleAtuadores(String idLote) async {
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
      throw ApiException('Falha ao alterar status do atuador.', statusCode: statusCode);
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
}
