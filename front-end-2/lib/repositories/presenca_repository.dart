import '../data/mock/mock_school_data_sources.dart';
import '../models/presenca.dart';

class PresencaRepository {
  PresencaRepository({PresencaDataSource? dataSource})
    : _dataSource = dataSource ?? MockPresencaDataSource();

  final PresencaDataSource _dataSource;

  Future<List<Presenca>> buscarHistorico() => _dataSource.buscarHistorico();
}
