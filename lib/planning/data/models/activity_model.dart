import 'package:capitalflow/planning/domain/entities/activity.dart';

class ActivityModel extends Activity {
  final int? cachedSpentCents;
  final int? cachedDepositedCents;
  final int? cachedFundedAmountCents;

  const ActivityModel({
    required super.id,
    required super.projectId,
    required super.name,
    super.description,
    super.year,
    super.budgetCents,
    super.autoUpdateBudget = false,
    required super.createdAt,
    this.cachedSpentCents,
    this.cachedDepositedCents,
    this.cachedFundedAmountCents,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      year: json['year'] as int?,
      budgetCents: json['budget_cents'] as int?,
      autoUpdateBudget: json['autoUpdateBudget'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      cachedSpentCents: json['cachedSpent_cents'] as int?,
      cachedDepositedCents: json['cachedDeposited_cents'] as int?,
      cachedFundedAmountCents: json['cachedFundedAmount_cents'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'year': year,
      'budget_cents': budgetCents,
      'autoUpdateBudget': autoUpdateBudget,
      'createdAt': createdAt.toIso8601String(),
      'cachedSpent_cents': cachedSpentCents,
      'cachedDeposited_cents': cachedDepositedCents,
      'cachedFundedAmount_cents': cachedFundedAmountCents,
    };
  }

  factory ActivityModel.fromEntity(Activity entity) {
    if (entity is ActivityModel) {
      return ActivityModel(
        id: entity.id,
        projectId: entity.projectId,
        name: entity.name,
        description: entity.description,
        year: entity.year,
        budgetCents: entity.budgetCents,
        autoUpdateBudget: entity.autoUpdateBudget,
        createdAt: entity.createdAt,
        cachedSpentCents: entity.cachedSpentCents,
        cachedDepositedCents: entity.cachedDepositedCents,
        cachedFundedAmountCents: entity.cachedFundedAmountCents,
      );
    }
    return ActivityModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      description: entity.description,
      year: entity.year,
      budgetCents: entity.budgetCents,
      autoUpdateBudget: entity.autoUpdateBudget,
      createdAt: entity.createdAt,
    );
  }
}
