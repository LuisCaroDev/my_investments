import 'package:capitalflow/core/storage/sync_change_recorder.dart';
import 'package:capitalflow/planning/data/datasources/planning_local_ds.dart';
import 'package:capitalflow/planning/data/models/activity_model.dart';
import 'package:capitalflow/planning/domain/entities/activity.dart';

class ActivityRepository {
  final PlanningLocalDataSource _localDataSource;
  final SyncChangeRecorder? _changeRecorder;

  ActivityRepository({
    required PlanningLocalDataSource localDataSource,
    SyncChangeRecorder? changeRecorder,
  }) : _localDataSource = localDataSource,
       _changeRecorder = changeRecorder;

  List<Activity> getActivitiesForProject(String projectId) {
    return _localDataSource
        .getActivities()
        .where((activity) => activity.projectId == projectId)
        .toList();
  }

  List<Activity> getAllActivities() {
    return _localDataSource.getActivities();
  }

  Future<void> addActivity(Activity activity) async {
    final activities = _localDataSource.getActivities();
    final model = ActivityModel.fromEntity(activity);
    activities.add(model);
    await _localDataSource.saveActivities(activities);
    await _changeRecorder?.recordChange(
      entity: 'activities',
      op: SyncChangeOp.add,
      id: model.id,
      payload: model.toJson(),
    );
  }

  Future<void> updateActivity(Activity activity) async {
    final activities = _localDataSource.getActivities();
    final index = activities.indexWhere(
      (currentActivity) => currentActivity.id == activity.id,
    );
    if (index == -1) {
      return;
    }

    activities[index] = ActivityModel.fromEntity(activity);
    await _localDataSource.saveActivities(activities);
    await _changeRecorder?.recordChange(
      entity: 'activities',
      op: SyncChangeOp.update,
      id: activity.id,
      payload: activities[index].toJson(),
    );
  }

  Future<void> deleteActivity(String activityId) async {
    final activities = _localDataSource.getActivities();
    activities.removeWhere((activity) => activity.id == activityId);
    await _localDataSource.saveActivities(activities);
    await _changeRecorder?.recordChange(
      entity: 'activities',
      op: SyncChangeOp.delete,
      id: activityId,
    );

    final tasks = _localDataSource.getCategories();
    final removedTasks = tasks
        .where((task) => task.activityId == activityId)
        .toList();
    tasks.removeWhere((task) => task.activityId == activityId);
    await _localDataSource.saveCategories(tasks);
    for (final task in removedTasks) {
      await _changeRecorder?.recordChange(
        entity: 'categories',
        op: SyncChangeOp.delete,
        id: task.id,
      );
    }
  }
}
