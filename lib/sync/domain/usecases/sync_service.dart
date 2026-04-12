import 'package:my_investments/core/storage/sync_snapshot_provider.dart';
import 'package:my_investments/sync/data/pending_changes_applier.dart';
import 'package:my_investments/sync/data/repositories/sync_repository.dart';
import 'package:my_investments/sync/data/sync_snapshot_codec.dart';
import 'package:my_investments/sync/data/sync_snapshot_merger.dart';
import 'package:my_investments/sync/domain/entities/sync_manifest.dart';

class SyncService {
  final SyncRepository _repository;

  const SyncService({required SyncRepository repository})
      : _repository = repository;

  Future<SyncPullOutcome> pullIfRemoteNewer({
    required String userId,
    required List<SyncSnapshotProvider> providers,
  }) async {
    final remoteManifest = await _repository.fetchRemoteManifest(userId);
    if (remoteManifest == null) return SyncPullOutcome.noRemote;

    final lastSync = _repository.getLastSync();
    if (lastSync != null &&
        !remoteManifest.updatedAt.isAfter(lastSync)) {
      return SyncPullOutcome.upToDate;
    }

    final rawSnapshot = await _repository.downloadSnapshot(userId);
    if (rawSnapshot == null) return SyncPullOutcome.noRemote;

    final snapshot = SyncSnapshotCodec.decode(rawSnapshot);
    final pending = _repository.getPendingChanges();
    final merged = PendingChangesApplier.apply(snapshot, pending);

    for (final provider in providers) {
      await provider.importSnapshot(merged);
    }

    await _repository.setLastSync(remoteManifest.updatedAt);
    return SyncPullOutcome.pulled;
  }

  Future<void> pushSnapshot({
    required String userId,
    required List<SyncSnapshotProvider> providers,
  }) async {
    final snapshot = SyncSnapshotMerger.mergeProviders(providers);
    final pending = _repository.getPendingChanges();
    final merged = PendingChangesApplier.apply(snapshot, pending);
    final encoded = SyncSnapshotCodec.encode(merged);

    await _repository.uploadSnapshot(userId, encoded);

    final manifest = SyncManifest(
      version: SyncSnapshotCodec.currentVersion,
      updatedAt: DateTime.now().toUtc(),
      deviceId: _repository.getOrCreateDeviceId(),
    );
    await _repository.uploadManifest(userId, manifest);
    await _repository.setLastSync(manifest.updatedAt);
    await _repository.clearPendingChanges();
  }
}

enum SyncPullOutcome {
  noRemote,
  upToDate,
  pulled,
}
