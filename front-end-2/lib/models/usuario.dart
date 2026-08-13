/// Cargo do usuário autenticado no sistema.
enum CargoUsuario { coordenador, professor, secretaria }

extension CargoUsuarioLabel on CargoUsuario {
  String get label {
    switch (this) {
      case CargoUsuario.coordenador:
        return 'Coordenador(a)';
      case CargoUsuario.professor:
        return 'Professor(a)';
      case CargoUsuario.secretaria:
        return 'Secretaria';
    }
  }
}

extension CargoUsuarioBackend on CargoUsuario {
  String get backendValue {
    switch (this) {
      case CargoUsuario.coordenador:
        return 'ADMIN';
      case CargoUsuario.professor:
        return 'PROFESSOR';
      case CargoUsuario.secretaria:
        return 'SECRETARIA';
    }
  }

  static CargoUsuario fromBackend(String? value) {
    switch (value) {
      case 'SECRETARIA':
      case 'secretaria':
        return CargoUsuario.secretaria;
      case 'PROFESSOR':
      case 'professor':
        return CargoUsuario.professor;
      default:
        return CargoUsuario.coordenador;
    }
  }
}

/// Modelo de Usuário — conta autenticada no aplicativo.
///
/// Estrutura compatível com o retorno esperado da futura API de
/// autenticação. Os métodos [fromJson]/[toJson] já deixam o modelo pronto
/// para a serialização real.
class Usuario {
  final String id;
  final String nome;
  final String email;
  final CargoUsuario cargo;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
  });

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    CargoUsuario? cargo,
  }) => Usuario(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    email: email ?? this.email,
    cargo: cargo ?? this.cargo,
  );

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id']?.toString() ?? '',
    nome: json['nome'] as String? ?? '',
    email: json['email'] as String? ?? '',
    cargo: CargoUsuarioBackend.fromBackend(
      (json['cargo'] ?? json['role']) as String?,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'role': cargo.backendValue,
  };
}
