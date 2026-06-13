import 'package:capitalflow/planning/domain/entities/activity.dart';

class ActivityModel extends Activity {
  final double? cachedSpent;
  final double? cachedDeposited;
  final double? cachedFundedAmount;

  const ActivityModel({
    required super.id,
    required super.projectId,
    required super.name,
    super.description,
    super.year,
    super.budget,
    super.autoUpdateBudget = false,
    required super.createdAt,
    this.cachedSpent,
    this.cachedDeposited,
    this.cachedFundedAmount,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      year: json['year'] as int?,
      budget: (json['budget'] as num?)?.toDouble(),
      autoUpdateBudget: json['autoUpdateBudget'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      cachedSpent: (json['cachedSpent'] as num?)?.toDouble(),
      cachedDeposited: (json['cachedDeposited'] as num?)?.toDouble(),
      cachedFundedAmount: (json['cachedFundedAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'year': year,
      'budget': budget,
      'autoUpdateBudget': autoUpdateBudget,
      'createdAt': createdAt.toIso8601String(),
      'cachedSpent': cachedSpent,
      'cachedDeposited': cachedDeposited,
      'cachedFundedAmount': cachedFundedAmount,
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
        budget: entity.budget,
        autoUpdateBudget: entity.autoUpdateBudget,
        createdAt: entity.createdAt,
        cachedSpent: entity.cachedSpent,
        cachedDeposited: entity.cachedDeposited,
        cachedFundedAmount: entity.cachedFundedAmount,
      );
    }
    return ActivityModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      description: entity.description,
      year: entity.year,
      budget: entity.budget,
      autoUpdateBudget: entity.autoUpdateBudget,
      createdAt: entity.createdAt,
    );
  }
}
