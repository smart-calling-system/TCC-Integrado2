import '../core/constants/app_constants.dart';
import '../models/aluno.dart';
import 'mock_data.dart';

/// Repositório de Alunos (camada de dados).
///
/// Mantém uma cópia mutável em memória dos alunos mockados, permitindo
/// simular o CRUD completo (criar, listar, atualizar, remover) enquanto o
/// app estiver aberto. A interface pública (assinaturas dos métodos) é a
/// mesma que será usada quando a API real existir.
///
/// TODO: Substituir dados mockados pela API quando o backend for integrado.
class AlunoRepository {
  // `static` para que a lista sobreviva entre telas (mesma sessão do app),
  // simulando um "banco" em memória compartilhado.
  static final List<Aluno> _alunos = List.of(MockData.alunos);
  static int _proximoId = MockData.alunos.length + 1;

  Future<List<Aluno>> listar({String? busca, String? turma}) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    Iterable<Aluno> lista = _alunos;
    if (turma != null && turma.isNotEmpty) {
      lista = lista.where((a) => a.turma == turma);
    }
    if (busca != null && busca.trim().isNotEmpty) {
      final termo = busca.trim().toLowerCase();
      lista = lista.where((a) =>
          a.nome.toLowerCase().contains(termo) || a.ra.contains(termo));
    }
    return lista.toList();
  }

  Future<Aluno> criar({
    required String nome,
    required String ra,
    required String turma,
  }) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final novo = Aluno(id: 'a${_proximoId++}', nome: nome, ra: ra, turma: turma);
    _alunos.add(novo);
    return novo;
  }

  Future<Aluno> atualizar(Aluno aluno) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final indice = _alunos.indexWhere((a) => a.id == aluno.id);
    if (indice != -1) _alunos[indice] = aluno;
    return aluno;
  }

  Future<void> remover(String id) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    _alunos.removeWhere((a) => a.id == id);
  }

  /// Verifica se já existe outro aluno com o mesmo RA (validação de
  /// unicidade usada no formulário de cadastro/edição).
  Future<bool> raJaExiste(String ra, {String? ignorandoId}) async {
    return _alunos.any((a) => a.ra == ra && a.id != ignorandoId);
  }
}
