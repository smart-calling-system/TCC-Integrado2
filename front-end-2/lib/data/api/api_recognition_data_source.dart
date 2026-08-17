import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/network/api_exception.dart'; // 👇 Caminho corrigido!
import '../../models/aluno.dart';

class ApiRecognitionDataSource {
  // 👇 Antes estava .12, agora atualizado para .13
  final String _pythonUrl = 'http://10.133.101.13:5000/reconhecer';

  Future<Aluno> reconhecerAluno(File foto) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_pythonUrl));
      
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

      return Aluno.fromJson(decoded['backend']['data']['aluno']);
      
    } catch (e) {
      throw ApiException('Erro de comunicação com a IA: $e');
    }
  }
}