import 'package:my_investments/core/storage/sync_change_recorder.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/planning/data/models/operational_task_model.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart';

class OperationalTaskRepository {
  final PlanningLocalDataSource _localDataSource;
  final SyncChangeRecorder? _changeRecorder;

  OperationalTaskRepository({
    required PlanningLocalDataSource localDataSource,
    SyncChangeRecorder? changeRecorder,
  }) : _localDataSource = localDataSource,
       _changeRecorder = changeRecorder;

  List<OperationalTask> getProjectOperationalTasks(String projectId) {
    return _localDataSource
        .getCategories()
        .where((task) => task.projectId == projectId && task.activityId == null)
        .toList();
  }

  List<OperationalTask> getAllOperationalTasks() {
    return _localDataSource.getCategories();
  }

  List<OperationalTask> getActivityOperationalTasks(String activityId) {
    return _localDataSource
        .getCategories()
        .where((task) => task.activityId == activityId)
        .toList();
  }

  List<OperationalTask> getAvailableOperationalTasks(
    String projectId,
    String activityId,
  ) {
    return _localDataSource
        .getCategories()
        .where(
          (task) =>
              task.activityId == activityId ||
              (task.projectId == projectId && task.activityId == null),
        )
        .toList();
  }

  Future<void> addOperationalTask(OperationalTask task) async {
    final tasks = _localDataSource.getCategories();
    final model = OperationalTaskModel.fromEntity(task);
    tasks.add(model);
    await _localDataSource.saveCategories(tasks);
    await _changeRecorder?.recordChange(
      entity: 'categories',
      op: SyncChangeOp.add,
      id: model.id,
      payload: model.toJson(),
    );
  }

  Future<void> updateOperationalTask(OperationalTask task) async {
    final tasks = _localDataSource.getCategories();
    final index = tasks.indexWhere((currentTask) => currentTask.id == task.id);
    if (index == -1) {
      return;
    }

    tasks[index] = OperationalTaskModel.fromEntity(task);
    await _localDataSource.saveCategories(tasks);
    await _changeRecorder?.recordChange(
      entity: 'categories',
      op: SyncChangeOp.update,
      id: task.id,
      payload: tasks[index].toJson(),
    );
  }

  Future<void> deleteOperationalTask(String taskId) async {
    final tasks = _localDataSource.getCategories();
    tasks.removeWhere((task) => task.id == taskId);
    await _localDataSource.saveCategories(tasks);
    await _changeRecorder?.recordChange(
      entity: 'categories',
      op: SyncChangeOp.delete,
      id: taskId,
    );
  }
}
