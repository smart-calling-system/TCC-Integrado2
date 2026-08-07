import '../models/sync_status.dart';

/// Repositório de Sincronização (camada de dados).
///
/// Toda a verificação é apenas visual/simulada; futuramente consultará a
/// conectividade real, o servidor (attendance-api) e o banco local SQLite.
class SyncRepository {
  /// Estado inicial fictício da sincronização.
  ///
  /// TODO: Substituir dados mockados pela API quando o backend for integrado.
  Future<SyncStatus> buscarStatus() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return SyncStatus(
      internet: EstadoConexao.conectado,
      servidor: EstadoConexao.conectado,
      bancoLocal: EstadoConexao.conectado,
      registrosPendentes: 7,
      ultimaSincronizacao:
          DateTime.now().subtract(const Duration(hours: 2, minutes: 14)),
    );
  }

  /// Simula o envio em lote dos registros pendentes ao servidor.
  ///
  /// TODO: Substituir dados mockados pela API quando o backend for integrado.
  Future<void> sincronizar() async {
    await Future.delayed(const Duration(milliseconds: 1800));
  }
}
