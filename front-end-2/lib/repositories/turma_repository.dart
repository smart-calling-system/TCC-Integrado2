import '../data/mock/mock_school_data_sources.dart';
import '../models/turma.dart';

class TurmaRepository {
  TurmaRepository({TurmaDataSource? dataSource})
    : _dataSource = dataSource ?? MockTurmaDataSource();

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
