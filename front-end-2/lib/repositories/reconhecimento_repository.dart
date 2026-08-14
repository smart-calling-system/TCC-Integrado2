import '../data/local/sync_queue_data_source.dart';
import '../data/local/sync_queue_factory.dart';
import '../data/api/api_recognition_data_source.dart';
// O import fantasma que estava aqui em cima foi apagado!
import '../models/aluno.dart';
import '../models/sync_queue_item.dart';

class ReconhecimentoRepository {
  ReconhecimentoRepository({
    // 👇 1. Trocamos o tipo aqui
    ApiRecognitionDataSource? recognitionDataSource,
    SyncQueueDataSource? syncQueueDataSource,
  }) : _recognitionDataSource =
           recognitionDataSource ?? ApiRecognitionDataSource(),
       _syncQueueDataSource =
           syncQueueDataSource ?? createDefaultSyncQueueDataSource();

  // 👇 2. Trocamos o tipo aqui na variável
  final ApiRecognitionDataSource _recognitionDataSource;
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
              'Registro local criado offline via app. turmaId será resolvido na sincronização.',
        },
      ),
    );
    return aluno;
  }
}