import '../models/presenca.dart';
import 'aluno_repository.dart';
import 'presenca_repository.dart';
import 'turma_repository.dart';

class ResumoDashboard {
  final int totalAlunos;
  final int totalTurmas;
  final int presentesHoje;
  final int faltasHoje;
  final int atrasadosHoje;
  final double frequenciaMedia;
  final List<int> presencasUltimos7Dias;

  const ResumoDashboard({
    required this.totalAlunos,
    required this.totalTurmas,
    required this.presentesHoje,
    required this.faltasHoje,
    required this.atrasadosHoje,
    required this.frequenciaMedia,
    required this.presencasUltimos7Dias,
  });
}

class DashboardRepository {
  DashboardRepository({
    AlunoRepository? alunoRepository,
    TurmaRepository? turmaRepository,
    PresencaRepository? presencaRepository,
  }) : _alunoRepository = alunoRepository ?? AlunoRepository(),
       _turmaRepository = turmaRepository ?? TurmaRepository(),
       _presencaRepository = presencaRepository ?? PresencaRepository();

  final AlunoRepository _alunoRepository;
  final TurmaRepository _turmaRepository;
  final PresencaRepository _presencaRepository;

  Future<ResumoDashboard> buscarResumo() async {
    final alunos = await _alunoRepository.listar();
    final turmas = await _turmaRepository.listar();
    final historico = await _presencaRepository.buscarHistorico();
    final hoje = DateTime.now();

    bool mesmoDia(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final registrosHoje = historico
        .where((p) => mesmoDia(p.data, hoje))
        .toList();

    final presentes = registrosHoje
        .where(
          (p) =>
              p.status == StatusPresenca.presente ||
              p.status == StatusPresenca.atrasado ||
              p.status == StatusPresenca.saidaAntecipada,
        )
        .length;
    final faltas = registrosHoje
        .where((p) => p.status == StatusPresenca.ausente)
        .length;
    final atrasados = registrosHoje
        .where((p) => p.status == StatusPresenca.atrasado)
        .length;

    final totalConsiderado = registrosHoje.isEmpty ? 1 : registrosHoje.length;
    final frequencia = (presentes / totalConsiderado) * 100;

    final serie = List<int>.generate(7, (i) {
      final dia = hoje.subtract(Duration(days: 6 - i));
      return historico
          .where(
            (p) => mesmoDia(p.data, dia) && p.status != StatusPresenca.ausente,
          )
          .length;
    });

    return ResumoDashboard(
      totalAlunos: alunos.length,
      totalTurmas: turmas.length,
      presentesHoje: presentes,
      faltasHoje: faltas,
      atrasadosHoje: atrasados,
      frequenciaMedia: frequencia.clamp(0, 100),
      presencasUltimos7Dias: serie,
    );
  }
}
