import 'package:smartmushroom_app/src/shared/models/Antigas/salas_lotes_ativos.dart';

abstract class PainelSalasRepository {
  Future<List<Salas>> fetchSalas();
}
