import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/data/repositories/project_repository.dart';
import 'package:my_investments/planning/data/services/planning_detail_query_service.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/planning/presentation/bloc/investments_state.dart';

class InvestmentsCubit extends Cubit<InvestmentsState> {
  final ProjectRepository _projectRepository;
  final PlanningDetailQueryService _detailQueryService;
  final AccountsRepository _accountsRepository;

  InvestmentsCubit({
    required ProjectRepository projectRepository,
    required PlanningDetailQueryService detailQueryService,
    required AccountsRepository accountsRepository,
  }) : _projectRepository = projectRepository,
       _detailQueryService = detailQueryService,
       _accountsRepository = accountsRepository,
       super(const InvestmentsInitial());

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
    loadInvestments();
  }

  Future<void> updateInvestment(Project project) async {
    await _projectRepository.updateProject(project);
    loadInvestments();
  }

  Future<void> deleteInvestment(String projectId) async {
    await _projectRepository.deleteProjectDataAndCascade(projectId);
    await _accountsRepository.deleteTransactionsForProject(projectId);
    loadInvestments();
  }

  Future<void> reorderInvestments(List<String> orderedIds) async {
    await _projectRepository.reorderProjects(orderedIds);
    loadInvestments();
  }
}
