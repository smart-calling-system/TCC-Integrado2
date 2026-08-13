import '../../models/aluno.dart';
import '../../models/disciplina.dart';
import '../../models/horario.dart';
import '../../models/notificacao.dart';
import '../../models/presenca.dart';
import '../../models/turma.dart';
import '../../models/usuario.dart';

class MockData {
  MockData._();

  static const String demoEmail = 'professor@escola.com';
  static const String demoPassword = '123456';

  static const Usuario usuarioPadrao = Usuario(
    id: 'u1',
    nome: 'Fernanda Dias',
    email: demoEmail,
    cargo: CargoUsuario.coordenador,
  );

  static const List<Turma> turmas = [
    Turma(
      id: 't1',
      nome: '1 DS',
      serie: '1 ano - Ensino Medio Tecnico',
      turno: TurnoTurma.manha,
      sala: 'Sala 08',
      quantidadeAlunos: 2,
    ),
    Turma(
      id: 't2',
      nome: '2 DS',
      serie: '2 ano - Ensino Medio Tecnico',
      turno: TurnoTurma.manha,
      sala: 'Sala 10',
      quantidadeAlunos: 2,
    ),
    Turma(
      id: 't3',
      nome: '3 DS',
      serie: '3 ano - Ensino Medio Tecnico',
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
      nome: 'Programacao Mobile',
      professor: 'Prof. Rafael Lima',
      cargaHoraria: 60,
      turmasVinculadas: ['t3'],
    ),
    Disciplina(
      id: 'd4',
      nome: 'Redes de Computadores',
      professor: 'Prof. Andre Souza',
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

  static const Aluno alunoPadrao = Aluno(
    id: '1',
    nome: 'Joao da Silva',
    ra: '202600123',
    turma: '3 DS',
  );

  static const List<Aluno> alunos = [
    alunoPadrao,
    Aluno(id: '2', nome: 'Maria Oliveira', ra: '202600124', turma: '3 DS'),
    Aluno(id: '3', nome: 'Pedro Santos', ra: '202600125', turma: '3 DS'),
    Aluno(id: '4', nome: 'Ana Costa', ra: '202600126', turma: '3 DS'),
    Aluno(id: '5', nome: 'Lucas Pereira', ra: '202600127', turma: '2 DS'),
    Aluno(id: '6', nome: 'Beatriz Almeida', ra: '202600128', turma: '2 DS'),
    Aluno(id: '7', nome: 'Gabriel Rocha', ra: '202600129', turma: '1 DS'),
    Aluno(id: '8', nome: 'Larissa Fernandes', ra: '202600130', turma: '1 DS'),
  ];

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
      disciplina: 'Programacao Mobile',
      professor: 'Prof. Rafael Lima',
      sala: 'Lab 03',
      diaSemana: 3,
      horaInicio: '09:00',
      horaFim: '10:40',
    ),
  ];

  static List<Notificacao> notificacoes() {
    final agora = DateTime.now();
    return [
      Notificacao(
        id: 'n1',
        titulo: 'Sincronizacao pendente',
        mensagem: 'Existem registros locais aguardando envio ao servidor.',
        dataHora: agora.subtract(const Duration(minutes: 25)),
        tipo: TipoNotificacao.alerta,
      ),
      Notificacao(
        id: 'n2',
        titulo: 'Ambiente de desenvolvimento',
        mensagem: 'API real desativada. O app esta operando em modo mock.',
        dataHora: agora.subtract(const Duration(hours: 1)),
        tipo: TipoNotificacao.info,
      ),
    ];
  }
}
