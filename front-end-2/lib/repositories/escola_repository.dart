import '../data/api/api_escola_data_source.dart';
import '../models/horario.dart';
import '../models/notificacao.dart';

class EscolaRepository {
  // 👇 1. Mudou aqui dentro do parênteses
  EscolaRepository({ApiEscolaDataSource? dataSource})
    : _dataSource = dataSource ?? ApiEscolaDataSource();

  // 👇 2. Mudou aqui na declaração final
  final ApiEscolaDataSource _dataSource;

  Future<Horario> buscarProximaAula() => _dataSource.buscarProximaAula();

  Future<List<Notificacao>> buscarNotificacoes() =>
      _dataSource.listarNotificacoes();
}