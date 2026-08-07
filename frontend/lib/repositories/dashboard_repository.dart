import '../core/constants/app_constants.dart';
import '../models/presenca.dart';
import 'aluno_repository.dart';
import 'mock_data.dart';
import 'turma_repository.dart';

/// Resumo de indicadores exibidos no Dashboard.
class ResumoDashboard {
  final int totalAlunos;
  final int totalTurmas;
  final int presentesHoje;
  final int faltasHoje;
  final int atrasadosHoje;
  final double frequenciaMedia;

  /// Presenças dos últimos 7 dias (para o gráfico de barras mockado),
  /// do mais antigo para o mais recente.
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

/// Repositório do Dashboard (camada de dados).
///
/// Agrega dados de outros repositórios/mocks para montar os indicadores
/// da tela inicial pós-login.
///
/// TODO: Substituir dados mockados pela API quando o backend for integrado.
class DashboardRepository {
  final AlunoRepository _alunoRepository = AlunoRepository();
  final TurmaRepository _turmaRepository = TurmaRepository();

  Future<ResumoDashboard> buscarResumo() async {
    await Future.delayed(AppConstants.mockLoadDelay);

    final alunos = await _alunoRepository.listar();
    final turmas = await _turmaRepository.listar();
    final historico = MockData.historico();
    final hoje = DateTime.now();

    bool mesmoDia(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final registrosHoje =
        historico.where((p) => mesmoDia(p.data, hoje)).toList();

    final presentes = registrosHoje
        .where((p) =>
            p.status == StatusPresenca.presente ||
            p.status == StatusPresenca.atrasado ||
            p.status == StatusPresenca.saidaAntecipada)
        .length;
    final faltas = registrosHoje
        .where((p) => p.status == StatusPresenca.ausente)
        .length;
    final atrasados = registrosHoje
        .where((p) => p.status == StatusPresenca.atrasado)
        .length;

    final totalConsiderado = registrosHoje.isEmpty ? 1 : registrosHoje.length;
    final frequencia = (presentes / totalConsiderado) * 100;

    // Série mockada dos últimos 7 dias (determinística, baseada na
    // quantidade de alunos, apenas para desenhar o gráfico).
    final base = alunos.isEmpty ? 6 : alunos.length;
    final serie = List<int>.generate(7, (i) {
      final variacao = [2, -1, 3, 0, -2, 4, 1][i % 7];
      final valor = base - variacao;
      return valor < 0 ? 0 : valor;
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
