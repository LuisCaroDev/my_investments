import 'package:capitalflow/accounts/domain/entities/financial_account.dart';

class FinancialAccountModel extends FinancialAccount {
  const FinancialAccountModel({
    required super.id,
    required super.name,
    required super.type,
    required super.balanceCents,
    required super.createdAt,
  });

  factory FinancialAccountModel.fromJson(Map<String, dynamic> json) {
    return FinancialAccountModel(
      id: json['id'],
      name: json['name'],
      type: FinancialAccountType.values.byName(json['type'] as String),
      balanceCents: json['balance_cents'] as int,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance_cents': balanceCents,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FinancialAccountModel.fromEntity(FinancialAccount entity) {
    return FinancialAccountModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      balanceCents: entity.balanceCents,
      createdAt: entity.createdAt,
    );
  }
}
