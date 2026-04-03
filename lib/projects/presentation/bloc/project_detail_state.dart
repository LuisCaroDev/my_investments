import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';

sealed class ProjectDetailState {
  const ProjectDetailState();
}

class ProjectDetailLoading extends ProjectDetailState {
  const ProjectDetailLoading();
}

class ProjectDetailLoaded extends ProjectDetailState {
  final Project project;
  final List<ActivitySummary> activitySummaries;
  final List<Transaction> projectLevelTransactions;
  final List<Category> projectCategories;
  final double totalBudget;
  final double totalSpent;
  final double totalDeposited;

  const ProjectDetailLoaded({
    required this.project,
    required this.activitySummaries,
    required this.projectLevelTransactions,
    required this.projectCategories,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalDeposited,
  });

  double get balance => totalDeposited - totalSpent;
  double get remainingBudget => totalBudget - totalDeposited;
  double get budgetProgress =>
      totalBudget > 0 ? (totalDeposited / totalBudget).clamp(0.0, 1.0) : 0.0;

}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError({required this.message});
}

class ActivitySummary {
  final Activity activity;
  final double spent;
  final double deposited;
  final List<Category> categories;
  final int transactionCount;

  const ActivitySummary({
    required this.activity,
    required this.spent,
    required this.deposited,
    required this.categories,
    required this.transactionCount,
  });

  double get budget => activity.budget ?? 0;
  double get balance => deposited - spent;
  double get remainingBudget => budget - deposited;
  double get budgetProgress =>
      budget > 0 ? (deposited / budget).clamp(0.0, 1.0) : 0.0;
}
