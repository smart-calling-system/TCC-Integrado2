import '../core/constants/app_constants.dart';
import '../models/disciplina.dart';
import 'mock_data.dart';

/// Repositório de Disciplinas (camada de dados).
///
/// TODO: Substituir dados mockados pela API quando o backend for integrado.
class DisciplinaRepository {
  static final List<Disciplina> _disciplinas = List.of(MockData.disciplinas);
  static int _proximoId = MockData.disciplinas.length + 1;

  Future<List<Disciplina>> listar({String? busca}) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    Iterable<Disciplina> lista = _disciplinas;
    if (busca != null && busca.trim().isNotEmpty) {
      final termo = busca.trim().toLowerCase();
      lista = lista.where((d) =>
          d.nome.toLowerCase().contains(termo) ||
          d.professor.toLowerCase().contains(termo));
    }
    return lista.toList();
  }

  Future<Disciplina> criar({
    required String nome,
    required String professor,
    required int cargaHoraria,
  }) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final nova = Disciplina(
      id: 'disc${_proximoId++}',
      nome: nome,
      professor: professor,
      cargaHoraria: cargaHoraria,
    );
    _disciplinas.add(nova);
    return nova;
  }

  Future<Disciplina> atualizar(Disciplina disciplina) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final indice = _disciplinas.indexWhere((d) => d.id == disciplina.id);
    if (indice != -1) _disciplinas[indice] = disciplina;
    return disciplina;
  }

  Future<void> remover(String id) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    _disciplinas.removeWhere((d) => d.id == id);
  }
}
