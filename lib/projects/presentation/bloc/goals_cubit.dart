import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/presentation/bloc/goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final ProjectsRepository _repository;

  GoalsCubit({required ProjectsRepository repository})
    : _repository = repository,
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
    loadGoals();
  }

  Future<void> reorderGoals(List<String> orderedIds) async {
    await _repository.reorderGoals(orderedIds);
    loadGoals();
  }
}
