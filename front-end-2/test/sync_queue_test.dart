import 'package:flutter_test/flutter_test.dart';
import 'package:tcc_face/data/local/memory_sync_queue_data_source.dart';
import 'package:tcc_face/models/sync_queue_item.dart';
import 'package:tcc_face/repositories/sync_repository.dart';

void main() {
  test('fila offline contabiliza pendencias reais', () async {
    final queue = MemorySyncQueueDataSource();
    final repository = SyncRepository(queueDataSource: queue);

    await queue.enqueue(
      SyncQueueItem(
        localId: 'local-1',
        operation: 'registrar_presenca_facial',
        payload: {'alunoId': 'a1', 'turmaNome': '3 DS'},
        createdAt: DateTime(2026, 8, 9, 7, 10),
      ),
    );

    final status = await repository.buscarStatus();

    expect(status.registrosPendentes, 1);
    expect((await repository.listarPendentes()).single.localId, 'local-1');
  });
}
