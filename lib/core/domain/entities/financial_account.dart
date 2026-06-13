enum FinancialAccountType { bank, loan }

class FinancialAccount {
  final String id;
  final String name;
  final FinancialAccountType type;
  final int balanceCents;
  final DateTime createdAt;

  const FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balanceCents,
    required this.createdAt,
  });

  FinancialAccount copyWith({
    String? id,
    String? name,
    FinancialAccountType? type,
    int? balanceCents,
    DateTime? createdAt,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balanceCents: balanceCents ?? this.balanceCents,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
