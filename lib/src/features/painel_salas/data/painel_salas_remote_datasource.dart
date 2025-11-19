import 'package:smartmushroom_app/src/core/network/dio_client.dart';
import 'package:smartmushroom_app/src/shared/models/Antigas/salas_lotes_ativos.dart';

class PainelSalasRemoteDataSource {
  PainelSalasRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<List<Salas>> fetchSalas() async {
    final response = await _dioClient.get<dynamic>(
      'framework/sala/listarSalasComLotesAtivos',
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return SalaLotesAtivos.fromJson(data).salas ?? [];
    }

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Salas.fromJson)
          .toList();
    }

    throw Exception('Formato inesperado ao carregar salas.');
  }
}
