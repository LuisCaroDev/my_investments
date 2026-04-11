import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/planning/presentation/bloc/goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final PlanningRepository _repository;
  final AccountsRepository _accountsRepository;

  GoalsCubit({
    required PlanningRepository repository,
    required AccountsRepository accountsRepository,
  }) : _repository = repository,
       _accountsRepository = accountsRepository,
       super(const GoalsInitial());

  void loadGoals() {
    emit(const GoalsLoading());
    try {
      final summaries = _repository.getGoalSummaries();
      emit(GoalsLoaded(summaries: summaries));
    } catch (e) {
      emit(GoalsError(message: e.toString()));
    }
  }

  Future<void> addGoal(Project project) async {
    await _repository.addGoal(project);
    loadGoals();
  }

  Future<void> updateGoal(Project project) async {
    await _repository.updateGoal(project);
    loadGoals();
  }

  Future<void> deleteGoal(String projectId) async {
    await _repository.deleteGoal(projectId);
    await _accountsRepository.deleteTransactionsForProject(projectId);
    loadGoals();
  }

  Future<void> reorderGoals(List<String> orderedIds) async {
    await _repository.reorderGoals(orderedIds);
    loadGoals();
  }
}
