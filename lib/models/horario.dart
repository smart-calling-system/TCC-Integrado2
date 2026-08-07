/// Modelo de Horário — item da grade horária de uma turma.
class Horario {
  final String disciplina;
  final String professor;
  final String sala;

  /// 1 = segunda-feira ... 7 = domingo (padrão DateTime.weekday).
  final int diaSemana;
  final String horaInicio;
  final String horaFim;

  const Horario({
    required this.disciplina,
    required this.professor,
    required this.sala,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFim,
  });

  // TODO: Substituir dados mockados pela API quando o backend for integrado.
  factory Horario.fromJson(Map<String, dynamic> json) => Horario(
        disciplina: json['disciplina'] as String,
        professor: json['professor'] as String,
        sala: json['sala'] as String,
        diaSemana: json['diaSemana'] as int,
        horaInicio: json['horaInicio'] as String,
        horaFim: json['horaFim'] as String,
      );

  Map<String, dynamic> toJson() => {
        'disciplina': disciplina,
        'professor': professor,
        'sala': sala,
        'diaSemana': diaSemana,
        'horaInicio': horaInicio,
        'horaFim': horaFim,
      };
}
