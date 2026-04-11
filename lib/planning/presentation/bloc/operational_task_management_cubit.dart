import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart';
import 'package:my_investments/planning/presentation/bloc/operational_task_management_state.dart';

class OperationalTaskManagementCubit
    extends Cubit<OperationalTaskManagementState> {
  final PlanningRepository _repository;
  final String projectId;
  final String? activityId;

  OperationalTaskManagementCubit({
    required PlanningRepository repository,
    required this.projectId,
    this.activityId,
  }) : _repository = repository,
       super(const OperationalTaskManagementLoading());

  void load() {
    try {
      final projectOperationalTasks =
          _repository.getProjectOperationalTasks(projectId);
      final activityOperationalTasks = activityId != null
          ? _repository.getActivityOperationalTasks(activityId!)
          : <OperationalTask>[];

      emit(
        OperationalTaskManagementLoaded(
          projectOperationalTasks: projectOperationalTasks,
          activityOperationalTasks: activityOperationalTasks,
        ),
      );
    } catch (e) {
      emit(OperationalTaskManagementError(message: e.toString()));
    }
  }

  Future<void> addOperationalTask(OperationalTask task) async {
    await _repository.addOperationalTask(task);
    load();
  }

  Future<void> updateOperationalTask(OperationalTask task) async {
    await _repository.updateOperationalTask(task);
    load();
  }

  Future<void> deleteOperationalTask(String taskId) async {
    await _repository.deleteOperationalTask(taskId);
    load();
  }
}
