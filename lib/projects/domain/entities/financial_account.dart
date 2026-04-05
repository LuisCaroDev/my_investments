enum FinancialAccountType { bank, loan }

class FinancialAccount {
  final String id;
  final String name;
  final FinancialAccountType type;
  final double balance;
  final DateTime createdAt;

  const FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.createdAt,
  });

  FinancialAccount copyWith({
    String? id,
    String? name,
    FinancialAccountType? type,
    double? balance,
    DateTime? createdAt,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
