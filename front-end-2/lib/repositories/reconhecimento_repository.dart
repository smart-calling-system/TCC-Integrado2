import '../data/local/sync_queue_data_source.dart';
import '../data/local/sync_queue_factory.dart';
import '../data/mock/mock_recognition_data_source.dart';
import '../models/aluno.dart';
import '../models/sync_queue_item.dart';

class ReconhecimentoRepository {
  ReconhecimentoRepository({
    RecognitionDataSource? recognitionDataSource,
    SyncQueueDataSource? syncQueueDataSource,
  }) : _recognitionDataSource =
           recognitionDataSource ?? MockRecognitionDataSource(),
       _syncQueueDataSource =
           syncQueueDataSource ?? createDefaultSyncQueueDataSource();

  final RecognitionDataSource _recognitionDataSource;
  final SyncQueueDataSource _syncQueueDataSource;

  Future<Aluno> reconhecerAluno() async {
    final aluno = await _recognitionDataSource.reconhecerAluno();
    final now = DateTime.now();
    await _syncQueueDataSource.enqueue(
      SyncQueueItem(
        localId: 'presence-${now.microsecondsSinceEpoch}-${aluno.id}',
        operation: 'registrar_presenca_facial',
        createdAt: now,
        payload: {
          'alunoId': aluno.id,
          'turmaNome': aluno.turma,
          'status': 'PRESENTE',
          'origem': 'FACIAL',
          'dataHoraLocal': now.toIso8601String(),
          'observacao':
              'Registro local criado em modo mock. turmaId sera resolvido na integracao.',
        },
      ),
    );
    return aluno;
  }
}
