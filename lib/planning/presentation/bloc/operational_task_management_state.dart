import 'package:my_investments/planning/domain/entities/operational_task.dart';

sealed class OperationalTaskManagementState {
  const OperationalTaskManagementState();
}

class OperationalTaskManagementLoading extends OperationalTaskManagementState {
  const OperationalTaskManagementLoading();
}

class OperationalTaskManagementLoaded extends OperationalTaskManagementState {
  final List<OperationalTask> projectOperationalTasks;
  final List<OperationalTask> activityOperationalTasks;

  const OperationalTaskManagementLoaded({
    required this.projectOperationalTasks,
    required this.activityOperationalTasks,
  });
}

class OperationalTaskManagementError extends OperationalTaskManagementState {
  final String message;

  const OperationalTaskManagementError({required this.message});
}
