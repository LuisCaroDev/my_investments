import 'package:my_investments/projects/domain/entities/activity_summary.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';

class ProjectDetail {
  final Project project;
  final List<ActivitySummary> activitySummaries;
  final List<Transaction> projectLevelTransactions;
  final List<Category> projectCategories;
  final double totalBudget;
  final double totalSpent;
  final double totalDeposited;
  final double fundedAmount;
  final double remainingToFund;

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
  });

  double get operatingBalance => totalDeposited - totalSpent;
  double get netBalance => operatingBalance + fundedAmount;
  double get remainingBudget => totalBudget - totalDeposited;
  double get budgetProgress =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
}
