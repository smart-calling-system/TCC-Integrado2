// 👇 1. Limpando os rastros do Mock e importando a API verdadeira
import '../data/api/api_turma_data_source.dart';
import '../data/turma_data_source.dart'; // Interface garantida
import '../models/turma.dart';

class TurmaRepository {
  TurmaRepository({TurmaDataSource? dataSource})
    // 👇 2. A MÁGICA CONTINUA! App 100% plugado no Backend!
    : _dataSource = dataSource ?? ApiTurmaDataSource();

  final TurmaDataSource _dataSource;

  Future<List<Turma>> listar({String? busca}) =>
      _dataSource.listar(busca: busca);

  Future<List<String>> listarNomes() => _dataSource.listarNomes();

  Future<Turma> criar({
    required String nome,
    required String serie,
    required TurnoTurma turno,
    required String sala,
  }) => _dataSource.criar(nome: nome, serie: serie, turno: turno, sala: sala);

  Future<Turma> atualizar(Turma turma) => _dataSource.atualizar(turma);

  Future<void> remover(String id) => _dataSource.remover(id);
}