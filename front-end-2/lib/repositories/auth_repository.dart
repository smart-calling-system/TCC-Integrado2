import '../core/session/session_manager.dart';
import '../core/session/session_state.dart';
import '../data/mock/mock_auth_data_source.dart';
import '../models/usuario.dart';

class AuthRepository {
  AuthRepository({AuthDataSource? dataSource, SessionManager? sessionManager})
    : _dataSource = dataSource ?? MockAuthDataSource(),
      _sessionManager = sessionManager ?? SessionManager();

  final AuthDataSource _dataSource;
  final SessionManager _sessionManager;

  Future<Usuario> login(String email, String senha) async {
    final result = await _dataSource.login(email, senha);
    await _sessionManager.save(
      SessionState(
        usuario: result.usuario,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiresAt: result.expiresAt,
      ),
    );
    return result.usuario;
  }

  Future<void> recuperarSenha(String email) =>
      _dataSource.recuperarSenha(email);

  Future<Usuario> atualizarPerfil({
    required String nome,
    required String email,
  }) async {
    final usuario = await _dataSource.atualizarPerfil(nome: nome, email: email);
    final state = _sessionManager.state;
    await _sessionManager.save(
      SessionState(
        usuario: usuario,
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
        expiresAt: state.expiresAt,
      ),
    );
    return usuario;
  }

  Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) => _dataSource.trocarSenha(senhaAtual: senhaAtual, novaSenha: novaSenha);

  Future<void> sair() async {
    await _dataSource.logout();
    await _sessionManager.clear();
  }
}
