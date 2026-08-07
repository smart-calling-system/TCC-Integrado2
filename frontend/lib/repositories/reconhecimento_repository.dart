import 'dart:math';

import '../core/constants/app_constants.dart';
import '../models/aluno.dart';
import 'mock_data.dart';

/// Exceção lançada quando a face não é reconhecida (simulação).
class FaceNaoReconhecidaException implements Exception {
  final String mensagem = 'Face não reconhecida';
}

/// Repositório de Reconhecimento Facial (camada de dados).
///
/// Hoje devolve dados fictícios; futuramente fará a chamada real ao
/// serviço de reconhecimento facial via attendance-api.
class ReconhecimentoRepository {
  final Random _random = Random();

  /// Simula o processamento do reconhecimento facial.
  ///
  /// Em ~80% das tentativas retorna o aluno padrão (sucesso) e nas demais
  /// lança [FaceNaoReconhecidaException], permitindo validar visualmente
  /// os dois fluxos (sucesso e erro).
  ///
  /// TODO: Substituir dados mockados pela API quando o backend for integrado.
  Future<Aluno> reconhecerAluno() async {
    await Future.delayed(AppConstants.recognitionDelay);
    if (_random.nextDouble() < 0.8) {
      return MockData.alunoPadrao;
    }
    throw FaceNaoReconhecidaException();
  }
}
