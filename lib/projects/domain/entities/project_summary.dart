import 'package:my_investments/projects/domain/entities/project.dart';

class ProjectSummary {
  final Project project;
  final double totalBudget;
  final double totalSpent;
  final double totalDeposited;
  final double totalCapitalInjected;
  final int activityCount;

  const ProjectSummary({
    required this.project,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalDeposited,
    required this.totalCapitalInjected,
    required this.activityCount,
  });

  double get operatingBalance => totalDeposited - totalSpent;
  double get netBalance => operatingBalance + totalCapitalInjected;
  double get remainingBudget => totalBudget - totalDeposited;
  double get budgetProgress =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
}
