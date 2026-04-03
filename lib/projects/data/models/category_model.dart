import 'package:my_investments/projects/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.projectId,
    super.activityId,
    required super.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
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

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      projectId: entity.projectId,
      activityId: entity.activityId,
      name: entity.name,
    );
  }
}
