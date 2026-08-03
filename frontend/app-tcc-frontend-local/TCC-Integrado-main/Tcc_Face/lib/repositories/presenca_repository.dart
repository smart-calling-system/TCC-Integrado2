import '../core/constants/app_constants.dart';
import '../models/presenca.dart';
import 'mock_data.dart';

/// Repositório de Presenças (camada de dados).
///
/// Centraliza o acesso aos registros de entrada/saída. As telas nunca
/// acessam o mock diretamente — apenas este repositório, o que permite
/// trocar a implementação pela API real sem alterar a interface.
class PresencaRepository {
  /// Retorna o histórico de presenças.
  ///
  /// TODO: Substituir dados mockados pela API quando o backend for integrado.
  Future<List<Presenca>> buscarHistorico() async {
    await Future.delayed(AppConstants.mockLoadDelay);
    return MockData.historico();
  }
}
