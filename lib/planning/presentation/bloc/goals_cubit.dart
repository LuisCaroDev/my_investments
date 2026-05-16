import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/data/repositories/project_repository.dart';
import 'package:my_investments/planning/data/services/planning_detail_query_service.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/planning/presentation/bloc/goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final ProjectRepository _projectRepository;
  final PlanningDetailQueryService _detailQueryService;
  final AccountsRepository _accountsRepository;

  GoalsCubit({
    required ProjectRepository projectRepository,
    required PlanningDetailQueryService detailQueryService,
    required AccountsRepository accountsRepository,
  }) : _projectRepository = projectRepository,
       _detailQueryService = detailQueryService,
       _accountsRepository = accountsRepository,
       super(const GoalsInitial());

  void loadGoals() {
    emit(const GoalsLoading());
    try {
      final summaries = _detailQueryService.getProjectSummaries(
        ProjectType.savingsGoal,
      );
      emit(GoalsLoaded(summaries: summaries));
    } catch (e) {
      emit(GoalsError(message: e.toString()));
    }
  }

  Future<void> addGoal(Project project) async {
    await _projectRepository.addProject(project, type: ProjectType.savingsGoal);
    loadGoals();
  }

  Future<void> updateGoal(Project project) async {
    await _projectRepository.updateProject(project);
    loadGoals();
  }

  Future<void> deleteGoal(String projectId) async {
    await _projectRepository.deleteProjectDataAndCascade(projectId);
    await _accountsRepository.deleteTransactionsForProject(projectId);
    loadGoals();
  }

  Future<void> reorderGoals(List<String> orderedIds) async {
    await _projectRepository.reorderProjects(orderedIds);
    loadGoals();
  }
}
