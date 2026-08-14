import '../../core/network/api_client.dart';
import '../../models/horario.dart';
import '../../models/notificacao.dart';

class ApiEscolaDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Horario> buscarProximaAula() async {
    final res = await _apiClient.get('/horarios/agora');
    return Horario.fromJson(res['data']);
  }

  Future<List<Notificacao>> listarNotificacoes() async {
    final res = await _apiClient.get('/alertas');
    return (res['data'] as List).map((e) => Notificacao.fromJson(e)).toList();
  }
}