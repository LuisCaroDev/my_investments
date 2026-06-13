import 'package:capitalflow/planning/domain/entities/project.dart';

class ProjectSummary {
  final Project project;
  final int totalBudgetCents;
  final int totalSpentCents;
  final int totalDepositedCents;
  final int fundedAmountCents;
  final int remainingToFundCents;
  final int activityCount;

  const ProjectSummary({
    required this.project,
    required this.totalBudgetCents,
    required this.totalSpentCents,
    required this.totalDepositedCents,
    required this.fundedAmountCents,
    required this.remainingToFundCents,
    required this.activityCount,
  });

  int get operatingBalanceCents => totalDepositedCents - totalSpentCents;
  int get netBalanceCents => operatingBalanceCents;
  double get budgetProgress =>
      totalBudgetCents > 0
      ? (totalSpentCents / totalBudgetCents).clamp(0.0, 1.0)
      : 0.0;
  double get fundingProgress =>
      totalBudgetCents > 0
      ? (fundedAmountCents / totalBudgetCents).clamp(0.0, 1.0)
      : 0.0;
}
