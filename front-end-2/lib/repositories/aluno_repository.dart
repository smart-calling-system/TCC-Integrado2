// 👇 1. Apagamos o import do Mock e trazemos o da API Real
import '../data/api/api_aluno_data_source.dart';
import '../data/aluno_data_source.dart'; // Adicionado para garantir o reconhecimento da interface
import '../models/aluno.dart';

class AlunoRepository {
  AlunoRepository({AlunoDataSource? dataSource})
    // 👇 2. AQUI ACONTECE A MÁGICA! Conectando o app no seu Backend!
    : _dataSource = dataSource ?? ApiAlunoDataSource();

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