import 'package:my_investments/sync/domain/entities/pending_change.dart';

class PendingChangesApplier {
  static Map<String, List<Map<String, dynamic>>> apply(
    Map<String, List<Map<String, dynamic>>> snapshot,
    List<PendingChange> changes,
  ) {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final entry in snapshot.entries) {
      result[entry.key] = entry.value.map((e) => Map.of(e)).toList();
    }

    for (final change in changes) {
      final list = result[change.entity] ?? <Map<String, dynamic>>[];
      final index = list.indexWhere(
        (item) => item['id']?.toString() == change.id,
      );

      switch (change.op) {
        case PendingChangeOp.add:
          if (change.payload == null) break;
          if (index == -1) {
            list.add(Map.of(change.payload!));
          } else {
            list[index] = Map.of(change.payload!);
          }
          break;
        case PendingChangeOp.update:
          if (change.payload == null) break;
          if (index == -1) {
            list.add(Map.of(change.payload!));
          } else {
            list[index] = Map.of(change.payload!);
          }
          break;
        case PendingChangeOp.delete:
          if (index != -1) {
            list.removeAt(index);
          }
          break;
      }

      result[change.entity] = list;
    }

    return result;
  }
}
