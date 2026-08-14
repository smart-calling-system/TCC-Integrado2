import '../../core/network/api_client.dart';
import '../../models/turma.dart';

class ApiTurmaDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<Turma>> listar({String? busca}) async {
    final res = await _apiClient.get('/turmas', query: {'busca': busca});
    return (res['data'] as List).map((e) => Turma.fromJson(e)).toList();
  }

  Future<List<String>> listarNomes() async {
    final res = await _apiClient.get('/turmas');
    return (res['data'] as List).map((e) => e['nome'].toString()).toList();
  }

  Future<Turma> criar({required String nome, required String serie, required TurnoTurma turno, required String sala}) async {
    final res = await _apiClient.post('/turmas', body: {'nome': nome, 'anoLetivo': int.parse(serie), 'turno': turno.name, 'sala': sala});
    return Turma.fromJson(res['data']);
  }

  Future<Turma> atualizar(Turma turma) async {
    final res = await _apiClient.patch('/turmas/${turma.id}', body: turma.toJson());
    return Turma.fromJson(res['data']);
  }

  Future<void> remover(String id) async => _apiClient.delete('/turmas/$id');
}