import 'package:get_storage/get_storage.dart';

class ApiConfig {
  ApiConfig._();

  static const String _defaultIp = '192.168.1.31';
  static final GetStorage _storage = GetStorage();

  static String get baseUrl {
    final savedIp = _storage.read<String>('server_ip');
    final ip = (savedIp == null || savedIp.isEmpty) ? _defaultIp : savedIp;
    return 'http://$ip/smartmushroom-api/';
  }
}
