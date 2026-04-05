import 'package:my_investments/projects/domain/entities/project_summary.dart';

sealed class GoalsState {
  const GoalsState();
}

class GoalsInitial extends GoalsState {
  const GoalsInitial();
}

class GoalsLoading extends GoalsState {
  const GoalsLoading();
}

class GoalsLoaded extends GoalsState {
  final List<ProjectSummary> summaries;
  const GoalsLoaded({required this.summaries});
}

class GoalsError extends GoalsState {
  final String message;
  const GoalsError({required this.message});
}
