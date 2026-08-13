import '../core/errors/app_exception.dart';
import '../core/network/api_config.dart';
import '../data/local/sync_queue_data_source.dart';
import '../data/local/sync_queue_factory.dart';
import '../models/sync_queue_item.dart';
import '../models/sync_status.dart';

class SyncUnavailableException extends AppException {
  const SyncUnavailableException()
    : super(
        'Servidor nao conectado nesta versao. Registros permanecem na fila local.',
        type: AppExceptionType.serverUnavailable,
      );
}

class SyncRepository {
  SyncRepository({SyncQueueDataSource? queueDataSource})
    : _queueDataSource = queueDataSource ?? createDefaultSyncQueueDataSource();

  final SyncQueueDataSource _queueDataSource;

  Future<SyncStatus> buscarStatus() async {
    final pending = await _queueDataSource.countPending();
    final lastSync = await _queueDataSource.lastSuccessfulSync();
    return SyncStatus(
      internet: EstadoConexao.conectado,
      servidor: ApiConfig.apiIntegrationEnabled
          ? EstadoConexao.verificando
          : EstadoConexao.desconectado,
      bancoLocal: EstadoConexao.conectado,
      registrosPendentes: pending,
      ultimaSincronizacao: lastSync,
    );
  }

  Future<List<SyncQueueItem>> listarPendentes() =>
      _queueDataSource.listPending();

  Future<void> sincronizar() async {
    final pending = await _queueDataSource.listPending();
    if (pending.isEmpty) return;

    final ids = pending.map((item) => item.localId).toList();
    await _queueDataSource.markSyncing(ids);

    if (!ApiConfig.apiIntegrationEnabled) {
      await _queueDataSource.markError(
        ids,
        'Servidor nao conectado nesta versao.',
      );
      throw const SyncUnavailableException();
    }

    await _queueDataSource.markError(
      ids,
      'ApiSyncDataSource ainda nao implementado.',
    );
    throw const SyncUnavailableException();
  }
}
