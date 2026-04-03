import 'package:my_investments/projects/domain/entities/category.dart';

sealed class CategoryManagementState {
  const CategoryManagementState();
}

class CategoryManagementLoading extends CategoryManagementState {
  const CategoryManagementLoading();
}

class CategoryManagementLoaded extends CategoryManagementState {
  final List<Category> projectCategories;
  final List<Category> activityCategories;

  const CategoryManagementLoaded({
    required this.projectCategories,
    required this.activityCategories,
  });
}

class CategoryManagementError extends CategoryManagementState {
  final String message;

  const CategoryManagementError({required this.message});
}
