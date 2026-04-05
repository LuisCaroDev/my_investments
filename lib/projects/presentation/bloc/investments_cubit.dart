import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/presentation/bloc/investments_state.dart';

class InvestmentsCubit extends Cubit<InvestmentsState> {
  final ProjectsRepository _repository;

  InvestmentsCubit({required ProjectsRepository repository})
    : _repository = repository,
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
    loadInvestments();
  }

  Future<void> reorderInvestments(List<String> orderedIds) async {
    await _repository.reorderInvestments(orderedIds);
    loadInvestments();
  }
}
