import 'package:my_investments/projects/domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    super.description,
    super.globalBudget,
    required super.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      globalBudget: (json['globalBudget'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'globalBudget': globalBudget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProjectModel.fromEntity(Project entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      globalBudget: entity.globalBudget,
      createdAt: entity.createdAt,
    );
  }
}
