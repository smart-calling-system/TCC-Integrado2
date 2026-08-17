import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import '../session/session_manager.dart'; 
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, SessionManager? sessionManager})
    : _httpClient = httpClient ?? http.Client(),
      _sessionManager = sessionManager ?? SessionManager();

  final http.Client _httpClient;
  final SessionManager _sessionManager;

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

    final token = accessToken ?? _sessionManager.state?.accessToken;

    // Amortecedor de Sessão mantido para o login não engasgar
    if ((token == null || token.isEmpty) && !endpoint.contains('/auth/login')) {
      return <String, dynamic>{'data': []}; 
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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

      // 👇 O RASTREADOR DO LUKA: Vamos ler as respostas originais do Node!
      print('🕵️ LUKA ESPIONANDO A ROTA [$endpoint]: $decoded');

      if (response.statusCode >= 400) {
        throw ApiException(
          decoded['message'] as String? ?? 'Erro retornado pelo servidor.',
          statusCode: response.statusCode,
          type: response.statusCode == 401
              ? AppExceptionType.sessionExpired
              : AppExceptionType.serverUnavailable,
        );
      }

      // Hack de paginação removido! O Flutter vai receber os dados puros.
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