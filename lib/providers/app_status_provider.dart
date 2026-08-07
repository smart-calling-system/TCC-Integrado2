import 'package:flutter/material.dart';

/// Provider de status de conexão do tablet (simulado).
///
/// Permite demonstrar visualmente os estados Online/Offline exigidos na
/// tela inicial. Futuramente será alimentado por um monitor real de
/// conectividade (ex.: connectivity_plus).
class AppStatusProvider extends ChangeNotifier {
  bool _online = true;

  bool get online => _online;

  /// Alterna o estado apenas para fins de demonstração visual.
  ///
  /// TODO: Substituir dados mockados pela API quando o backend for integrado.
  void alternarConexao() {
    _online = !_online;
    notifyListeners();
  }
}
