import 'package:my_investments/projects/domain/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.projectId,
    required super.name,
    super.description,
    super.year,
    super.budget,
    required super.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      year: json['year'] as int?,
      budget: (json['budget'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'year': year,
      'budget': budget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActivityModel.fromEntity(Activity entity) {
    return ActivityModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      description: entity.description,
      year: entity.year,
      budget: entity.budget,
      createdAt: entity.createdAt,
    );
  }
}
