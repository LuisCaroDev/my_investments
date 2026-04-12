import 'package:my_investments/core/storage/sync_snapshot_provider.dart';

class SyncSnapshotMerger {
  static Map<String, List<Map<String, dynamic>>> mergeProviders(
    List<SyncSnapshotProvider> providers,
  ) {
    final merged = <String, List<Map<String, dynamic>>>{};
    for (final provider in providers) {
      final snapshot = provider.exportSnapshot();
      for (final entry in snapshot.entries) {
        merged[entry.key] = [
          ...?merged[entry.key],
          ...entry.value,
        ];
      }
    }
    return merged;
  }
}
