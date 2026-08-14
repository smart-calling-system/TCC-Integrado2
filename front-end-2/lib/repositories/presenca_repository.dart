// 👇 1. Fim da linha para o Mock! Trazendo a API real:
import '../data/api/api_presenca_data_source.dart';
import '../data/presenca_data_source.dart'; // Interface garantida
import '../models/presenca.dart';

class PresencaRepository {
  PresencaRepository({PresencaDataSource? dataSource})
    // 👇 2. A MÁGICA FEITA! Agora o histórico de presença vem direto do banco de dados!
    : _dataSource = dataSource ?? ApiPresencaDataSource();

  final PresencaDataSource _dataSource;

  Future<List<Presenca>> buscarHistorico() => _dataSource.buscarHistorico();
}