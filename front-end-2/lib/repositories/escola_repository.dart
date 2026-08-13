import '../data/mock/mock_school_data_sources.dart';
import '../models/horario.dart';
import '../models/notificacao.dart';

class EscolaRepository {
  EscolaRepository({EscolaDataSource? dataSource})
    : _dataSource = dataSource ?? MockEscolaDataSource();

  final EscolaDataSource _dataSource;

  Future<Horario> buscarProximaAula() => _dataSource.buscarProximaAula();

  Future<List<Notificacao>> buscarNotificacoes() =>
      _dataSource.listarNotificacoes();
}
