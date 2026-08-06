import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../repositories/auth_exception.dart';

/// Controller da tela "Esqueci minha senha".
class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({required AuthProvider authProvider})
      : _authProvider = authProvider;

  final AuthProvider _authProvider;

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _carregando = false;
  bool _enviado = false;
  String? _erro;

  bool get carregando => _carregando;
  bool get enviado => _enviado;
  String? get erro => _erro;

  String? validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o e-mail';
    if (!valor.contains('@') || !valor.contains('.')) {
      return 'E-mail inválido';
    }
    return null;
  }

  Future<void> enviar() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _authProvider.recuperarSenha(emailController.text.trim());
      _enviado = true;
    } on AuthException catch (e) {
      _erro = e.mensagem;
    } catch (_) {
      _erro = 'Não foi possível concluir a solicitação.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
