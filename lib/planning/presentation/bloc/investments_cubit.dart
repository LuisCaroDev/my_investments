import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/planning/presentation/bloc/investments_state.dart';

class InvestmentsCubit extends Cubit<InvestmentsState> {
  final PlanningRepository _repository;
  final AccountsRepository _accountsRepository;

  InvestmentsCubit({
    required PlanningRepository repository,
    required AccountsRepository accountsRepository,
  }) : _repository = repository,
       _accountsRepository = accountsRepository,
       super(const InvestmentsInitial());

  void loadInvestments() {
    emit(const InvestmentsLoading());
    try {
      final summaries = _repository.getInvestmentSummaries();
      emit(InvestmentsLoaded(summaries: summaries));
    } catch (e) {
      emit(InvestmentsError(message: e.toString()));
    }
  }

  Future<void> addInvestment(Project project) async {
    await _repository.addInvestment(project);
    loadInvestments();
  }

  Future<void> updateInvestment(Project project) async {
    await _repository.updateInvestment(project);
    loadInvestments();
  }

  Future<void> deleteInvestment(String projectId) async {
    await _repository.deleteInvestment(projectId);
    await _accountsRepository.deleteTransactionsForProject(projectId);
    loadInvestments();
  }

  Future<void> reorderInvestments(List<String> orderedIds) async {
    await _repository.reorderInvestments(orderedIds);
    loadInvestments();
  }
}
