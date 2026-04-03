class Category {
  final String id;
  final String projectId;
  final String? activityId;
  final String name;

  const Category({
    required this.id,
    required this.projectId,
    this.activityId,
    required this.name,
  });

  Category copyWith({
    String? id,
    String? projectId,
    String? activityId,
    String? name,
  }) {
    return Category(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      activityId: activityId ?? this.activityId,
      name: name ?? this.name,
    );
  }
}
