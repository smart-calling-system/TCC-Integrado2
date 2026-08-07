import 'package:flutter/material.dart';

import '../repositories/dashboard_repository.dart';

/// Controller da tela de Dashboard.
class DashboardController extends ChangeNotifier {
  DashboardController({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository();

  final DashboardRepository _repository;

  bool _carregando = true;
  ResumoDashboard? _resumo;

  bool get carregando => _carregando;
  ResumoDashboard? get resumo => _resumo;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _resumo = await _repository.buscarResumo();
    _carregando = false;
    notifyListeners();
  }
}
