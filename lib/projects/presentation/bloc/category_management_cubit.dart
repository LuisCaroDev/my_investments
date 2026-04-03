import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/presentation/bloc/category_management_state.dart';

class CategoryManagementCubit extends Cubit<CategoryManagementState> {
  final ProjectsRepository _repository;
  final String projectId;
  final String? activityId;

  CategoryManagementCubit({
    required ProjectsRepository repository,
    required this.projectId,
    this.activityId,
  }) : _repository = repository,
       super(const CategoryManagementLoading());

  void load() {
    try {
      final projectCategories = _repository.getProjectCategories(projectId);
      final activityCategories = activityId != null
          ? _repository.getActivityCategories(activityId!)
          : <Category>[];

      emit(
        CategoryManagementLoaded(
          projectCategories: projectCategories,
          activityCategories: activityCategories,
        ),
      );
    } catch (e) {
      emit(CategoryManagementError(message: e.toString()));
    }
  }

  Future<void> addCategory(Category category) async {
    await _repository.addCategory(category);
    load();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    load();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    load();
  }
}
