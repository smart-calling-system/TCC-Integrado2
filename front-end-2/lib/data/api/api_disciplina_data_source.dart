import '../../core/network/api_client.dart';
import '../../models/disciplina.dart';

class ApiDisciplinaDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<Disciplina>> listar({String? busca}) async {
    final res = await _apiClient.get('/disciplinas', query: {'busca': busca});
    return (res['data'] as List).map((e) => Disciplina.fromJson(e)).toList();
  }

  Future<Disciplina> criar({required String nome, required String professor, required int cargaHoraria}) async {
    final res = await _apiClient.post('/disciplinas', body: {'nome': nome, 'professor': professor, 'cargaHoraria': cargaHoraria});
    return Disciplina.fromJson(res['data']);
  }

  Future<Disciplina> atualizar(Disciplina disciplina) async {
    final res = await _apiClient.patch('/disciplinas/${disciplina.id}', body: disciplina.toJson());
    return Disciplina.fromJson(res['data']);
  }

  Future<void> remover(String id) async => _apiClient.delete('/disciplinas/$id');
}