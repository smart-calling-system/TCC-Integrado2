import '../../core/network/api_client.dart';
import '../../models/presenca.dart';

class ApiPresencaDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<Presenca>> buscarHistorico() async {
    final res = await _apiClient.get('/presencas');
    
    // 👇 A MÁGICA AQUI: Lendo 'dados' de dentro do 'data', exatamente como seu Node.js envia!
    final lista = res['data']['dados'] as List;
    
    return lista.map((e) => Presenca.fromJson(e)).toList();
  }
}