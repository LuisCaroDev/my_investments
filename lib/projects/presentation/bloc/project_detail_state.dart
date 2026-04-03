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
  final double totalCapitalInjected;

  const ProjectDetailLoaded({
    required this.project,
    required this.activitySummaries,
    required this.projectLevelTransactions,
    required this.projectCategories,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalDeposited,
    required this.totalCapitalInjected,
  });

  double get operatingBalance => totalDeposited - totalSpent;
  double get netBalance => operatingBalance + totalCapitalInjected;
  double get remainingBudget => totalBudget - totalDeposited;
  double get budgetProgress =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError({required this.message});
}

class ActivitySummary {
  final Activity activity;
  final double spent;
  final double deposited;
  final double capitalInjected;
  final List<Category> categories;
  final int transactionCount;

  const ActivitySummary({
    required this.activity,
    required this.spent,
    required this.deposited,
    required this.capitalInjected,
    required this.categories,
    required this.transactionCount,
  });

  double get budget => activity.budget ?? 0;
  double get operatingBalance => deposited - spent;
  double get netBalance => operatingBalance + capitalInjected;
  double get remainingBudget => budget - deposited;
  double get budgetProgress =>
      budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
}
