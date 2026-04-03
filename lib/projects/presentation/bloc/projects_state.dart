import 'package:my_investments/projects/domain/entities/project.dart';

sealed class ProjectsState {
  const ProjectsState();
}

class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

class ProjectsLoaded extends ProjectsState {
  final List<ProjectSummary> summaries;
  const ProjectsLoaded({required this.summaries});
}

class ProjectsError extends ProjectsState {
  final String message;
  const ProjectsError({required this.message});
}

class ProjectSummary {
  final Project project;
  final double totalBudget;
  final double totalSpent;
  final double totalDeposited;
  final int activityCount;

  const ProjectSummary({
    required this.project,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalDeposited,
    required this.activityCount,
  });

  double get balance => totalDeposited - totalSpent;
  double get remainingBudget => totalBudget - totalDeposited;
  double get budgetProgress =>
      totalBudget > 0 ? (totalDeposited / totalBudget).clamp(0.0, 1.0) : 0.0;
}
