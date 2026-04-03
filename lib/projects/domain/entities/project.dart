class Project {
  final String id;
  final String name;
  final String? description;
  final double? globalBudget;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.globalBudget,
    required this.createdAt,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    double? globalBudget,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      globalBudget: globalBudget ?? this.globalBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
