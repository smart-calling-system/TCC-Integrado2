import '../data/mock/mock_school_data_sources.dart';
import '../models/aluno.dart';

class AlunoRepository {
  AlunoRepository({AlunoDataSource? dataSource})
    : _dataSource = dataSource ?? MockAlunoDataSource();

  final AlunoDataSource _dataSource;

  Future<List<Aluno>> listar({String? busca, String? turma}) =>
      _dataSource.listar(busca: busca, turma: turma);

  Future<Aluno> criar({
    required String nome,
    required String ra,
    required String turma,
  }) => _dataSource.criar(nome: nome, ra: ra, turma: turma);

  Future<Aluno> atualizar(Aluno aluno) => _dataSource.atualizar(aluno);

  Future<void> remover(String id) => _dataSource.remover(id);

  Future<bool> raJaExiste(String ra, {String? ignorandoId}) =>
      _dataSource.raJaExiste(ra, ignorandoId: ignorandoId);
}
