import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../repositories/auth_repository.dart';

/// Provider global de sessão do usuário.
///
/// Controla o estado de autenticação (fake) usado pelas rotas e pelo
/// menu lateral. A persistência real entre reinicializações do app ficará
/// a cargo de uma implementação futura (ex.: flutter_secure_storage)
/// quando o backend de autenticação existir.
///
/// TODO: Substituir dados mockados pela API quando o backend for integrado.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  Usuario? _usuario;

  Usuario? get usuario => _usuario;
  bool get estaAutenticado => _usuario != null;

  Future<void> login(String email, String senha) async {
    _usuario = await _repository.login(email, senha);
    notifyListeners();
  }

  Future<void> recuperarSenha(String email) =>
      _repository.recuperarSenha(email);

  Future<void> atualizarPerfil({
    required String nome,
    required String email,
  }) async {
    _usuario = await _repository.atualizarPerfil(nome: nome, email: email);
    notifyListeners();
  }

  Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) =>
      _repository.trocarSenha(senhaAtual: senhaAtual, novaSenha: novaSenha);

  Future<void> logout() async {
    await _repository.sair();
    _usuario = null;
    notifyListeners();
  }
}
