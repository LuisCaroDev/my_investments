import 'package:my_investments/planning/domain/entities/project_detail.dart';

sealed class ProjectDetailState {
  const ProjectDetailState();
}

class ProjectDetailLoading extends ProjectDetailState {
  const ProjectDetailLoading();
}

class ProjectDetailLoaded extends ProjectDetailState {
  final ProjectDetail detail;

  const ProjectDetailLoaded({
    required this.detail,
  });
}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError({required this.message});
}
