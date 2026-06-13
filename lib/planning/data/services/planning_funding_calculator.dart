import 'dart:math' as math;

import 'package:capitalflow/core/domain/entities/transaction.dart';
import 'package:capitalflow/core/utils/money.dart';
import 'package:capitalflow/planning/domain/entities/activity.dart';
import 'package:capitalflow/planning/domain/entities/project.dart';
import 'package:capitalflow/planning/domain/entities/project_summary.dart';

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

    var totalLiquidityCents = calculateAvailableLiquidityFromAccounts(
      transactions,
    );
    final summaries = <ProjectSummary>[];

    for (final project in sortedProjects) {
      final projectActivities = activities
          .where((activity) => activity.projectId == project.id)
          .toList();
      final projectTransactions = transactions
          .where((transaction) => transaction.projectId == project.id)
          .toList();

      final totalSpentCents = _sumTransactions(
        projectTransactions,
        TransactionType.expense,
      );
      final totalDepositedCents = _sumTransactions(
        projectTransactions,
        TransactionType.deposit,
      );
      final totalBudgetCents = calculateProjectBudget(
        project: project,
        projectActivities: projectActivities,
        projectTransactions: projectTransactions,
      );
      final remainingNeedCents = calculateRemainingProjectNeed(
        totalBudgetCents: totalBudgetCents,
        totalSpentCents: totalSpentCents,
      );

      var fundedAmountCents = 0;
      if (remainingNeedCents > 0) {
        fundedAmountCents = remainingNeedCents < totalLiquidityCents
            ? remainingNeedCents
            : totalLiquidityCents;
        if (fundedAmountCents < 0) {
          fundedAmountCents = 0;
        }
        totalLiquidityCents -= fundedAmountCents;
      }

      final remainingToFundCents = remainingNeedCents > 0
          ? (remainingNeedCents - fundedAmountCents)
          : 0;

      summaries.add(
        ProjectSummary(
          project: project,
          totalBudgetCents: totalBudgetCents,
          totalSpentCents: totalSpentCents,
          totalDepositedCents: totalDepositedCents,
          fundedAmountCents: fundedAmountCents,
          remainingToFundCents: remainingToFundCents,
          activityCount: projectActivities.length,
        ),
      );
    }

    return summaries.where((summary) => summary.project.type == type).toList();
  }

  int calculateFundedAmountForProject({
    required Project project,
    required List<Project> projects,
    required List<Activity> allActivities,
    required List<Transaction> allTransactions,
  }) {
    var totalLiquidityCents = calculateAvailableLiquidityFromAccounts(
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
      final projectBudgetCents = calculateProjectBudget(
        project: currentProject,
        projectActivities: projectActivities,
        projectTransactions: projectTransactions,
      );
      final projectSpentCents = _sumTransactions(
        projectTransactions,
        TransactionType.expense,
      );
      final projectRemainingNeedCents = calculateRemainingProjectNeed(
        totalBudgetCents: projectBudgetCents,
        totalSpentCents: projectSpentCents,
      );

      var fundedAmountCents = 0;
      if (projectRemainingNeedCents > 0) {
        fundedAmountCents = projectRemainingNeedCents < totalLiquidityCents
            ? projectRemainingNeedCents
            : totalLiquidityCents;
        if (fundedAmountCents < 0) {
          fundedAmountCents = 0;
        }
        totalLiquidityCents -= fundedAmountCents;
      }

      if (currentProject.id == project.id) {
        return fundedAmountCents;
      }
    }

    return 0;
  }

  int calculateAvailableLiquidityFromAccounts(
    List<Transaction> transactions,
  ) {
    return transactions.fold(
      0,
      (sum, transaction) =>
          sum +
          (transaction.type == TransactionType.deposit
              ? transaction.amountCents
              : -transaction.amountCents),
    );
  }

  Map<String, int> allocateFundingSequentially({
    required List<Activity> activities,
    required int fundedAmountCents,
    required List<Transaction> transactions,
  }) {
    final allocations = <String, int>{};
    var balanceCents = fundedAmountCents < 0 ? 0 : fundedAmountCents;
    final sortedActivities = List<Activity>.from(activities)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final activity in sortedActivities) {
      final budgetCents = activity.budgetCents ?? 0;
      final spentCents = _sumTransactions(
        transactions.where(
          (transaction) => transaction.activityId == activity.id,
        ),
        TransactionType.expense,
      );
      final remainingNeedCents = calculateRemainingProjectNeed(
        totalBudgetCents: budgetCents,
        totalSpentCents: spentCents,
      );

      if (remainingNeedCents <= 0 || balanceCents <= 0) {
        allocations[activity.id] = 0;
        continue;
      }

      final allocatedCents = balanceCents < remainingNeedCents
          ? balanceCents
          : remainingNeedCents;
      allocations[activity.id] = allocatedCents;
      balanceCents -= allocatedCents;
    }

    return allocations;
  }

  int calculateProjectBudget({
    required Project project,
    required List<Activity> projectActivities,
    required List<Transaction> projectTransactions,
  }) {
    if (project.autoUpdateBudget) {
      return calculateSuggestedProjectBudget(
        projectActivities: projectActivities,
        projectTransactions: projectTransactions,
      );
    }
    return project.globalBudgetCents ??
        projectActivities.fold<int>(
          0,
          (sum, activity) => sum + (activity.budgetCents ?? 0),
        );
  }

  int calculateSuggestedProjectBudget({
    required List<Activity> projectActivities,
    required List<Transaction> projectTransactions,
  }) {
    final activitiesBudgetCents = projectActivities.fold<int>(0, (
      sum,
      activity,
    ) {
      final activitySpentCents = _sumTransactions(
        projectTransactions.where((t) => t.activityId == activity.id),
        TransactionType.expense,
      );
      final dynamicActivityBudgetCents = activity.autoUpdateBudget
          ? math.max(activity.budgetCents ?? 0, activitySpentCents)
          : (activity.budgetCents ?? 0);
      return sum + dynamicActivityBudgetCents;
    });

    final projectLevelSpentCents = _sumTransactions(
      projectTransactions.where((t) => t.activityId == null),
      TransactionType.expense,
    );

    return activitiesBudgetCents + projectLevelSpentCents;
  }

  int calculateRemainingProjectNeed({
    required int totalBudgetCents,
    required int totalSpentCents,
  }) {
    if (totalBudgetCents <= 0) {
      return 0;
    }

    return clampMoney(
      totalBudgetCents - totalSpentCents,
      0,
      totalBudgetCents,
    );
  }

  int _sumTransactions(
    Iterable<Transaction> transactions,
    TransactionType type,
  ) {
    return transactions
        .where((transaction) => transaction.type == type)
        .fold(0, (sum, transaction) => sum + transaction.amountCents);
  }
}
