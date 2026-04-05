import 'package:my_investments/projects/domain/entities/project_summary.dart';

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
