/// Operational task/step within a project/activity (not accounting taxonomy).
class OperationalTask {
  final String id;
  final String projectId;
  final String? activityId;
  final String name;

  const OperationalTask({
    required this.id,
    required this.projectId,
    this.activityId,
    required this.name,
  });

  OperationalTask copyWith({
    String? id,
    String? projectId,
    String? activityId,
    String? name,
  }) {
    return OperationalTask(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      activityId: activityId ?? this.activityId,
      name: name ?? this.name,
    );
  }
}
