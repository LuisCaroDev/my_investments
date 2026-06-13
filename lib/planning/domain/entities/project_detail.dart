import 'package:capitalflow/planning/domain/entities/activity_summary.dart';
import 'package:capitalflow/planning/domain/entities/operational_task.dart';
import 'package:capitalflow/planning/domain/entities/project.dart';
import 'package:capitalflow/core/domain/entities/transaction.dart';

class ProjectDetail {
  final Project project;
  final List<ActivitySummary> activitySummaries;
  final List<Transaction> projectLevelTransactions;
  final List<OperationalTask> projectCategories;
  final int totalBudgetCents;
  final int totalSpentCents;
  final int totalDepositedCents;
  final int fundedAmountCents;
  final int remainingToFundCents;
  final int projectLevelBalanceCents;
  final int suggestedBudgetCents;

  const ProjectDetail({
    required this.project,
    required this.activitySummaries,
    required this.projectLevelTransactions,
    required this.projectCategories,
    required this.totalBudgetCents,
    required this.totalSpentCents,
    required this.totalDepositedCents,
    required this.fundedAmountCents,
    required this.remainingToFundCents,
    required this.projectLevelBalanceCents,
    required this.suggestedBudgetCents,
  });

  int get operatingBalanceCents => totalDepositedCents - totalSpentCents;
  int get netBalanceCents => operatingBalanceCents;
  int get remainingBudgetCents => totalBudgetCents - totalDepositedCents;
  double get budgetProgress =>
      totalBudgetCents > 0
      ? (totalSpentCents / totalBudgetCents).clamp(0.0, 1.0)
      : 0.0;
}
