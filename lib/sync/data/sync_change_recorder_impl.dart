import 'package:flutter/foundation.dart';
import 'package:my_investments/core/storage/sync_change_recorder.dart';
import 'package:my_investments/sync/data/datasources/sync_local_ds.dart';
import 'package:my_investments/sync/domain/entities/pending_change.dart';

class SyncChangeRecorderImpl implements SyncChangeRecorder {
  final SyncLocalDataSource _local;
  final VoidCallback? _onChange;

  const SyncChangeRecorderImpl({
    required SyncLocalDataSource local,
    VoidCallback? onChange,
  })  : _local = local,
        _onChange = onChange;

  @override
  Future<void> recordChange({
    required String entity,
    required SyncChangeOp op,
    required String id,
    Map<String, dynamic>? payload,
  }) async {
    await _local.addPendingChange(
      PendingChange(
        op: PendingChangeOp.values.byName(op.name),
        entity: entity,
        id: id,
        payload: payload,
        timestamp: DateTime.now().toUtc(),
      ),
    );
    _onChange?.call();
  }
}
