import 'package:flutter/material.dart';

import '../models/presenca.dart';
import '../repositories/mock_data.dart';
import '../repositories/turma_repository.dart';

/// Período usado como filtro em Relatórios.
enum PeriodoRelatorio { ultimos7Dias, ultimos30Dias, todoPeriodo }

extension PeriodoRelatorioLabel on PeriodoRelatorio {
  String get label {
    switch (this) {
      case PeriodoRelatorio.ultimos7Dias:
        return 'Últimos 7 dias';
      case PeriodoRelatorio.ultimos30Dias:
        return 'Últimos 30 dias';
      case PeriodoRelatorio.todoPeriodo:
        return 'Todo o período';
    }
  }

  int? get dias {
    switch (this) {
      case PeriodoRelatorio.ultimos7Dias:
        return 7;
      case PeriodoRelatorio.ultimos30Dias:
        return 30;
      case PeriodoRelatorio.todoPeriodo:
        return null;
    }
  }
}

/// Controller da tela de Relatórios — filtra o histórico mockado por
/// período/turma/status e monta os dados do gráfico.
class RelatorioController extends ChangeNotifier {
  RelatorioController({TurmaRepository? turmaRepository})
      : _turmaRepository = turmaRepository ?? TurmaRepository();

  final TurmaRepository _turmaRepository;

  bool _carregando = true;
  List<Presenca> _todosRegistros = [];
  List<Presenca> _registrosFiltrados = [];
  List<String> turmasDisponiveis = [];

  PeriodoRelatorio _periodo = PeriodoRelatorio.ultimos7Dias;
  String? _turma;
  StatusPresenca? _status;

  bool _exportando = false;

  bool get carregando => _carregando;
  bool get exportando => _exportando;
  List<Presenca> get registros => _registrosFiltrados;
  PeriodoRelatorio get periodo => _periodo;
  String? get turma => _turma;
  StatusPresenca? get status => _status;

  int get totalPresentes => _registrosFiltrados
      .where((p) =>
          p.status == StatusPresenca.presente ||
          p.status == StatusPresenca.atrasado)
      .length;
  int get totalFaltas =>
      _registrosFiltrados.where((p) => p.status == StatusPresenca.ausente).length;
  double get percentualPresenca {
    if (_registrosFiltrados.isEmpty) return 0;
    return (totalPresentes / _registrosFiltrados.length) * 100;
  }

  /// Presenças por dia (últimos 7 dias considerados no filtro atual),
  /// usadas no gráfico de barras.
  List<int> get serieDiaria {
    final agora = DateTime.now();
    return List<int>.generate(7, (i) {
      final dia = agora.subtract(Duration(days: 6 - i));
      return _registrosFiltrados
          .where((p) =>
              p.data.year == dia.year &&
              p.data.month == dia.month &&
              p.data.day == dia.day &&
              p.status != StatusPresenca.ausente)
          .length;
    });
  }

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    turmasDisponiveis = await _turmaRepository.listarNomes();
    _todosRegistros = MockData.historico();
    _aplicarFiltros();

    _carregando = false;
    notifyListeners();
  }

  void filtrarPorPeriodo(PeriodoRelatorio periodo) {
    _periodo = periodo;
    _aplicarFiltros();
    notifyListeners();
  }

  void filtrarPorTurma(String? turma) {
    _turma = turma;
    _aplicarFiltros();
    notifyListeners();
  }

  void filtrarPorStatus(StatusPresenca? status) {
    _status = status;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    Iterable<Presenca> lista = _todosRegistros;

    final dias = _periodo.dias;
    if (dias != null) {
      final limite = DateTime.now().subtract(Duration(days: dias));
      lista = lista.where((p) => p.data.isAfter(limite));
    }
    if (_status != null) {
      lista = lista.where((p) => p.status == _status);
    }
    if (_turma != null && _turma!.isNotEmpty) {
      lista = lista.where((p) => p.aluno.turma == _turma);
    }
    _registrosFiltrados = lista.toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  /// Simula a exportação do relatório (sem gerar arquivo real).
  Future<void> exportar() async {
    _exportando = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    _exportando = false;
    notifyListeners();
  }
}
