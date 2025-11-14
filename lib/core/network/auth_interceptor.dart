import 'dart:async';

import 'package:dio/dio.dart';
import 'package:smartmushroom_app/core/auth/auth_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({AuthStorage? storage}) : _storage = storage ?? AuthStorage();

  final AuthStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode ?? 0;
    if (statusCode == 401 || statusCode == 403) {
      unawaited(_storage.clearSession());
    }
    super.onError(err, handler);
  }
}
