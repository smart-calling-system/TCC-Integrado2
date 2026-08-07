import 'package:flutter/material.dart';

import '../models/aluno.dart';
import '../repositories/aluno_repository.dart';
import '../repositories/turma_repository.dart';

/// Controller do formulário de cadastro/edição de Aluno.
class AlunoFormController extends ChangeNotifier {
  AlunoFormController({
    Aluno? alunoParaEditar,
    AlunoRepository? repository,
    TurmaRepository? turmaRepository,
  })  : _alunoOriginal = alunoParaEditar,
        _repository = repository ?? AlunoRepository(),
        _turmaRepository = turmaRepository ?? TurmaRepository() {
    if (alunoParaEditar != null) {
      nomeController.text = alunoParaEditar.nome;
      raController.text = alunoParaEditar.ra;
      _turmaSelecionada = alunoParaEditar.turma;
    }
    _carregarTurmas();
  }

  final Aluno? _alunoOriginal;
  final AlunoRepository _repository;
  final TurmaRepository _turmaRepository;

  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final raController = TextEditingController();

  bool get emEdicao => _alunoOriginal != null;

  List<String> turmas = [];
  String? _turmaSelecionada;
  bool _salvando = false;
  bool _carregandoTurmas = true;

  String? get turmaSelecionada => _turmaSelecionada;
  bool get salvando => _salvando;
  bool get carregandoTurmas => _carregandoTurmas;

  Future<void> _carregarTurmas() async {
    turmas = await _turmaRepository.listarNomes();
    _turmaSelecionada ??= turmas.isNotEmpty ? turmas.first : null;
    _carregandoTurmas = false;
    notifyListeners();
  }

  void selecionarTurma(String? turma) {
    _turmaSelecionada = turma;
    notifyListeners();
  }

  String? validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o nome';
    if (valor.trim().length < 3) return 'Nome muito curto';
    return null;
  }

  String? validarRa(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o RA';
    if (valor.trim().length < 4) return 'RA inválido';
    return null;
  }

  /// Retorna `true` quando o cadastro foi salvo com sucesso.
  Future<bool> salvar() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (_turmaSelecionada == null) return false;

    final ra = raController.text.trim();
    final raDuplicado = await _repository.raJaExiste(
      ra,
      ignorandoId: _alunoOriginal?.id,
    );
    if (raDuplicado) {
      _erroRa = 'Já existe um aluno cadastrado com este RA';
      notifyListeners();
      return false;
    }
    _erroRa = null;

    _salvando = true;
    notifyListeners();
    try {
      if (emEdicao) {
        await _repository.atualizar(
          Aluno(
            id: _alunoOriginal!.id,
            nome: nomeController.text.trim(),
            ra: ra,
            turma: _turmaSelecionada!,
            fotoUrl: _alunoOriginal.fotoUrl,
          ),
        );
      } else {
        await _repository.criar(
          nome: nomeController.text.trim(),
          ra: ra,
          turma: _turmaSelecionada!,
        );
      }
      return true;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  String? _erroRa;
  String? get erroRa => _erroRa;

  @override
  void dispose() {
    nomeController.dispose();
    raController.dispose();
    super.dispose();
  }
}
