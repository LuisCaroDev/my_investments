import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final ProjectsRepository _repository;
  final String projectId;

  ProjectDetailCubit({
    required ProjectsRepository repository,
    required this.projectId,
  }) : _repository = repository,
       super(const ProjectDetailLoading());

  void load() {
    try {
      final detail = _repository.getProjectDetail(projectId);
      emit(ProjectDetailLoaded(detail: detail));
    } catch (e) {
      emit(ProjectDetailError(message: e.toString()));
    }
  }

  // ── Activities ────────────────────────────────────────────

  Future<void> addActivity(Activity activity) async {
    await _repository.addActivity(activity);
    load();
  }

  Future<void> updateActivity(Activity activity) async {
    await _repository.updateActivity(activity);
    load();
  }

  Future<void> deleteActivity(String activityId) async {
    await _repository.deleteActivity(activityId);
    load();
  }

  // ── Categories ────────────────────────────────────────────

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

  // ── Transactions ──────────────────────────────────────────

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
    load();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _repository.deleteTransaction(transactionId);
    load();
  }
}
