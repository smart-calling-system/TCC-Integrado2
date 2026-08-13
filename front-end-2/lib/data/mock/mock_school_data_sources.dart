import '../../core/constants/app_constants.dart';
import '../../models/aluno.dart';
import '../../models/disciplina.dart';
import '../../models/horario.dart';
import '../../models/notificacao.dart';
import '../../models/presenca.dart';
import '../../models/turma.dart';
import 'mock_data.dart';

abstract class AlunoDataSource {
  Future<List<Aluno>> listar({String? busca, String? turma});
  Future<Aluno> criar({
    required String nome,
    required String ra,
    required String turma,
  });
  Future<Aluno> atualizar(Aluno aluno);
  Future<void> remover(String id);
  Future<bool> raJaExiste(String ra, {String? ignorandoId});
}

class MockAlunoDataSource implements AlunoDataSource {
  static final List<Aluno> _alunos = List.of(MockData.alunos);
  static int _proximoId = MockData.alunos.length + 1;

  @override
  Future<List<Aluno>> listar({String? busca, String? turma}) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    Iterable<Aluno> lista = _alunos;
    if (turma != null && turma.isNotEmpty) {
      lista = lista.where((a) => a.turma == turma);
    }
    if (busca != null && busca.trim().isNotEmpty) {
      final termo = busca.trim().toLowerCase();
      lista = lista.where(
        (a) => a.nome.toLowerCase().contains(termo) || a.ra.contains(termo),
      );
    }
    return lista.toList();
  }

  @override
  Future<Aluno> criar({
    required String nome,
    required String ra,
    required String turma,
  }) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final novo = Aluno(
      id: 'a${_proximoId++}',
      nome: nome,
      ra: ra,
      turma: turma,
    );
    _alunos.add(novo);
    return novo;
  }

  @override
  Future<Aluno> atualizar(Aluno aluno) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final indice = _alunos.indexWhere((a) => a.id == aluno.id);
    if (indice != -1) _alunos[indice] = aluno;
    return aluno;
  }

  @override
  Future<void> remover(String id) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    _alunos.removeWhere((a) => a.id == id);
  }

  @override
  Future<bool> raJaExiste(String ra, {String? ignorandoId}) async {
    return _alunos.any((a) => a.ra == ra && a.id != ignorandoId);
  }
}

abstract class TurmaDataSource {
  Future<List<Turma>> listar({String? busca});
  Future<List<String>> listarNomes();
  Future<Turma> criar({
    required String nome,
    required String serie,
    required TurnoTurma turno,
    required String sala,
  });
  Future<Turma> atualizar(Turma turma);
  Future<void> remover(String id);
}

class MockTurmaDataSource implements TurmaDataSource {
  static final List<Turma> _turmas = List.of(MockData.turmas);
  static int _proximoId = MockData.turmas.length + 1;

  @override
  Future<List<Turma>> listar({String? busca}) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    Iterable<Turma> lista = _turmas;
    if (busca != null && busca.trim().isNotEmpty) {
      final termo = busca.trim().toLowerCase();
      lista = lista.where(
        (t) =>
            t.nome.toLowerCase().contains(termo) ||
            t.serie.toLowerCase().contains(termo),
      );
    }
    return lista.toList();
  }

  @override
  Future<List<String>> listarNomes() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    return _turmas.map((t) => t.nome).toList();
  }

  @override
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

  @override
  Future<Turma> atualizar(Turma turma) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final indice = _turmas.indexWhere((t) => t.id == turma.id);
    if (indice != -1) _turmas[indice] = turma;
    return turma;
  }

  @override
  Future<void> remover(String id) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    _turmas.removeWhere((t) => t.id == id);
  }
}

abstract class DisciplinaDataSource {
  Future<List<Disciplina>> listar({String? busca});
  Future<Disciplina> criar({
    required String nome,
    required String professor,
    required int cargaHoraria,
  });
  Future<Disciplina> atualizar(Disciplina disciplina);
  Future<void> remover(String id);
}

class MockDisciplinaDataSource implements DisciplinaDataSource {
  static final List<Disciplina> _disciplinas = List.of(MockData.disciplinas);
  static int _proximoId = MockData.disciplinas.length + 1;

  @override
  Future<List<Disciplina>> listar({String? busca}) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    Iterable<Disciplina> lista = _disciplinas;
    if (busca != null && busca.trim().isNotEmpty) {
      final termo = busca.trim().toLowerCase();
      lista = lista.where(
        (d) =>
            d.nome.toLowerCase().contains(termo) ||
            d.professor.toLowerCase().contains(termo),
      );
    }
    return lista.toList();
  }

  @override
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

  @override
  Future<Disciplina> atualizar(Disciplina disciplina) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final indice = _disciplinas.indexWhere((d) => d.id == disciplina.id);
    if (indice != -1) _disciplinas[indice] = disciplina;
    return disciplina;
  }

  @override
  Future<void> remover(String id) async {
    await Future.delayed(AppConstants.mockLoadDelay);
    _disciplinas.removeWhere((d) => d.id == id);
  }
}

abstract class PresencaDataSource {
  Future<List<Presenca>> buscarHistorico();
}

class MockPresencaDataSource implements PresencaDataSource {
  @override
  Future<List<Presenca>> buscarHistorico() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    return MockData.historico();
  }
}

abstract class EscolaDataSource {
  Future<Horario> buscarProximaAula();
  Future<List<Notificacao>> listarNotificacoes();
}

class MockEscolaDataSource implements EscolaDataSource {
  @override
  Future<Horario> buscarProximaAula() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final hoje = DateTime.now().weekday;
    return MockData.horarios.firstWhere(
      (h) => h.diaSemana == hoje,
      orElse: () => MockData.horarios.first,
    );
  }

  @override
  Future<List<Notificacao>> listarNotificacoes() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    return MockData.notificacoes();
  }
}
