import 'package:capitalflow/planning/domain/entities/activity_summary.dart';
import 'package:capitalflow/planning/domain/entities/operational_task.dart';
import 'package:capitalflow/planning/domain/entities/project.dart';
import 'package:capitalflow/core/domain/entities/transaction.dart';

class ProjectDetail {
  final Project project;
  final List<ActivitySummary> activitySummaries;
  final List<Transaction> projectLevelTransactions;
  final List<OperationalTask> projectCategories;
  final double totalBudget;
  final double totalSpent;
  final double totalDeposited;
  final double fundedAmount;
  final double remainingToFund;
  final double projectLevelBalance;
  final double suggestedBudget;

  const ProjectDetail({
    required this.project,
    required this.activitySummaries,
    required this.projectLevelTransactions,
    required this.projectCategories,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalDeposited,
    required this.fundedAmount,
    required this.remainingToFund,
    required this.projectLevelBalance,
    required this.suggestedBudget,
  });

  double get operatingBalance => totalDeposited - totalSpent;
  double get netBalance => operatingBalance;
  double get remainingBudget => totalBudget - totalDeposited;
  double get budgetProgress =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
}
