import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // 👇 ATENÇÃO CHEF: Coloque o IP da máquina e a rota do Node.js que lista os alunos!
// 👇 IP NOVO DO SEU COMPUTADOR NO SENAI!
  final String _nodeApiUrl = 'http://10.133.101.13:3000/api/v1/alunos'; 
  
  // IP do servidor Python para mandar a foto
  final String _pythonApiUrl = 'http://10.133.101.13:5000/cadastrar';

  VincularController() {
    // Assim que a tela abre, ele já puxa os alunos do banco!
    carregarAlunos();
  }

  Future<void> carregarAlunos() async {
    _carregandoAlunos = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_nodeApiUrl));

      if (response.statusCode == 200) {
        // 👇 Agora o Flutter entende que é um objeto complexo (Map) e não uma lista direta
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // 👇 Nós navegamos pelas chaves do seu JSON: "data" -> "dados"
        if (jsonResponse['status'] == 'success' && 
            jsonResponse['data'] != null && 
            jsonResponse['data']['dados'] != null) {
              
          final List<dynamic> listaAlunos = jsonResponse['data']['dados'];
          
          _alunos = listaAlunos.map((e) => {
            'id': e['id'].toString(),
            'nome': e['nome'].toString(), // O Python usa esse nome para criar a foto
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
      // 1️⃣ PASSO: Manda a foto para o Python processar a IA e salvar na pasta local
      final uriPython = Uri.parse(_pythonApiUrl);
      var requestPython = http.MultipartRequest('POST', uriPython);
      
      requestPython.fields['nome'] = _alunoSelecionado!;
      requestPython.fields['numero_foto'] = '1';
      requestPython.files.add(await http.MultipartFile.fromPath('file', foto.path));

      var responsePython = await requestPython.send();

      if (responsePython.statusCode != 200) {
        _processando = false;
        notifyListeners();
        return false;
      }

      // 2️⃣ PASSO: Manda a foto para o Node.js salvar o caminho na tabela do Postgres (`foto_treinamento`)
      // Usamos a mesma URL base do Node, mas batendo na rota do controller que você mandou!
      final uriNode = Uri.parse('http://10.133.101.13:3000/api/v1/alunos/$alunoId/foto');
      var requestNode = http.MultipartRequest('POST', uriNode);
      
      requestNode.files.add(await http.MultipartFile.fromPath('foto', foto.path)); // Nome do campo esperado pelo upload.single('foto')

      var responseNode = await requestNode.send();

      _processando = false;
      notifyListeners();

      return responseNode.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao vincular rosto e salvar no banco: $e');
      _processando = false;
      notifyListeners();
      return false;
    }
  }
}