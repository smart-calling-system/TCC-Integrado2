import '../core/constants/app_constants.dart';
import '../models/horario.dart';
import '../models/notificacao.dart';
import 'mock_data.dart';

/// Repositório da Escola — grade horária e notificações.
class EscolaRepository {
  /// Retorna a próxima aula da grade a partir do dia atual.
  ///
  /// TODO: Substituir dados mockados pela API quando o backend for integrado.
  Future<Horario> buscarProximaAula() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    final hoje = DateTime.now().weekday;
    return MockData.horarios.firstWhere(
      (h) => h.diaSemana >= hoje,
      orElse: () => MockData.horarios.first,
    );
  }

  /// Retorna as notificações do sistema.
  ///
  /// TODO: Substituir dados mockados pela API quando o backend for integrado.
  Future<List<Notificacao>> buscarNotificacoes() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    return MockData.notificacoes();
  }
}
