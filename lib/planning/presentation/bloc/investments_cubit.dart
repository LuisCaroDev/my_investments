import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:capitalflow/accounts/data/repositories/accounts_repository.dart';
import 'package:capitalflow/planning/data/repositories/project_repository.dart';
import 'package:capitalflow/planning/data/datasources/planning_local_ds.dart';
import 'package:capitalflow/planning/data/services/planning_detail_query_service.dart';
import 'package:capitalflow/planning/domain/entities/project.dart';
import 'package:capitalflow/planning/presentation/bloc/investments_state.dart';

class InvestmentsCubit extends Cubit<InvestmentsState> {
  final ProjectRepository _projectRepository;
  final PlanningDetailQueryService _detailQueryService;
  final AccountsRepository _accountsRepository;
  final PlanningLocalDataSource _planningLocalDataSource;
  StreamSubscription? _subscription;

  InvestmentsCubit({
    required ProjectRepository projectRepository,
    required PlanningDetailQueryService detailQueryService,
    required AccountsRepository accountsRepository,
    required PlanningLocalDataSource planningLocalDataSource,
  }) : _projectRepository = projectRepository,
       _detailQueryService = detailQueryService,
       _accountsRepository = accountsRepository,
       _planningLocalDataSource = planningLocalDataSource,
       super(const InvestmentsInitial()) {
    _subscription = _planningLocalDataSource.projectsStream.listen((_) {
      loadInvestments();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void loadInvestments() {
    emit(const InvestmentsLoading());
    try {
      final summaries = _detailQueryService.getProjectSummaries(
        ProjectType.investment,
      );
      emit(InvestmentsLoaded(summaries: summaries));
    } catch (e) {
      emit(InvestmentsError(message: e.toString()));
    }
  }

  Future<void> addInvestment(Project project) async {
    await _projectRepository.addProject(project, type: ProjectType.investment);
  }

  Future<void> updateInvestment(Project project) async {
    await _projectRepository.updateProject(project);
  }

  Future<void> deleteInvestment(String projectId) async {
    await _projectRepository.deleteProjectDataAndCascade(projectId);
    await _accountsRepository.deleteTransactionsForProject(projectId);
  }

  Future<void> reorderInvestments(List<String> orderedIds) async {
    await _projectRepository.reorderProjects(orderedIds);
  }
}
