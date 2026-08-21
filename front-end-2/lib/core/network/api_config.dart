class ApiConfig {
  ApiConfig._();

  // Habilitado por padrão para permitir as requisições
  static const bool apiIntegrationEnabled = bool.fromEnvironment(
    'API_INTEGRATION_ENABLED',
    defaultValue: true,
  );

  // ==========================================================
  // 👇 QUARTEL GENERAL DO IP: NO DIA DO TCC, MUDE SÓ ESTA LINHA!
  // ==========================================================
  static const String ipServidor = '10.133.101.30';

  // Base URLs das duas APIs
  static const String nodeBaseUrl = 'http://$ipServidor:3000';
  static const String pythonBaseUrl = 'http://$ipServidor:5000';

  // Prefixo oficial da API do Node.js
  static const String apiPrefix = '/api/v1';

  // ==========================================================
  // 1. MONTADOR DE ROTAS PARA O NODE.JS (Usa a porta 3000 e o /api/v1)
  // Exemplo de uso: ApiConfig.uri('/auth/login')
  // ==========================================================
  static Uri uri(String endpoint, [Map<String, dynamic>? query]) {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
        
    // Montagem correta: http://10.133.101.30:3000 + /api/v1 + /endpoint
    final montagem = Uri.parse('$nodeBaseUrl$apiPrefix$normalizedEndpoint');

    if (query == null || query.isEmpty) return montagem;

    return montagem.replace(
      queryParameters: query.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }

  // ==========================================================
  // 2. MONTADOR DE ROTAS PARA O PYTHON IA (Usa porta 5000, sem prefixo)
  // Exemplo de uso: ApiConfig.pythonUri('/reconhecer')
  // ==========================================================
  static Uri pythonUri(String endpoint, [Map<String, dynamic>? query]) {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
        
    // Montagem correta: http://10.133.101.30:5000 + /endpoint
    final montagem = Uri.parse('$pythonBaseUrl$normalizedEndpoint');

    if (query == null || query.isEmpty) return montagem;

    return montagem.replace(
      queryParameters: query.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }
}