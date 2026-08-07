import 'package:flutter/material.dart';

import '../models/sync_status.dart';
import '../repositories/sync_repository.dart';

/// Controller da tela de Sincronização.
///
/// Carrega o status fictício e simula, etapa por etapa, a verificação de
/// Internet, Servidor e Banco local durante a sincronização.
class SyncController extends ChangeNotifier {
  SyncController({SyncRepository? repository})
      : _repository = repository ?? SyncRepository();

  final SyncRepository _repository;

  bool _carregando = true;
  bool _sincronizando = false;
  SyncStatus? _status;

  bool get carregando => _carregando;
  bool get sincronizando => _sincronizando;
  SyncStatus? get status => _status;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _status = await _repository.buscarStatus();
    _carregando = false;
    notifyListeners();
  }

  /// Executa a sincronização simulada, atualizando os indicadores em etapas
  /// para dar retorno visual ao usuário.
  Future<void> sincronizar() async {
    if (_status == null || _sincronizando) return;
    _sincronizando = true;

    _status = _status!.copyWith(
      internet: EstadoConexao.verificando,
      servidor: EstadoConexao.verificando,
      bancoLocal: EstadoConexao.verificando,
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _status = _status!.copyWith(internet: EstadoConexao.conectado);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _status = _status!.copyWith(servidor: EstadoConexao.conectado);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _status = _status!.copyWith(bancoLocal: EstadoConexao.conectado);
    notifyListeners();

    await _repository.sincronizar();

    _status = _status!.copyWith(
      registrosPendentes: 0,
      ultimaSincronizacao: DateTime.now(),
    );
    _sincronizando = false;
    notifyListeners();
  }
}
