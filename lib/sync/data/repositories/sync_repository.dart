import 'package:my_investments/sync/data/datasources/sync_local_ds.dart';
import 'package:my_investments/sync/data/datasources/sync_remote_ds.dart';
import 'package:my_investments/sync/domain/entities/pending_change.dart';
import 'package:my_investments/sync/domain/entities/sync_manifest.dart';

class SyncRepository {
  final SyncRemoteDataSource _remote;
  final SyncLocalDataSource _local;

  const SyncRepository({
    required SyncRemoteDataSource remote,
    required SyncLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  Future<SyncManifest?> fetchRemoteManifest(String userId) {
    return _remote.fetchManifest(userId: userId);
  }

  Future<void> uploadManifest(String userId, SyncManifest manifest) {
    return _remote.uploadManifest(userId: userId, manifest: manifest);
  }

  Future<String?> downloadSnapshot(String userId) {
    return _remote.downloadSnapshot(userId: userId);
  }

  Future<void> uploadSnapshot(String userId, String snapshot) {
    return _remote.uploadSnapshot(userId: userId, snapshot: snapshot);
  }

  List<PendingChange> getPendingChanges() {
    return _local.getPendingChanges();
  }

  Future<void> addPendingChange(PendingChange change) {
    return _local.addPendingChange(change);
  }

  Future<void> clearPendingChanges() {
    return _local.clearPendingChanges();
  }

  DateTime? getLastSync() {
    return _local.getLastSync();
  }

  Future<void> setLastSync(DateTime time) {
    return _local.setLastSync(time);
  }

  String getOrCreateDeviceId() {
    return _local.getOrCreateDeviceId();
  }
}
