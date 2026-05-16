import 'package:my_investments/core/storage/sync_change_recorder.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/planning/data/models/project_model.dart';
import 'package:my_investments/planning/domain/entities/project.dart';

class ProjectRepository {
  final PlanningLocalDataSource _localDataSource;
  final SyncChangeRecorder? _changeRecorder;

  ProjectRepository({
    required PlanningLocalDataSource localDataSource,
    SyncChangeRecorder? changeRecorder,
  }) : _localDataSource = localDataSource,
       _changeRecorder = changeRecorder;

  Future<void> addProject(Project project, {required ProjectType type}) async {
    final typedProject = project.copyWith(type: type);
    final projects = _localDataSource.getProjects();
    final initialMaxPriority = _initialMaxPriority(type);
    final maxPriority = projects
        .where((currentProject) => currentProject.type == type)
        .fold(
          initialMaxPriority,
          (max, currentProject) =>
              currentProject.priority > max ? currentProject.priority : max,
        );

    final model = ProjectModel.fromEntity(
      typedProject.copyWith(priority: maxPriority + 1),
    );
    projects.add(model);
    await _localDataSource.saveProjects(projects);
    await _changeRecorder?.recordChange(
      entity: 'projects',
      op: SyncChangeOp.add,
      id: model.id,
      payload: model.toJson(),
    );
  }

  Future<void> updateProject(Project project) async {
    final projects = _localDataSource.getProjects();
    final index = projects.indexWhere(
      (currentProject) => currentProject.id == project.id,
    );
    if (index == -1) {
      return;
    }

    projects[index] = ProjectModel.fromEntity(project);
    await _localDataSource.saveProjects(projects);
    await _changeRecorder?.recordChange(
      entity: 'projects',
      op: SyncChangeOp.update,
      id: project.id,
      payload: projects[index].toJson(),
    );
  }

  Future<void> deleteProjectDataAndCascade(String projectId) async {
    final projects = _localDataSource.getProjects();
    projects.removeWhere((project) => project.id == projectId);
    await _localDataSource.saveProjects(projects);
    await _changeRecorder?.recordChange(
      entity: 'projects',
      op: SyncChangeOp.delete,
      id: projectId,
    );

    final activities = _localDataSource.getActivities();
    final removedActivities = activities
        .where((activity) => activity.projectId == projectId)
        .toList();
    activities.removeWhere((activity) => activity.projectId == projectId);
    await _localDataSource.saveActivities(activities);
    for (final activity in removedActivities) {
      await _changeRecorder?.recordChange(
        entity: 'activities',
        op: SyncChangeOp.delete,
        id: activity.id,
      );
    }

    final tasks = _localDataSource.getCategories();
    final removedTasks = tasks
        .where((task) => task.projectId == projectId)
        .toList();
    tasks.removeWhere((task) => task.projectId == projectId);
    await _localDataSource.saveCategories(tasks);
    for (final task in removedTasks) {
      await _changeRecorder?.recordChange(
        entity: 'categories',
        op: SyncChangeOp.delete,
        id: task.id,
      );
    }
  }

  Future<void> reorderProjects(List<String> orderedIds) async {
    final projects = _localDataSource.getProjects();
    for (var index = 0; index < orderedIds.length; index++) {
      final projectId = orderedIds[index];
      final projectIndex = projects.indexWhere(
        (project) => project.id == projectId,
      );
      if (projectIndex == -1) {
        continue;
      }

      projects[projectIndex] = ProjectModel.fromEntity(
        projects[projectIndex].copyWith(priority: index),
      );
      await _changeRecorder?.recordChange(
        entity: 'projects',
        op: SyncChangeOp.update,
        id: projects[projectIndex].id,
        payload: projects[projectIndex].toJson(),
      );
    }

    await _localDataSource.saveProjects(projects);
  }

  int _initialMaxPriority(ProjectType type) {
    return switch (type) {
      ProjectType.investment => 0,
      ProjectType.savingsGoal => -1,
    };
  }
}
