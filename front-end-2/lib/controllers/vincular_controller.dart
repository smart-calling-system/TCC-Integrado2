import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 👇 1. Importando o nosso Quartel General de IPs! 
import '../../core/network/api_config.dart';

class VincularController extends ChangeNotifier {
  bool _processando = false;
  bool get processando => _processando;

  bool _carregandoAlunos = true;
  bool get carregandoAlunos => _carregandoAlunos;

  // Lista dinâmica que vai receber os dados do Node.js
  List<Map<String, dynamic>> _alunos = [];
  List<Map<String, dynamic>> get alunos => _alunos;

  String? _alunoSelecionado;
  String? get alunoSelecionado => _alunoSelecionado;

  VincularController() {
    // Assim que a tela abre, ele já puxa os alunos do banco!
    carregarAlunos();
  }

  Future<void> carregarAlunos() async {
    _carregandoAlunos = true;
    notifyListeners();

    try {
      // 👇 2. O FLUTTER PEGA O TOKEN DE LOGIN SALVO
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // 👇 3. FAZ A REQUISIÇÃO COM O IP CENTRALIZADO E O TOKEN NA PORTA!
      final response = await http.get(
        ApiConfig.uri('/alunos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['status'] == 'success' && 
            jsonResponse['data'] != null && 
            jsonResponse['data']['dados'] != null) {
              
          final List<dynamic> listaAlunos = jsonResponse['data']['dados'];
          
          _alunos = listaAlunos.map((e) => {
            'id': e['id'].toString(),
            'nome': e['nome'].toString(), 
          }).toList();
        } else {
          _alunos = [];
        }
      } else {
        debugPrint('Erro ao buscar alunos do Node: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro de conexão com o backend Node: $e');
    } finally {
      _carregandoAlunos = false;
      notifyListeners();
    }
  }

  void selecionarAluno(String? nome) {
    _alunoSelecionado = nome;
    notifyListeners();
  }

  Future<bool> vincularRostoNoPython(File foto, String alunoId) async {
    if (_alunoSelecionado == null) return false;
    
    _processando = true;
    notifyListeners();

    try {
      // 👇 4. PEGA O TOKEN NOVAMENTE PARA AUTORIZAR O UPLOAD
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Arquitetura limpa: O Flutter manda TUDO SÓ PARA O NODE!
      final uriNode = ApiConfig.uri('/alunos/$alunoId/foto');
      
      var requestNode = http.MultipartRequest('POST', uriNode);
      
      // 👇 5. COLOCA O TOKEN NO HEADER DO MULTIPART
      requestNode.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Anexa a foto no campo 'foto' que o Node.js (multer) está esperando
      requestNode.files.add(await http.MultipartFile.fromPath('foto', foto.path)); 

      var responseNode = await requestNode.send();

      _processando = false;
      notifyListeners();

      // Se o Node der 200 (OK) ou 201 (Created), deu tudo certo!
      return responseNode.statusCode == 200 || responseNode.statusCode == 201;
    } catch (e) {
      debugPrint('Erro ao vincular rosto e salvar no banco: $e');
      _processando = false;
      notifyListeners();
      return false;
    }
  }
}