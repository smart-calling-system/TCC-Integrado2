import '../../core/constants/app_constants.dart';
import '../../models/usuario.dart';
import '../../repositories/auth_exception.dart';
import 'mock_data.dart';

class MockAuthResult {
  final Usuario usuario;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const MockAuthResult({
    required this.usuario,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
}

abstract class AuthDataSource {
  Future<MockAuthResult> login(String email, String senha);
  Future<void> recuperarSenha(String email);
  Future<Usuario> atualizarPerfil({
    required String nome,
    required String email,
  });
  Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  });
  Future<void> logout();
}

class MockAuthDataSource implements AuthDataSource {
  String _senhaAtual = MockData.demoPassword;
  Usuario _usuario = MockData.usuarioPadrao;

  @override
  Future<MockAuthResult> login(String email, String senha) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final emailNormalizado = email.trim().toLowerCase();
    if (emailNormalizado != MockData.demoEmail || senha != _senhaAtual) {
      throw const AuthException('E-mail ou senha invalidos.');
    }

    return MockAuthResult(
      usuario: _usuario,
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
    );
  }

  @override
  Future<void> recuperarSenha(String email) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    if (!email.contains('@') || !email.contains('.')) {
      throw const AuthException('Informe um e-mail valido.');
    }
  }

  @override
  Future<Usuario> atualizarPerfil({
    required String nome,
    required String email,
  }) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    _usuario = _usuario.copyWith(nome: nome, email: email);
    return _usuario;
  }

  @override
  Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    if (senhaAtual != _senhaAtual) {
      throw const AuthException('Senha atual incorreta.');
    }
    if (novaSenha.length < 6) {
      throw const AuthException('A nova senha deve ter ao menos 6 caracteres.');
    }
    _senhaAtual = novaSenha;
  }

  @override
  Future<void> logout() async {}
}
