import 'package:flutter/material.dart';

import '../models/aluno.dart';
import '../repositories/reconhecimento_repository.dart';

/// Estados possíveis da tela de reconhecimento facial.
enum EstadoReconhecimento { aguardando, processando, sucesso, erro }

/// Controller da tela de Reconhecimento Facial.
///
/// Orquestra a simulação: aguardando -> processando (loading) ->
/// sucesso ou erro. A tela apenas reage às mudanças de estado.
class RecognitionController extends ChangeNotifier {
  RecognitionController({ReconhecimentoRepository? repository})
      : _repository = repository ?? ReconhecimentoRepository();

  final ReconhecimentoRepository _repository;

  EstadoReconhecimento _estado = EstadoReconhecimento.aguardando;
  Aluno? _alunoReconhecido;
  DateTime? _horarioRegistro;

  EstadoReconhecimento get estado => _estado;
  Aluno? get alunoReconhecido => _alunoReconhecido;
  DateTime? get horarioRegistro => _horarioRegistro;
  bool get processando => _estado == EstadoReconhecimento.processando;

  /// Executa a simulação do reconhecimento e retorna `true` em sucesso.
  Future<bool> simularReconhecimento() async {
    _estado = EstadoReconhecimento.processando;
    notifyListeners();

    try {
      _alunoReconhecido = await _repository.reconhecerAluno();
      _horarioRegistro = DateTime.now();
      _estado = EstadoReconhecimento.sucesso;
      notifyListeners();
      return true;
    } on FaceNaoReconhecidaException {
      _estado = EstadoReconhecimento.erro;
      notifyListeners();
      return false;
    }
  }

  /// Reinicia o fluxo para uma nova tentativa.
  void reiniciar() {
    _estado = EstadoReconhecimento.aguardando;
    _alunoReconhecido = null;
    _horarioRegistro = null;
    notifyListeners();
  }
}
