import 'sync_queue_data_source.dart';
import 'sync_queue_factory_stub.dart'
    if (dart.library.io) 'sync_queue_factory_io.dart'
    as factory;

SyncQueueDataSource createDefaultSyncQueueDataSource() =>
    factory.createDefaultSyncQueueDataSource();
