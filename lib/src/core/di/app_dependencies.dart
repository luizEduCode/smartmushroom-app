import 'package:smartmushroom_app/src/core/auth/auth_repository.dart';
import 'package:smartmushroom_app/src/core/network/dio_client.dart';
import 'package:smartmushroom_app/src/core/theme/theme_notifier.dart';
import 'package:smartmushroom_app/src/features/criar_lote/data/criar_lote_remote_datasource.dart';
import 'package:smartmushroom_app/src/features/criar_lote/data/repositories/criar_lote_repository_impl.dart';
import 'package:smartmushroom_app/src/features/criar_lote/domain/repositories/criar_lote_repository.dart';
import 'package:smartmushroom_app/src/features/home/data/home_remote_datasource.dart';
import 'package:smartmushroom_app/src/features/home/data/repositories/home_repository_impl.dart';
import 'package:smartmushroom_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:smartmushroom_app/src/features/painel_salas/data/painel_salas_remote_datasource.dart';
import 'package:smartmushroom_app/src/features/painel_salas/data/repositories/painel_salas_repository_impl.dart';
import 'package:smartmushroom_app/src/features/painel_salas/domain/repositories/painel_salas_repository.dart';
import 'package:smartmushroom_app/src/features/sala/data/datasources/sala_remote_data_source.dart';
import 'package:smartmushroom_app/src/features/sala/data/repositories/sala_repository_impl.dart';
import 'package:smartmushroom_app/src/features/sala/domain/repositories/sala_repository.dart';

class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  late final DioClient _dioClient = DioClient();

  DioClient get dioClient => _dioClient;

  late final AuthRepository _authRepository = AuthRepository();
  AuthRepository get authRepository => _authRepository;

  late final ThemeViewModel _themeViewModel = ThemeViewModel();
  ThemeViewModel get themeViewModel => _themeViewModel;

  late final SalaRemoteDataSource _salaRemoteDataSource =
      SalaRemoteDataSource(_dioClient);
  late final SalaRepository _salaRepository =
      SalaRepositoryImpl(_salaRemoteDataSource);

  SalaRepository get salaRepository => _salaRepository;

  late final HomeRemoteDataSource _homeRemoteDataSource =
      HomeRemoteDataSource(_dioClient);
  late final HomeRepository _homeRepository =
      HomeRepositoryImpl(_homeRemoteDataSource);

  HomeRepository get homeRepository => _homeRepository;

  late final PainelSalasRemoteDataSource _painelRemoteDataSource =
      PainelSalasRemoteDataSource(_dioClient);
  late final PainelSalasRepository _painelSalasRepository =
      PainelSalasRepositoryImpl(_painelRemoteDataSource);

  PainelSalasRepository get painelSalasRepository => _painelSalasRepository;

  late final CriarLoteRemoteDataSource _criarLoteRemoteDataSource =
      CriarLoteRemoteDataSource(_dioClient);
  late final CriarLoteRepository _criarLoteRepository =
      CriarLoteRepositoryImpl(_criarLoteRemoteDataSource);

  CriarLoteRepository get criarLoteRepository => _criarLoteRepository;
}
