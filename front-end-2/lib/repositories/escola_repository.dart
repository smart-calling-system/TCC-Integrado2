// 👇 1. Apagando o rastro do mock e trazendo os arquivos da API real
import '../data/api/api_escola_data_source.dart';
import '../data/escola_data_source.dart'; // Interface garantida
import '../models/horario.dart';
import '../models/notificacao.dart';

class EscolaRepository {
  EscolaRepository({EscolaDataSource? dataSource})
    // 👇 2. A MÁGICA CONTINUA! App 100% plugado no Backend!
    : _dataSource = dataSource ?? ApiEscolaDataSource();

  final EscolaDataSource _dataSource;

  Future<Horario> buscarProximaAula() => _dataSource.buscarProximaAula();

  Future<List<Notificacao>> buscarNotificacoes() =>
      _dataSource.listarNotificacoes();
}