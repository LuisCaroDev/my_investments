enum PendingChangeOp {
  add,
  update,
  delete,
}

class PendingChange {
  final PendingChangeOp op;
  final String entity;
  final String id;
  final Map<String, dynamic>? payload;
  final DateTime timestamp;

  const PendingChange({
    required this.op,
    required this.entity,
    required this.id,
    required this.timestamp,
    this.payload,
  });

  factory PendingChange.fromJson(Map<String, dynamic> json) {
    return PendingChange(
      op: PendingChangeOp.values.byName(json['op'] as String),
      entity: json['entity'] as String,
      id: json['id'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'op': op.name,
      'entity': entity,
      'id': id,
      if (payload != null) 'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
