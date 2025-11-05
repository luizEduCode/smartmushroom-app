// lib/core/network/api_exception.dart

import 'package:dio/dio.dart'; // <<< Adicione esta importação para DioException

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  // Adicione este construtor de fábrica
  factory ApiException.fromDioError(DioException dioError) {
    String errorMessage = 'Ocorreu um erro inesperado.';
    int? errorStatusCode;

    // Se houver uma resposta do servidor
    if (dioError.response != null) {
      errorStatusCode = dioError.response!.statusCode;

      // Tenta extrair a mensagem de erro do corpo da resposta JSON
      // Presumindo que a API retorne um JSON como {"message": "..."} ou {"error": "..."}
      if (dioError.response!.data is Map<String, dynamic>) {
        final responseData = dioError.response!.data as Map<String, dynamic>;
        if (responseData.containsKey('message') && responseData['message'] is String) {
          errorMessage = responseData['message'] as String;
        } else if (responseData.containsKey('error') && responseData['error'] is String) {
          errorMessage = responseData['error'] as String;
        } else {
          // Fallback para status message se não encontrar message/error no JSON
          errorMessage = dioError.response!.statusMessage ?? 'Erro no servidor';
        }
      } else {
        // Se a resposta não for um JSON ou estiver vazia
        errorMessage = dioError.response!.statusMessage ?? 'Erro no servidor';
      }
    }
    // Lidar com diferentes tipos de DioException
    else {
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Tempo limite de conexão excedido. Verifique sua conexão com a internet.';
          break;
        case DioExceptionType.badResponse: // Erros 4xx, 5xx já foram tratados acima, mas para garantir
          errorMessage = 'Requisição inválida (código: ${dioError.response?.statusCode ?? 'N/A'}).';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'A requisição foi cancelada.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Falha de conexão. Verifique sua conexão com a internet.';
          break;
        case DioExceptionType.unknown:
        default:
          errorMessage = 'Erro desconhecido: ${dioError.message ?? 'Verifique sua conexão.'}';
          break;
      }
    }

    return ApiException(errorMessage, statusCode: errorStatusCode);
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}