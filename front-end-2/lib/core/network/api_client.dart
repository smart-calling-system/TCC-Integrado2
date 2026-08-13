import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? accessToken,
    Map<String, dynamic>? query,
  }) => _send('GET', endpoint, accessToken: accessToken, query: query);

  Future<Map<String, dynamic>> post(
    String endpoint, {
    String? accessToken,
    Object? body,
  }) => _send('POST', endpoint, accessToken: accessToken, body: body);

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    String? accessToken,
    Object? body,
  }) => _send('PATCH', endpoint, accessToken: accessToken, body: body);

  Future<Map<String, dynamic>> delete(String endpoint, {String? accessToken}) =>
      _send('DELETE', endpoint, accessToken: accessToken);

  Future<Map<String, dynamic>> _send(
    String method,
    String endpoint, {
    String? accessToken,
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    if (!ApiConfig.apiIntegrationEnabled) {
      throw const ApiException(
        'Integracao com API desativada nesta versao.',
        type: AppExceptionType.serverUnavailable,
      );
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    try {
      final uri = ApiConfig.uri(endpoint, query);
      final requestBody = body == null ? null : jsonEncode(body);
      final response = await switch (method) {
        'GET' => _httpClient.get(uri, headers: headers),
        'POST' => _httpClient.post(uri, headers: headers, body: requestBody),
        'PATCH' => _httpClient.patch(uri, headers: headers, body: requestBody),
        'DELETE' => _httpClient.delete(uri, headers: headers),
        _ => throw const ApiException('Metodo HTTP nao suportado.'),
      }.timeout(const Duration(seconds: 20));

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400) {
        throw ApiException(
          decoded['message'] as String? ?? 'Erro retornado pelo servidor.',
          statusCode: response.statusCode,
          type: response.statusCode == 401
              ? AppExceptionType.sessionExpired
              : AppExceptionType.serverUnavailable,
        );
      }

      return decoded;
    } on TimeoutException catch (error) {
      throw ApiException(
        'Tempo limite de comunicacao com o servidor.',
        type: AppExceptionType.timeout,
        cause: error,
      );
    } on FormatException catch (error) {
      throw ApiException(
        'Resposta invalida recebida do servidor.',
        type: AppExceptionType.invalidPayload,
        cause: error,
      );
    }
  }
}
