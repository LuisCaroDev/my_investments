import 'package:my_investments/projects/domain/entities/project_summary.dart';

sealed class InvestmentsState {
  const InvestmentsState();
}

class InvestmentsInitial extends InvestmentsState {
  const InvestmentsInitial();
}

class InvestmentsLoading extends InvestmentsState {
  const InvestmentsLoading();
}

class InvestmentsLoaded extends InvestmentsState {
  final List<ProjectSummary> summaries;
  const InvestmentsLoaded({required this.summaries});
}

class InvestmentsError extends InvestmentsState {
  final String message;
  const InvestmentsError({required this.message});
}
