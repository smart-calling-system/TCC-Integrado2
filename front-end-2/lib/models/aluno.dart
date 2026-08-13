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

  factory Aluno.fromJson(Map<String, dynamic> json) => Aluno(
    id: json['id']?.toString() ?? '',
    nome: json['nome'] as String? ?? '',
    ra: (json['ra'] ?? json['matricula']) as String? ?? '',
    turma: json['turma'] is String
        ? json['turma'] as String
        : (json['turma'] as Map<String, dynamic>?)?['nome'] as String? ?? '',
    fotoUrl: (json['fotoUrl'] ?? json['fotoTreinamento']) as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'matricula': ra,
    'turma': turma,
    'fotoTreinamento': fotoUrl,
  };
}
