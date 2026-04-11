import 'package:my_investments/planning/domain/entities/operational_task.dart';

class OperationalTaskModel extends OperationalTask {
  const OperationalTaskModel({
    required super.id,
    required super.projectId,
    super.activityId,
    required super.name,
  });

  factory OperationalTaskModel.fromJson(Map<String, dynamic> json) {
    return OperationalTaskModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      activityId: json['activityId'] as String?,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'activityId': activityId,
      'name': name,
    };
  }

  factory OperationalTaskModel.fromEntity(OperationalTask entity) {
    return OperationalTaskModel(
      id: entity.id,
      projectId: entity.projectId,
      activityId: entity.activityId,
      name: entity.name,
    );
  }
}
