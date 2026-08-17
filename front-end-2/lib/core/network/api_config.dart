class ApiConfig {
  ApiConfig._();

  // Habilitado por padrão para permitir as requisições
  static const bool apiIntegrationEnabled = bool.fromEnvironment(
    'API_INTEGRATION_ENABLED',
    defaultValue: true,
  );

  // Base URL limpa (sem o prefixo de versão no final)
  static const String baseUrl = 'http://10.133.101.13:3000';

  // Prefixo oficial da API
  static const String apiPrefix = '/api/v1';

  static Uri uri(String endpoint, [Map<String, dynamic>? query]) {
    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
        
    // Montagem correta: http://10.133.101.12:3000 + /api/v1 + /endpoint
    final uri = Uri.parse('$normalizedBase$apiPrefix$normalizedEndpoint');

    if (query == null || query.isEmpty) return uri;

    return uri.replace(
      queryParameters: query.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }
}