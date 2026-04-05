import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/presentation/bloc/projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsRepository _repository;

  ProjectsCubit({required ProjectsRepository repository})
    : _repository = repository,
      super(const ProjectsInitial());

  void loadProjects() {
    emit(const ProjectsLoading());
    try {
      final summaries = _repository.getProjectSummaries();
      emit(ProjectsLoaded(summaries: summaries));
    } catch (e) {
      emit(ProjectsError(message: e.toString()));
    }
  }

  Future<void> addProject(Project project) async {
    await _repository.addProject(project);
    loadProjects();
  }

  Future<void> updateProject(Project project) async {
    await _repository.updateProject(project);
    loadProjects();
  }

  Future<void> deleteProject(String projectId) async {
    await _repository.deleteProject(projectId);
    loadProjects();
  }
}
