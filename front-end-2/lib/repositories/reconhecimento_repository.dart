import '../data/local/sync_queue_data_source.dart';
import '../data/local/sync_queue_factory.dart';
// 👇 1. Expulsando o Mock e trazendo a interface e a API real
import '../data/api/api_recognition_data_source.dart';
import '../data/recognition_data_source.dart'; 
import '../models/aluno.dart';
import '../models/sync_queue_item.dart';

class ReconhecimentoRepository {
  ReconhecimentoRepository({
    RecognitionDataSource? recognitionDataSource,
    SyncQueueDataSource? syncQueueDataSource,
  }) : _recognitionDataSource =
           // 👇 2. A MÁGICA SUPREMA! Conectado com a IA e o Backend!
           recognitionDataSource ?? ApiRecognitionDataSource(),
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
          // 👇 3. Mensagem atualizada: adeus modo mock, olá produção!
          'observacao':
              'Registro local criado offline via app. turmaId será resolvido na sincronização.',
        },
      ),
    );
    return aluno;
  }
}