import '../models/aluno.dart';
import '../models/disciplina.dart';
import '../models/horario.dart';
import '../models/notificacao.dart';
import '../models/presenca.dart';
import '../models/turma.dart';
import '../models/usuario.dart';

/// Fonte única de dados fictícios do aplicativo.
///
/// TODO: Substituir dados mockados pela API quando o backend for integrado.
class MockData {
  MockData._();

  /// Usuário autenticado de demonstração.
  static const Usuario usuarioPadrao = Usuario(
    id: 'u1',
    nome: 'Fernanda Dias',
    email: 'professor@escola.com',
    cargo: CargoUsuario.coordenador,
  );

  static const List<Turma> turmas = [
    Turma(
      id: 't1',
      nome: '1º DS',
      serie: '1º ano — Ensino Médio Técnico',
      turno: TurnoTurma.manha,
      sala: 'Sala 08',
      quantidadeAlunos: 2,
    ),
    Turma(
      id: 't2',
      nome: '2º DS',
      serie: '2º ano — Ensino Médio Técnico',
      turno: TurnoTurma.manha,
      sala: 'Sala 10',
      quantidadeAlunos: 2,
    ),
    Turma(
      id: 't3',
      nome: '3º DS',
      serie: '3º ano — Ensino Médio Técnico',
      turno: TurnoTurma.manha,
      sala: 'Lab 02',
      quantidadeAlunos: 4,
    ),
  ];

  static const List<Disciplina> disciplinas = [
    Disciplina(
      id: 'd1',
      nome: 'Desenvolvimento de Sistemas',
      professor: 'Prof. Carlos Mendes',
      cargaHoraria: 80,
      turmasVinculadas: ['t3'],
    ),
    Disciplina(
      id: 'd2',
      nome: 'Banco de Dados',
      professor: 'Profa. Juliana Reis',
      cargaHoraria: 60,
      turmasVinculadas: ['t2', 't3'],
    ),
    Disciplina(
      id: 'd3',
      nome: 'Programação Mobile',
      professor: 'Prof. Rafael Lima',
      cargaHoraria: 60,
      turmasVinculadas: ['t3'],
    ),
    Disciplina(
      id: 'd4',
      nome: 'Redes de Computadores',
      professor: 'Prof. André Souza',
      cargaHoraria: 40,
      turmasVinculadas: ['t1', 't2'],
    ),
    Disciplina(
      id: 'd5',
      nome: 'Projeto de TCC',
      professor: 'Profa. Fernanda Dias',
      cargaHoraria: 40,
      turmasVinculadas: ['t3'],
    ),
  ];

  /// Aluno padrão exibido na tela de sucesso do reconhecimento.
  static const Aluno alunoPadrao = Aluno(
    id: '1',
    nome: 'João da Silva',
    ra: '202600123',
    turma: '3º DS',
  );

  static const List<Aluno> alunos = [
    alunoPadrao,
    Aluno(id: '2', nome: 'Maria Oliveira', ra: '202600124', turma: '3º DS'),
    Aluno(id: '3', nome: 'Pedro Santos', ra: '202600125', turma: '3º DS'),
    Aluno(id: '4', nome: 'Ana Costa', ra: '202600126', turma: '3º DS'),
    Aluno(id: '5', nome: 'Lucas Pereira', ra: '202600127', turma: '2º DS'),
    Aluno(id: '6', nome: 'Beatriz Almeida', ra: '202600128', turma: '2º DS'),
    Aluno(id: '7', nome: 'Gabriel Rocha', ra: '202600129', turma: '1º DS'),
    Aluno(id: '8', nome: 'Larissa Fernandes', ra: '202600130', turma: '1º DS'),
  ];

  /// Histórico fictício de presenças (dias e horários relativos a hoje).
  static List<Presenca> historico() {
    final hoje = DateTime.now();
    DateTime dia(int diasAtras) =>
        DateTime(hoje.year, hoje.month, hoje.day - diasAtras);
    DateTime hm(DateTime d, int h, int m) =>
        DateTime(d.year, d.month, d.day, h, m);

    final d0 = dia(0);
    final d1 = dia(1);
    final d2 = dia(2);

    return [
      Presenca(
        id: 'p1',
        aluno: alunos[0],
        data: d0,
        entrada: hm(d0, 7, 12),
        status: StatusPresenca.presente,
      ),
      Presenca(
        id: 'p2',
        aluno: alunos[1],
        data: d0,
        entrada: hm(d0, 7, 05),
        status: StatusPresenca.presente,
      ),
      Presenca(
        id: 'p3',
        aluno: alunos[2],
        data: d0,
        entrada: hm(d0, 7, 43),
        status: StatusPresenca.atrasado,
      ),
      Presenca(
        id: 'p4',
        aluno: alunos[3],
        data: d0,
        status: StatusPresenca.ausente,
      ),
      Presenca(
        id: 'p5',
        aluno: alunos[4],
        data: d1,
        entrada: hm(d1, 7, 02),
        saida: hm(d1, 11, 20),
        status: StatusPresenca.saidaAntecipada,
      ),
      Presenca(
        id: 'p6',
        aluno: alunos[5],
        data: d1,
        entrada: hm(d1, 7, 10),
        saida: hm(d1, 12, 30),
        status: StatusPresenca.presente,
      ),
      Presenca(
        id: 'p7',
        aluno: alunos[6],
        data: d2,
        entrada: hm(d2, 7, 36),
        saida: hm(d2, 12, 30),
        status: StatusPresenca.atrasado,
      ),
      Presenca(
        id: 'p8',
        aluno: alunos[7],
        data: d2,
        entrada: hm(d2, 7, 08),
        saida: hm(d2, 12, 30),
        status: StatusPresenca.presente,
      ),
      Presenca(
        id: 'p9',
        aluno: alunos[0],
        data: d2,
        entrada: hm(d2, 7, 15),
        saida: hm(d2, 12, 30),
        status: StatusPresenca.presente,
      ),
      Presenca(
        id: 'p10',
        aluno: alunos[2],
        data: d2,
        status: StatusPresenca.ausente,
      ),
    ];
  }

  /// Grade horária fictícia da turma 3º DS.
  static const List<Horario> horarios = [
    Horario(
      disciplina: 'Desenvolvimento de Sistemas',
      professor: 'Prof. Carlos Mendes',
      sala: 'Lab 02',
      diaSemana: 1,
      horaInicio: '07:00',
      horaFim: '08:40',
    ),
    Horario(
      disciplina: 'Banco de Dados',
      professor: 'Profa. Juliana Reis',
      sala: 'Lab 01',
      diaSemana: 2,
      horaInicio: '07:00',
      horaFim: '08:40',
    ),
    Horario(
      disciplina: 'Programação Mobile',
      professor: 'Prof. Rafael Lima',
      sala: 'Lab 03',
      diaSemana: 3,
      horaInicio: '09:00',
      horaFim: '10:40',
    ),
    Horario(
      disciplina: 'Redes de Computadores',
      professor: 'Prof. André Souza',
      sala: 'Sala 12',
      diaSemana: 4,
      horaInicio: '07:00',
      horaFim: '08:40',
    ),
    Horario(
      disciplina: 'Projeto de TCC',
      professor: 'Profa. Fernanda Dias',
      sala: 'Sala 08',
      diaSemana: 5,
      horaInicio: '10:00',
      horaFim: '11:40',
    ),
  ];

  /// Notificações fictícias do sistema.
  static List<Notificacao> notificacoes() {
    final agora = DateTime.now();
    return [
      Notificacao(
        id: 'n1',
        titulo: 'Sincronização pendente',
        mensagem: '7 registros aguardando envio ao servidor.',
        dataHora: agora.subtract(const Duration(minutes: 25)),
        tipo: TipoNotificacao.alerta,
      ),
      Notificacao(
        id: 'n2',
        titulo: 'Alerta de baixa frequência',
        mensagem: 'Ana Costa está com frequência abaixo de 75%.',
        dataHora: agora.subtract(const Duration(hours: 3)),
        tipo: TipoNotificacao.alerta,
      ),
      Notificacao(
        id: 'n3',
        titulo: 'Presenças registradas',
        mensagem: '32 entradas registradas hoje até o momento.',
        dataHora: agora.subtract(const Duration(hours: 5)),
        tipo: TipoNotificacao.sucesso,
        lida: true,
      ),
      Notificacao(
        id: 'n4',
        titulo: 'Comunicado da secretaria',
        mensagem: 'Reunião de pais confirmada para sexta-feira.',
        dataHora: agora.subtract(const Duration(days: 1)),
        tipo: TipoNotificacao.info,
        lida: true,
      ),
    ];
  }
}
