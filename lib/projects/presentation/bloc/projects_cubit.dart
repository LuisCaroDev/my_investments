import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsRepository _repository;

  ProjectsCubit({required ProjectsRepository repository})
    : _repository = repository,
      super(const ProjectsInitial());

  void loadProjects() {
    emit(const ProjectsLoading());
    try {
      final projects = _repository.getProjects();

      // Calculate summary for each project
      final summaries = projects.map((project) {
        final allTransactions = _repository.getTransactionsForProject(
          project.id,
        );
        final activities = _repository.getActivitiesForProject(project.id);

        final totalSpent = allTransactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);
        final totalDeposited = allTransactions
            .where((t) => t.type == TransactionType.deposit)
            .fold(0.0, (sum, t) => sum + t.amount);
        final totalCapitalInjected = allTransactions
            .where((t) => t.type == TransactionType.capitalInjection)
            .fold(0.0, (sum, t) => sum + t.amount);

        final totalBudget =
            project.globalBudget ??
            activities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));

        return ProjectSummary(
          project: project,
          totalBudget: totalBudget,
          totalSpent: totalSpent,
          totalDeposited: totalDeposited,
          totalCapitalInjected: totalCapitalInjected,
          activityCount: activities.length,
        );
      }).toList();

      emit(ProjectsLoaded(summaries: summaries));
    } catch (e) {
      emit(ProjectsError(message: e.toString()));
    }
  }

  Future<void> addProject(Project project) async {
    await _repository.addProject(project);
    loadProjects();
  }

  Future<void> updateProject(Project project) async {
    await _repository.updateProject(project);
    loadProjects();
  }

  Future<void> deleteProject(String projectId) async {
    await _repository.deleteProject(projectId);
    loadProjects();
  }
}
