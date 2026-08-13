class Horario {
  final String disciplina;
  final String professor;
  final String sala;
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

  factory Horario.fromJson(Map<String, dynamic> json) => Horario(
    disciplina: (json['disciplina'] is Map<String, dynamic>)
        ? (json['disciplina'] as Map<String, dynamic>)['nome'] as String? ?? ''
        : json['disciplina'] as String? ?? '',
    professor: json['professor'] as String? ?? '',
    sala: json['sala'] as String? ?? '',
    diaSemana: json['diaSemana'] as int? ?? 1,
    horaInicio: json['horaInicio'] as String? ?? '',
    horaFim: json['horaFim'] as String? ?? '',
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
