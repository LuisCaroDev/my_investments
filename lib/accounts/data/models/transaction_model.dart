import 'package:capitalflow/accounts/domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.projectId,
    super.activityId,
    super.operationalTaskId,
    required super.accountId,
    required super.type,
    required super.amountCents,
    required super.date,
    super.description,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // For migration: if type is 'capitalInjection' (legacy), convert to 'deposit'
    final rawType = json['type'] as String;
    final type = rawType == 'capitalInjection'
        ? TransactionType.deposit
        : TransactionType.values.byName(rawType);

    return TransactionModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      activityId: json['activityId'] as String?,
      operationalTaskId: json['categoryId'] as String?,
      accountId: json['accountId'] as String? ?? 'initial_statement',
      type: type,
      amountCents: json['amount_cents'] as int,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'activityId': activityId,
      'categoryId': operationalTaskId,
      'accountId': accountId,
      'type': type.name,
      'amount_cents': amountCents,
      'date': date.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      projectId: entity.projectId,
      activityId: entity.activityId,
      operationalTaskId: entity.operationalTaskId,
      accountId: entity.accountId,
      type: entity.type,
      amountCents: entity.amountCents,
      date: entity.date,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}
