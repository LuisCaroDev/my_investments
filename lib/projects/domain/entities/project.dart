enum ProjectType { investment, savingsGoal }

class Project {
  final String id;
  final String name;
  final String? description;
  final double? globalBudget;
  final ProjectType type;
  final int priority;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.globalBudget,
    this.type = ProjectType.investment,
    this.priority = 0,
    required this.createdAt,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    double? globalBudget,
    ProjectType? type,
    int? priority,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      globalBudget: globalBudget ?? this.globalBudget,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
