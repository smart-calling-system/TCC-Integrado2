/// Modelo de Disciplina.
///
/// Estrutura compatível com o retorno esperado da futura API. Os métodos
/// [fromJson]/[toJson] já deixam o modelo pronto para a serialização real.
class Disciplina {
  final String id;
  final String nome;
  final String professor;
  final int cargaHoraria;
  final List<String> turmasVinculadas;

  const Disciplina({
    required this.id,
    required this.nome,
    required this.professor,
    required this.cargaHoraria,
    this.turmasVinculadas = const [],
  });

  Disciplina copyWith({
    String? id,
    String? nome,
    String? professor,
    int? cargaHoraria,
    List<String>? turmasVinculadas,
  }) =>
      Disciplina(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        professor: professor ?? this.professor,
        cargaHoraria: cargaHoraria ?? this.cargaHoraria,
        turmasVinculadas: turmasVinculadas ?? this.turmasVinculadas,
      );

  // TODO: Substituir dados mockados pela API quando o backend for integrado.
  factory Disciplina.fromJson(Map<String, dynamic> json) => Disciplina(
        id: json['id'] as String,
        nome: json['nome'] as String,
        professor: json['professor'] as String,
        cargaHoraria: json['cargaHoraria'] as int,
        turmasVinculadas: (json['turmasVinculadas'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'professor': professor,
        'cargaHoraria': cargaHoraria,
        'turmasVinculadas': turmasVinculadas,
      };
}
