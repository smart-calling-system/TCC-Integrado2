/// Modelo de Aluno.
///
/// Estrutura compatível com o retorno esperado da futura API
/// (attendance-api). Os métodos [fromJson]/[toJson] já deixam o modelo
/// pronto para a serialização real.
class Aluno {
  final String id;
  final String nome;
  final String ra;
  final String turma;

  /// Iniciais usadas no avatar fictício (a foto real virá do backend).
  final String? fotoUrl;

  const Aluno({
    required this.id,
    required this.nome,
    required this.ra,
    required this.turma,
    this.fotoUrl,
  });

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  // TODO: Substituir dados mockados pela API quando o backend for integrado.
  factory Aluno.fromJson(Map<String, dynamic> json) => Aluno(
        id: json['id'] as String,
        nome: json['nome'] as String,
        ra: json['ra'] as String,
        turma: json['turma'] as String,
        fotoUrl: json['fotoUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'ra': ra,
        'turma': turma,
        'fotoUrl': fotoUrl,
      };
}
