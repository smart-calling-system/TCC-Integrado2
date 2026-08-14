import '../../core/network/api_client.dart';
import '../../models/aluno.dart';

class ApiAlunoDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<Aluno>> listar({String? busca, String? turma}) async {
    final res = await _apiClient.get('/alunos', query: {'busca': busca, 'turma': turma});
    return (res['data'] as List).map((e) => Aluno.fromJson(e)).toList();
  }

  Future<Aluno> criar({required String nome, required String ra, required String turma}) async {
    final res = await _apiClient.post('/alunos', body: {'nome': nome, 'matricula': ra, 'turmaId': turma});
    return Aluno.fromJson(res['data']);
  }

  Future<Aluno> atualizar(Aluno aluno) async {
    final res = await _apiClient.patch('/alunos/${aluno.id}', body: aluno.toJson());
    return Aluno.fromJson(res['data']);
  }

  Future<void> remover(String id) async => _apiClient.delete('/alunos/$id');

  Future<bool> raJaExiste(String ra, {String? ignorandoId}) async {
    final res = await _apiClient.get('/alunos/check-ra/$ra');
    return res['data']['existe'] ?? false;
  }
}