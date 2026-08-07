import '../core/constants/app_constants.dart';
import '../models/usuario.dart';
import 'auth_exception.dart';
import 'mock_data.dart';

/// Repositório de Autenticação (camada de dados).
///
/// Simula um servidor de autenticação: valida as credenciais de
/// demonstração, "recupera senha" e atualiza o perfil/senha do usuário.
/// Nenhum dado sai do dispositivo — tudo em memória.
///
/// TODO: Substituir dados mockados pela API quando o backend for integrado.
class AuthRepository {
  /// Credenciais de demonstração exibidas na tela de login.
  static const String emailDemo = 'professor@escola.com';
  static const String senhaDemo = '123456';

  Usuario? _usuarioLogado;
  String _senhaAtual = senhaDemo;

  /// Autentica o usuário. Lança [AuthException] em caso de erro.
  Future<Usuario> login(String email, String senha) async {
    await Future.delayed(AppConstants.mockLoadDelay);

    final emailNormalizado = email.trim().toLowerCase();
    if (emailNormalizado != emailDemo || senha != _senhaAtual) {
      throw const AuthException('E-mail ou senha inválidos.');
    }

    _usuarioLogado = MockData.usuarioPadrao;
    return _usuarioLogado!;
  }

  /// Simula o envio de um e-mail de recuperação de senha.
  Future<void> recuperarSenha(String email) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    if (!email.contains('@') || !email.contains('.')) {
      throw const AuthException('Informe um e-mail válido.');
    }
    // Nenhum e-mail é enviado de verdade — fluxo apenas visual.
  }

  /// Atualiza nome/e-mail do usuário autenticado.
  Future<Usuario> atualizarPerfil({
    required String nome,
    required String email,
  }) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final atual = _usuarioLogado ?? MockData.usuarioPadrao;
    _usuarioLogado = atual.copyWith(nome: nome, email: email);
    return _usuarioLogado!;
  }

  /// Troca a senha (fake) validando a senha atual informada.
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

  Future<void> sair() async {
    _usuarioLogado = null;
  }
}
