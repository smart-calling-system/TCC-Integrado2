import '../../core/network/api_client.dart';
import '../../models/aluno.dart';

class ApiRecognitionDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Aluno> reconhecerAluno() async {
    final res = await _apiClient.post('/ia/reconhecer');
    return Aluno.fromJson(res['data']['aluno']);
  }
}