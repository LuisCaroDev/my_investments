import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/planning/domain/entities/activity.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/planning/domain/entities/project_summary.dart';

class PlanningFundingCalculator {
  const PlanningFundingCalculator();

  List<ProjectSummary> buildProjectSummaries({
    required ProjectType type,
    required List<Project> projects,
    required List<Activity> activities,
    required List<Transaction> transactions,
  }) {
    final sortedProjects = List<Project>.from(projects)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    var totalLiquidity = calculateAvailableLiquidityFromAccounts(transactions);
    final summaries = <ProjectSummary>[];

    for (final project in sortedProjects) {
      final projectActivities = activities
          .where((activity) => activity.projectId == project.id)
          .toList();
      final projectTransactions = transactions
          .where((transaction) => transaction.projectId == project.id)
          .toList();

      final totalSpent = _sumTransactions(
        projectTransactions,
        TransactionType.expense,
      );
      final totalDeposited = _sumTransactions(
        projectTransactions,
        TransactionType.deposit,
      );
      final totalBudget = calculateProjectBudget(
        project: project,
        projectActivities: projectActivities,
      );
      final remainingNeed = calculateRemainingProjectNeed(
        totalBudget: totalBudget,
        totalSpent: totalSpent,
      );

      var fundedAmount = 0.0;
      if (remainingNeed > 0) {
        fundedAmount = remainingNeed < totalLiquidity
            ? remainingNeed
            : totalLiquidity;
        if (fundedAmount < 0) {
          fundedAmount = 0.0;
        }
        totalLiquidity -= fundedAmount;
      }

      final remainingToFund = remainingNeed > 0
          ? (remainingNeed - fundedAmount)
          : 0.0;

      summaries.add(
        ProjectSummary(
          project: project,
          totalBudget: totalBudget,
          totalSpent: totalSpent,
          totalDeposited: totalDeposited,
          fundedAmount: fundedAmount,
          remainingToFund: remainingToFund,
          activityCount: projectActivities.length,
        ),
      );
    }

    return summaries.where((summary) => summary.project.type == type).toList();
  }

  double calculateFundedAmountForProject({
    required Project project,
    required List<Project> projects,
    required List<Activity> allActivities,
    required List<Transaction> allTransactions,
  }) {
    var totalLiquidity = calculateAvailableLiquidityFromAccounts(
      allTransactions,
    );
    final sortedProjects = List<Project>.from(projects)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final currentProject in sortedProjects) {
      final projectActivities = allActivities
          .where((activity) => activity.projectId == currentProject.id)
          .toList();
      final projectTransactions = allTransactions
          .where((transaction) => transaction.projectId == currentProject.id)
          .toList();
      final projectBudget = calculateProjectBudget(
        project: currentProject,
        projectActivities: projectActivities,
      );
      final projectSpent = _sumTransactions(
        projectTransactions,
        TransactionType.expense,
      );
      final projectRemainingNeed = calculateRemainingProjectNeed(
        totalBudget: projectBudget,
        totalSpent: projectSpent,
      );

      var fundedAmount = 0.0;
      if (projectRemainingNeed > 0) {
        fundedAmount = projectRemainingNeed < totalLiquidity
            ? projectRemainingNeed
            : totalLiquidity;
        if (fundedAmount < 0) {
          fundedAmount = 0.0;
        }
        totalLiquidity -= fundedAmount;
      }

      if (currentProject.id == project.id) {
        return fundedAmount;
      }
    }

    return 0.0;
  }

  double calculateAvailableLiquidityFromAccounts(
    List<Transaction> transactions,
  ) {
    return transactions.fold(
      0.0,
      (sum, transaction) =>
          sum +
          (transaction.type == TransactionType.deposit
              ? transaction.amount
              : -transaction.amount),
    );
  }

  Map<String, double> allocateFundingSequentially({
    required List<Activity> activities,
    required double fundedAmount,
    required List<Transaction> transactions,
  }) {
    final allocations = <String, double>{};
    var balance = fundedAmount < 0 ? 0.0 : fundedAmount;
    final sortedActivities = List<Activity>.from(activities)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final activity in sortedActivities) {
      final budget = activity.budget ?? 0.0;
      final spent = _sumTransactions(
        transactions.where(
          (transaction) => transaction.activityId == activity.id,
        ),
        TransactionType.expense,
      );
      final remainingNeed = calculateRemainingProjectNeed(
        totalBudget: budget,
        totalSpent: spent,
      );

      if (remainingNeed <= 0 || balance <= 0) {
        allocations[activity.id] = 0.0;
        continue;
      }

      final allocated = balance < remainingNeed ? balance : remainingNeed;
      allocations[activity.id] = allocated;
      balance -= allocated;
    }

    return allocations;
  }

  double calculateProjectBudget({
    required Project project,
    required List<Activity> projectActivities,
  }) {
    return project.globalBudget ??
        projectActivities.fold<double>(
          0.0,
          (sum, activity) => sum + (activity.budget ?? 0.0),
        );
  }

  double calculateRemainingProjectNeed({
    required double totalBudget,
    required double totalSpent,
  }) {
    if (totalBudget <= 0) {
      return 0.0;
    }

    return (totalBudget - totalSpent).clamp(0.0, totalBudget);
  }

  double _sumTransactions(
    Iterable<Transaction> transactions,
    TransactionType type,
  ) {
    return transactions
        .where((transaction) => transaction.type == type)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
}
