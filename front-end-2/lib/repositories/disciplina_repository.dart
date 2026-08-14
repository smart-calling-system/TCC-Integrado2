// 👇 1. Adeus, dados falsos! Trazendo a conexão com a API real:
import '../data/api/api_disciplina_data_source.dart';
import '../data/disciplina_data_source.dart'; // Interface garantida
import '../models/disciplina.dart';

class DisciplinaRepository {
  DisciplinaRepository({DisciplinaDataSource? dataSource})
    // 👇 2. A MÁGICA FINALIZADA! Tudo conectado no Node.js!
    : _dataSource = dataSource ?? ApiDisciplinaDataSource();

  final DisciplinaDataSource _dataSource;

  Future<List<Disciplina>> listar({String? busca}) =>
      _dataSource.listar(busca: busca);

  Future<Disciplina> criar({
    required String nome,
    required String professor,
    required int cargaHoraria,
  }) => _dataSource.criar(
    nome: nome,
    professor: professor,
    cargaHoraria: cargaHoraria,
  );

  Future<Disciplina> atualizar(Disciplina disciplina) =>
      _dataSource.atualizar(disciplina);

  Future<void> remover(String id) => _dataSource.remover(id);
}