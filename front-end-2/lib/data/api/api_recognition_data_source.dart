import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// 👇 1. Importando o nosso Quartel General de IPs!
import '../../core/network/api_config.dart'; 
import '../../core/network/api_exception.dart';
import '../../models/aluno.dart';

class ApiRecognitionDataSource {
  
  Future<Aluno> reconhecerAluno(File foto) async {
    try {
      // 👇 2. FIM DO IP CHUMBADO! Usamos a rota centralizada direto pro Python (Porta 5000)
      final url = ApiConfig.pythonUri('/reconhecer');
      
      var request = http.MultipartRequest('POST', url);
      
      request.files.add(await http.MultipartFile.fromPath('file', foto.path));
      
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      
      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 400 || decoded['status'] == 'erro') {
        throw ApiException(decoded['mensagem'] ?? 'Erro no servidor de IA.');
      }

      if (decoded['reconhecido'] == false) {
        throw ApiException(decoded['mensagem'] ?? 'Rosto não reconhecido.');
      }

      // 👇 3. Isso aqui agora vai funcionar perfeito se você aplicou aquela correção no Node.js 
      // para ele devolver o objeto inteiro do Aluno em vez de só a String!
      return Aluno.fromJson(decoded['backend']['data']['aluno']);
      
    } catch (e) {
      throw ApiException('Erro de comunicação com a IA: $e');
    }
  }
}