import '../core/constants/app_constants.dart';
import '../models/turma.dart';
import 'mock_data.dart';

/// Repositório de Turmas (camada de dados).
///
/// TODO: Substituir dados mockados pela API quando o backend for integrado.
class TurmaRepository {
  static final List<Turma> _turmas = List.of(MockData.turmas);
  static int _proximoId = MockData.turmas.length + 1;

  Future<List<Turma>> listar({String? busca}) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    Iterable<Turma> lista = _turmas;
    if (busca != null && busca.trim().isNotEmpty) {
      final termo = busca.trim().toLowerCase();
      lista = lista.where((t) =>
          t.nome.toLowerCase().contains(termo) ||
          t.serie.toLowerCase().contains(termo));
    }
    return lista.toList();
  }

  /// Lista simples de nomes de turma, usada em seletores (formulário de
  /// Aluno, filtros, etc.).
  Future<List<String>> listarNomes() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    return _turmas.map((t) => t.nome).toList();
  }

  Future<Turma> criar({
    required String nome,
    required String serie,
    required TurnoTurma turno,
    required String sala,
  }) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final nova = Turma(
      id: 'turma${_proximoId++}',
      nome: nome,
      serie: serie,
      turno: turno,
      sala: sala,
    );
    _turmas.add(nova);
    return nova;
  }

  Future<Turma> atualizar(Turma turma) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final indice = _turmas.indexWhere((t) => t.id == turma.id);
    if (indice != -1) _turmas[indice] = turma;
    return turma;
  }

  Future<void> remover(String id) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    _turmas.removeWhere((t) => t.id == id);
  }
}
