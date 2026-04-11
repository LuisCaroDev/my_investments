import 'package:my_investments/accounts/domain/entities/financial_account.dart';

class FinancialAccountModel extends FinancialAccount {
  const FinancialAccountModel({
    required super.id,
    required super.name,
    required super.type,
    required super.balance,
    required super.createdAt,
  });

  factory FinancialAccountModel.fromJson(Map<String, dynamic> json) {
    return FinancialAccountModel(
      id: json['id'],
      name: json['name'],
      type: FinancialAccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FinancialAccountType.bank,
      ),
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FinancialAccountModel.fromEntity(FinancialAccount entity) {
    return FinancialAccountModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      balance: entity.balance,
      createdAt: entity.createdAt,
    );
  }
}
