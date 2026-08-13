import 'dart:math';

import '../../core/constants/app_constants.dart';
import '../../core/errors/recognition_exception.dart';
import '../../models/aluno.dart';
import 'mock_data.dart';

abstract class RecognitionDataSource {
  Future<Aluno> reconhecerAluno();
}

class MockRecognitionDataSource implements RecognitionDataSource {
  MockRecognitionDataSource({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  Future<Aluno> reconhecerAluno() async {
    await Future.delayed(AppConstants.recognitionDelay);
    if (_random.nextDouble() < 0.8) return MockData.alunoPadrao;
    throw FaceNaoReconhecidaException();
  }
}
