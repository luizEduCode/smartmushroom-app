import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:smartmushroom_app/core/auth/auth_models.dart';
import 'package:smartmushroom_app/core/auth/auth_storage.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';

class AuthRepository {
  AuthRepository({DioClient? client, AuthStorage? storage})
    : _client = client ?? DioClient(),
      _storage = storage ?? AuthStorage();

  final DioClient _client;
  final AuthStorage _storage;

  Future<AuthSession> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        'framework/usuario/login',
        data: FormData.fromMap({'email': email, 'senha': senha}),
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      final statusCode = response.statusCode ?? 500;
      final data = response.data;

      if (statusCode == 200 && data is Map<String, dynamic>) {
        final token = data['token'] as String?;
        final userData = data['usuario'];

        if (token == null || token.isEmpty) {
          throw ApiException(
            'Token não recebido. Tente novamente em instantes.',
            statusCode: statusCode,
          );
        }

        final session = AuthSession(
          token: token,
          user:
              userData is Map<String, dynamic>
                  ? AuthUser.fromJson(userData)
                  : null,
        );

        developer.log('Token recebido: $token', name: 'AuthRepository');

        await _storage.saveSession(session);
        return session;
      }

      if (statusCode == 400 || statusCode == 401) {
        final message = _extractErrorMessage(data) ?? 'Credenciais inválidas.';
        throw ApiException(message, statusCode: statusCode);
      }

      throw ApiException(
        'Não foi possível concluir o login. Código: $statusCode',
        statusCode: statusCode,
      );
    } on DioException catch (err) {
      throw ApiException.fromDioError(err);
    }
  }

  Future<void> logout() => _storage.clearSession();

  String? get token => _storage.token;
  AuthUser? get user => _storage.user;

  bool get isAuthenticated => _storage.hasSession;

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
