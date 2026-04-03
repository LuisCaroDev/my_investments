import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final ProjectsRepository _repository;
  final String projectId;
  String? _selectedCategoryId;

  ProjectDetailCubit({
    required ProjectsRepository repository,
    required this.projectId,
  }) : _repository = repository,
       super(const ProjectDetailLoading());

  void load() {
    try {
      final projects = _repository.getProjects();
      final project = projects.firstWhere((p) => p.id == projectId);
      final activities = _repository.getActivitiesForProject(projectId);
      final allTransactions = _repository.getTransactionsForProject(projectId);
      final projectCategories = _repository.getProjectCategories(projectId);

      // Build activity summaries
      final activitySummaries = activities.map((activity) {
        final activityTransactions = allTransactions
            .where((t) => t.activityId == activity.id)
            .toList();
        final spent = activityTransactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);
        final deposited = activityTransactions
            .where((t) => t.type == TransactionType.deposit)
            .fold(0.0, (sum, t) => sum + t.amount);
        final categories = _repository.getActivityCategories(activity.id);

        return ActivitySummary(
          activity: activity,
          spent: spent,
          deposited: deposited,
          categories: categories,
          transactionCount: activityTransactions.length,
        );
      }).toList();

      // Project-level transactions (no activity)
      final projectLevelTransactions = _repository.getProjectLevelTransactions(
        projectId,
      );

      final totalSpent = allTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalDeposited = allTransactions
          .where((t) => t.type == TransactionType.deposit)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalBudget =
          project.globalBudget ??
          activities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));

      emit(
        ProjectDetailLoaded(
          project: project,
          activitySummaries: activitySummaries,
          projectLevelTransactions: projectLevelTransactions,
          projectCategories: projectCategories,
          selectedCategoryId: _selectedCategoryId,
          totalBudget: totalBudget,
          totalSpent: totalSpent,
          totalDeposited: totalDeposited,
        ),
      );
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

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    load();
  }
}
