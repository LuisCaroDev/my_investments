import 'package:capitalflow/planning/domain/entities/project.dart';

class ProjectModel extends Project {
  final int? cachedTotalSpentCents;
  final int? cachedFundedAmountCents;
  final int? cachedRemainingToFundCents;

  const ProjectModel({
    required super.id,
    required super.name,
    super.description,
    super.globalBudgetCents,
    super.type = ProjectType.investment,
    super.priority = 0,
    super.autoUpdateBudget = false,
    required super.createdAt,
    this.cachedTotalSpentCents,
    this.cachedFundedAmountCents,
    this.cachedRemainingToFundCents,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      globalBudgetCents: json['globalBudget_cents'] as int?,
      type: ProjectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProjectType.investment,
      ),
      priority: json['priority'] as int? ?? 0,
      autoUpdateBudget: json['autoUpdateBudget'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      cachedTotalSpentCents: json['cachedTotalSpent_cents'] as int?,
      cachedFundedAmountCents: json['cachedFundedAmount_cents'] as int?,
      cachedRemainingToFundCents: json['cachedRemainingToFund_cents'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'globalBudget_cents': globalBudgetCents,
      'type': type.name,
      'priority': priority,
      'autoUpdateBudget': autoUpdateBudget,
      'createdAt': createdAt.toIso8601String(),
      'cachedTotalSpent_cents': cachedTotalSpentCents,
      'cachedFundedAmount_cents': cachedFundedAmountCents,
      'cachedRemainingToFund_cents': cachedRemainingToFundCents,
    };
  }

  factory ProjectModel.fromEntity(Project entity) {
    if (entity is ProjectModel) {
      return ProjectModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        globalBudgetCents: entity.globalBudgetCents,
        type: entity.type,
        priority: entity.priority,
        autoUpdateBudget: entity.autoUpdateBudget,
        createdAt: entity.createdAt,
        cachedTotalSpentCents: entity.cachedTotalSpentCents,
        cachedFundedAmountCents: entity.cachedFundedAmountCents,
        cachedRemainingToFundCents: entity.cachedRemainingToFundCents,
      );
    }
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      globalBudgetCents: entity.globalBudgetCents,
      type: entity.type,
      priority: entity.priority,
      autoUpdateBudget: entity.autoUpdateBudget,
      createdAt: entity.createdAt,
    );
  }
}
