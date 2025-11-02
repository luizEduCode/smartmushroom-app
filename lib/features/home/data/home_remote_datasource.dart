import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/models/Antigas/salas_lotes_ativos.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._dioClient);

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

    throw Exception('Formato inesperado ao buscar salas.');
  }
}
