import '../../core/network/api_client.dart';
import '../../models/usuario.dart';

// 👇 Trazemos o AuthResult de volta à vida, agora no mundo real
class AuthResult {
  final Usuario usuario;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthResult({
    required this.usuario,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
}

// 👇 Removemos o "implements" para não depender mais de interfaces fantasmas
class ApiAuthDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResult> login(String email, String senha) async {
    final res = await _apiClient.post('/auth/login', body: {'email': email, 'senha': senha});
    final data = res['data'];
    return AuthResult(
      usuario: Usuario.fromJson(data['usuario']),
      accessToken: data['token'],
      refreshToken: data['refreshToken'] ?? '',
      expiresAt: DateTime.parse(data['expiresAt'] ?? DateTime.now().add(const Duration(hours: 8)).toIso8601String()),
    );
  }

  Future<void> recuperarSenha(String email) async => _apiClient.post('/auth/recuperar-senha', body: {'email': email});

  Future<Usuario> atualizarPerfil({required String nome, required String email}) async {
    final res = await _apiClient.patch('/usuarios/me', body: {'nome': nome, 'email': email});
    return Usuario.fromJson(res['data']);
  }

  Future<void> trocarSenha({required String senhaAtual, required String novaSenha}) async {
    await _apiClient.post('/auth/trocar-senha', body: {'senhaAtual': senhaAtual, 'novaSenha': novaSenha});
  }

  Future<void> logout() async => _apiClient.post('/auth/logout');
}