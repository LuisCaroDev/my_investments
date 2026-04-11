enum TransactionType { expense, deposit }

class Transaction {
  final String id;
  final String projectId;
  final String? activityId;
  final String? operationalTaskId;
  final String accountId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.projectId,
    this.activityId,
    this.operationalTaskId,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.date,
    this.description,
    required this.createdAt,
  });

  Transaction copyWith({
    String? id,
    String? projectId,
    String? activityId,
    String? operationalTaskId,
    String? accountId,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      activityId: activityId ?? this.activityId,
      operationalTaskId: operationalTaskId ?? this.operationalTaskId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
