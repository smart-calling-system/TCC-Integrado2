/// Tipo da notificação exibida no aplicativo.
enum TipoNotificacao { info, alerta, sucesso }

/// Modelo de Notificação — avisos do sistema (ex.: baixa frequência,
/// sincronização pendente, comunicados da secretaria).
class Notificacao {
  final String id;
  final String titulo;
  final String mensagem;
  final DateTime dataHora;
  final TipoNotificacao tipo;
  final bool lida;

  const Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.dataHora,
    required this.tipo,
    this.lida = false,
  });

  // TODO: Substituir dados mockados pela API quando o backend for integrado.
  factory Notificacao.fromJson(Map<String, dynamic> json) => Notificacao(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        mensagem: json['mensagem'] as String,
        dataHora: DateTime.parse(json['dataHora'] as String),
        tipo: TipoNotificacao.values.byName(json['tipo'] as String),
        lida: json['lida'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'mensagem': mensagem,
        'dataHora': dataHora.toIso8601String(),
        'tipo': tipo.name,
        'lida': lida,
      };
}
