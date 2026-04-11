class Activity {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final int? year;
  final double? budget;
  final DateTime createdAt;

  const Activity({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.year,
    this.budget,
    required this.createdAt,
  });

  Activity copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    int? year,
    double? budget,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      year: year ?? this.year,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
