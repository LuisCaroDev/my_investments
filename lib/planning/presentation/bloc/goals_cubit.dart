import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/data/repositories/project_repository.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/planning/data/services/planning_detail_query_service.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/planning/presentation/bloc/goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final ProjectRepository _projectRepository;
  final PlanningDetailQueryService _detailQueryService;
  final AccountsRepository _accountsRepository;
  final PlanningLocalDataSource _planningLocalDataSource;
  StreamSubscription? _subscription;

  GoalsCubit({
    required ProjectRepository projectRepository,
    required PlanningDetailQueryService detailQueryService,
    required AccountsRepository accountsRepository,
    required PlanningLocalDataSource planningLocalDataSource,
  }) : _projectRepository = projectRepository,
       _detailQueryService = detailQueryService,
       _accountsRepository = accountsRepository,
       _planningLocalDataSource = planningLocalDataSource,
       super(const GoalsInitial()) {
    _subscription = _planningLocalDataSource.projectsStream.listen((_) {
      loadGoals();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

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
  }

  Future<void> updateGoal(Project project) async {
    await _projectRepository.updateProject(project);
  }

  Future<void> deleteGoal(String projectId) async {
    await _projectRepository.deleteProjectDataAndCascade(projectId);
    await _accountsRepository.deleteTransactionsForProject(projectId);
  }

  Future<void> reorderGoals(List<String> orderedIds) async {
    await _projectRepository.reorderProjects(orderedIds);
  }
}
