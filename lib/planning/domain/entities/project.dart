enum ProjectType { investment, savingsGoal }

class Project {
  final String id;
  final String name;
  final String? description;
  final int? globalBudgetCents;
  final ProjectType type;
  final int priority;
  final bool autoUpdateBudget;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.globalBudgetCents,
    this.type = ProjectType.investment,
    this.priority = 0,
    this.autoUpdateBudget = false,
    required this.createdAt,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    int? globalBudgetCents,
    ProjectType? type,
    int? priority,
    bool? autoUpdateBudget,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      globalBudgetCents: globalBudgetCents ?? this.globalBudgetCents,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      autoUpdateBudget: autoUpdateBudget ?? this.autoUpdateBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
