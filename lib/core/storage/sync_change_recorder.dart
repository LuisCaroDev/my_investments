enum SyncChangeOp {
  add,
  update,
  delete,
}

abstract class SyncChangeRecorder {
  Future<void> recordChange({
    required String entity,
    required SyncChangeOp op,
    required String id,
    Map<String, dynamic>? payload,
  });
}
