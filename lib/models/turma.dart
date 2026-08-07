/// Turno em que a turma acontece.
enum TurnoTurma { manha, tarde, noite }

extension TurnoTurmaLabel on TurnoTurma {
  String get label {
    switch (this) {
      case TurnoTurma.manha:
        return 'Manhã';
      case TurnoTurma.tarde:
        return 'Tarde';
      case TurnoTurma.noite:
        return 'Noite';
    }
  }
}

/// Modelo de Turma.
///
/// Estrutura compatível com o retorno esperado da futura API. Os métodos
/// [fromJson]/[toJson] já deixam o modelo pronto para a serialização real.
class Turma {
  final String id;
  final String nome;
  final String serie;
  final TurnoTurma turno;
  final String sala;
  final int quantidadeAlunos;

  const Turma({
    required this.id,
    required this.nome,
    required this.serie,
    required this.turno,
    required this.sala,
    this.quantidadeAlunos = 0,
  });

  Turma copyWith({
    String? id,
    String? nome,
    String? serie,
    TurnoTurma? turno,
    String? sala,
    int? quantidadeAlunos,
  }) =>
      Turma(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        serie: serie ?? this.serie,
        turno: turno ?? this.turno,
        sala: sala ?? this.sala,
        quantidadeAlunos: quantidadeAlunos ?? this.quantidadeAlunos,
      );

  // TODO: Substituir dados mockados pela API quando o backend for integrado.
  factory Turma.fromJson(Map<String, dynamic> json) => Turma(
        id: json['id'] as String,
        nome: json['nome'] as String,
        serie: json['serie'] as String,
        turno: TurnoTurma.values.byName(json['turno'] as String),
        sala: json['sala'] as String,
        quantidadeAlunos: json['quantidadeAlunos'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'serie': serie,
        'turno': turno.name,
        'sala': sala,
        'quantidadeAlunos': quantidadeAlunos,
      };
}
