import 'aluno.dart';

/// Situação do registro de presença.
enum StatusPresenca { presente, atrasado, saidaAntecipada, ausente }

extension StatusPresencaLabel on StatusPresenca {
  String get label {
    switch (this) {
      case StatusPresenca.presente:
        return 'Presente';
      case StatusPresenca.atrasado:
        return 'Atrasado';
      case StatusPresenca.saidaAntecipada:
        return 'Saída antecipada';
      case StatusPresenca.ausente:
        return 'Ausente';
    }
  }
}

/// Modelo de Presença — registro de entrada/saída de um aluno.
class Presenca {
  final String id;
  final Aluno aluno;
  final DateTime data;
  final DateTime? entrada;
  final DateTime? saida;
  final StatusPresenca status;

  const Presenca({
    required this.id,
    required this.aluno,
    required this.data,
    required this.status,
    this.entrada,
    this.saida,
  });

  // TODO: Substituir dados mockados pela API quando o backend for integrado.
  factory Presenca.fromJson(Map<String, dynamic> json) => Presenca(
        id: json['id'] as String,
        aluno: Aluno.fromJson(json['aluno'] as Map<String, dynamic>),
        data: DateTime.parse(json['data'] as String),
        entrada: json['entrada'] != null
            ? DateTime.parse(json['entrada'] as String)
            : null,
        saida: json['saida'] != null
            ? DateTime.parse(json['saida'] as String)
            : null,
        status: StatusPresenca.values.byName(json['status'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'aluno': aluno.toJson(),
        'data': data.toIso8601String(),
        'entrada': entrada?.toIso8601String(),
        'saida': saida?.toIso8601String(),
        'status': status.name,
      };
}
