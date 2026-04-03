import 'package:my_investments/projects/domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.projectId,
    super.activityId,
    super.categoryId,
    required super.type,
    required super.amount,
    required super.date,
    super.description,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      activityId: json['activityId'] as String?,
      categoryId: json['categoryId'] as String?,
      type: TransactionType.values.byName(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
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
      'categoryId': categoryId,
      'type': type.name,
      'amount': amount,
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
      categoryId: entity.categoryId,
      type: entity.type,
      amount: entity.amount,
      date: entity.date,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}
