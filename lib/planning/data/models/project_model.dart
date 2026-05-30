import 'package:my_investments/planning/domain/entities/project.dart';

class ProjectModel extends Project {
  final double? cachedTotalSpent;
  final double? cachedFundedAmount;
  final double? cachedRemainingToFund;

  const ProjectModel({
    required super.id,
    required super.name,
    super.description,
    super.globalBudget,
    super.type = ProjectType.investment,
    super.priority = 0,
    required super.createdAt,
    this.cachedTotalSpent,
    this.cachedFundedAmount,
    this.cachedRemainingToFund,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      globalBudget: (json['globalBudget'] as num?)?.toDouble(),
      type: ProjectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProjectType.investment,
      ),
      priority: json['priority'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      cachedTotalSpent: (json['cachedTotalSpent'] as num?)?.toDouble(),
      cachedFundedAmount: (json['cachedFundedAmount'] as num?)?.toDouble(),
      cachedRemainingToFund: (json['cachedRemainingToFund'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'globalBudget': globalBudget,
      'type': type.name,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'cachedTotalSpent': cachedTotalSpent,
      'cachedFundedAmount': cachedFundedAmount,
      'cachedRemainingToFund': cachedRemainingToFund,
    };
  }

  factory ProjectModel.fromEntity(Project entity) {
    if (entity is ProjectModel) {
      return ProjectModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        globalBudget: entity.globalBudget,
        type: entity.type,
        priority: entity.priority,
        createdAt: entity.createdAt,
        cachedTotalSpent: entity.cachedTotalSpent,
        cachedFundedAmount: entity.cachedFundedAmount,
        cachedRemainingToFund: entity.cachedRemainingToFund,
      );
    }
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      globalBudget: entity.globalBudget,
      type: entity.type,
      priority: entity.priority,
      createdAt: entity.createdAt,
    );
  }
}
