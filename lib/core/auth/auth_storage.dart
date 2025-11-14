import 'package:get_storage/get_storage.dart';
import 'package:smartmushroom_app/core/auth/auth_models.dart';

class AuthStorage {
  AuthStorage({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  final GetStorage _storage;

  Future<void> saveSession(AuthSession session) async {
    await _storage.write(_tokenKey, session.token);
    if (session.user != null) {
      await _storage.write(_userKey, session.user!.toJson());
    } else {
      await _storage.remove(_userKey);
    }
  }

  String? get token {
    final storedToken = _storage.read<dynamic>(_tokenKey);
    if (storedToken is String && storedToken.isNotEmpty) {
      return storedToken;
    }
    return null;
  }

  AuthUser? get user {
    final data = _storage.read<dynamic>(_userKey);
    if (data is Map) {
      return AuthUser.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  bool get hasSession => token != null;

  Future<void> clearSession() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_userKey);
  }
}
