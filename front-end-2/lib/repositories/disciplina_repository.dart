import '../data/mock/mock_school_data_sources.dart';
import '../models/disciplina.dart';

class DisciplinaRepository {
  DisciplinaRepository({DisciplinaDataSource? dataSource})
    : _dataSource = dataSource ?? MockDisciplinaDataSource();

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
