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

extension StatusPresencaBackend on StatusPresenca {
  String get backendValue {
    switch (this) {
      case StatusPresenca.presente:
        return 'PRESENTE';
      case StatusPresenca.atrasado:
        return 'ATRASO';
      case StatusPresenca.saidaAntecipada:
        return 'SAIDA_ANTECIPADA';
      case StatusPresenca.ausente:
        return 'AUSENTE';
    }
  }

  static StatusPresenca fromBackend(String? value) {
    switch (value) {
      case 'ATRASO':
      case 'atrasado':
        return StatusPresenca.atrasado;
      case 'SAIDA_ANTECIPADA':
      case 'saidaAntecipada':
        return StatusPresenca.saidaAntecipada;
      case 'AUSENTE':
      case 'ausente':
        return StatusPresenca.ausente;
      default:
        return StatusPresenca.presente;
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

  factory Presenca.fromJson(Map<String, dynamic> json) => Presenca(
    id: json['id']?.toString() ?? '',
    aluno: Aluno.fromJson(
      json['aluno'] as Map<String, dynamic>? ?? <String, dynamic>{},
    ),
    data: DateTime.parse((json['data'] ?? json['dataHora']) as String),
    entrada: (json['entrada'] ?? json['dataHora']) != null
        ? DateTime.parse((json['entrada'] ?? json['dataHora']) as String)
        : null,
    saida: (json['saida'] ?? json['dataHoraSaida']) != null
        ? DateTime.parse((json['saida'] ?? json['dataHoraSaida']) as String)
        : null,
    status: StatusPresencaBackend.fromBackend(json['status'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'aluno': aluno.toJson(),
    'data': data.toIso8601String(),
    'dataHora': entrada?.toIso8601String(),
    'dataHoraSaida': saida?.toIso8601String(),
    'status': status.backendValue,
  };
}
