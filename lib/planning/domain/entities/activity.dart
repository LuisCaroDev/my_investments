class Activity {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final int? year;
  final int? budgetCents;
  final bool autoUpdateBudget;
  final DateTime createdAt;

  const Activity({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.year,
    this.budgetCents,
    this.autoUpdateBudget = false,
    required this.createdAt,
  });

  Activity copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    int? year,
    int? budgetCents,
    bool? autoUpdateBudget,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      year: year ?? this.year,
      budgetCents: budgetCents ?? this.budgetCents,
      autoUpdateBudget: autoUpdateBudget ?? this.autoUpdateBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
