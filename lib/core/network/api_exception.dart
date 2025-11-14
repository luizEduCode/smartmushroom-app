import 'dart:io';

import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDioError(DioException dioError) {
    String errorMessage = 'Ocorreu um erro inesperado.';
    int? errorStatusCode;

    final Object? rawError = dioError.error;
    if (rawError is SocketException) {
      return ApiException(
        'Nao foi possivel conectar ao servidor. Verifique sua internet e o IP configurado.',
        statusCode: dioError.response?.statusCode,
      );
    }

    if (dioError.response != null) {
      errorStatusCode = dioError.response!.statusCode;

      if (dioError.response!.data is Map<String, dynamic>) {
        final responseData = dioError.response!.data as Map<String, dynamic>;
        final message = responseData['message'] ?? responseData['error'];
        if (message is String && message.isNotEmpty) {
          errorMessage = message;
        } else {
          errorMessage = dioError.response!.statusMessage ?? 'Erro no servidor';
        }
      } else {
        errorMessage = dioError.response!.statusMessage ?? 'Erro no servidor';
      }
    } else {
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'Tempo limite excedido. Verifique sua conexao com a internet.';
          break;
        case DioExceptionType.badResponse:
          errorMessage =
              'Requisicao invalida (codigo: ${dioError.response?.statusCode ?? 'N/A'}).';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'A requisicao foi cancelada.';
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              'Falha de conexao. Verifique sua internet e tente novamente.';
          break;
        case DioExceptionType.unknown:
        default:
          final message = dioError.message ?? '';
          final bool isHostLookup = message.contains('Failed host lookup');
          final bool isNetworkUnreachable =
              message.contains('Network is unreachable');
          if (isHostLookup || isNetworkUnreachable) {
            errorMessage =
                'Nao foi possivel conectar ao servidor. Confirme a internet e o IP configurado.';
          } else if (message.isNotEmpty) {
            errorMessage = message;
          } else {
            errorMessage = 'Erro desconhecido. Verifique sua conexao.';
          }
          break;
      }
    }

    return ApiException(errorMessage, statusCode: errorStatusCode);
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
