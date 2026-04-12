abstract class SyncSnapshotProvider {
  Map<String, List<Map<String, dynamic>>> exportSnapshot();

  Future<void> importSnapshot(Map<String, List<Map<String, dynamic>>> data);
}
