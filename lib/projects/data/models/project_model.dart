import 'package:my_investments/projects/domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    super.description,
    super.globalBudget,
    super.type = ProjectType.investment,
    super.priority = 0,
    required super.createdAt,
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
    };
  }

  factory ProjectModel.fromEntity(Project entity) {
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
