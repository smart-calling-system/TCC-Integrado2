import '../../core/network/api_client.dart';
import '../../models/presenca.dart';

class ApiPresencaDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<Presenca>> buscarHistorico() async {
    final res = await _apiClient.get('/presencas');
    return (res['data'] as List).map((e) => Presenca.fromJson(e)).toList();
  }
}