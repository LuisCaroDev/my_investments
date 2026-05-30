import 'package:my_investments/accounts/data/datasources/accounts_local_ds.dart';
import 'package:my_investments/accounts/data/models/financial_account_model.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/planning/data/models/activity_model.dart';
import 'package:my_investments/planning/data/models/project_model.dart';
import 'package:my_investments/planning/data/services/planning_funding_calculator.dart';
import 'package:my_investments/planning/domain/entities/project.dart';

class TransactionProjectionJob {
  final AccountsLocalDataSource _accountsDs;
  final PlanningLocalDataSource _planningDs;
  final PlanningFundingCalculator _calculator;

  const TransactionProjectionJob({
    required AccountsLocalDataSource accountsDs,
    required PlanningLocalDataSource planningDs,
    required PlanningFundingCalculator calculator,
  }) : _accountsDs = accountsDs,
       _planningDs = planningDs,
       _calculator = calculator;

  Future<void> run() async {
    final transactions = _accountsDs.getTransactions();

    // 1. Recalculate account balances
    final accounts = _accountsDs.getFinancialAccounts();
    final totals = <String, double>{};
    for (final transaction in transactions) {
      final delta = transaction.type == TransactionType.deposit
          ? transaction.amount
          : -transaction.amount;
      totals.update(
        transaction.accountId,
        (value) => value + delta,
        ifAbsent: () => delta,
      );
    }
    final updatedAccounts = accounts.map((account) {
      return FinancialAccountModel(
        id: account.id,
        name: account.name,
        type: account.type,
        balance: totals[account.id] ?? 0.0,
        createdAt: account.createdAt,
      );
    }).toList();
    await _accountsDs.saveFinancialAccounts(updatedAccounts);

    // 2. Recalculate project and activity stats
    final projects = _planningDs.getProjects();
    final activities = _planningDs.getActivities();

    final updatedProjects = <ProjectModel>[];
    final updatedActivities = <ActivityModel>[];

    final investmentSummaries = _calculator.buildProjectSummaries(
      type: ProjectType.investment,
      projects: projects,
      activities: activities,
      transactions: transactions,
    );
    final savingsSummaries = _calculator.buildProjectSummaries(
      type: ProjectType.savingsGoal,
      projects: projects,
      activities: activities,
      transactions: transactions,
    );

    final allSummaries = [...investmentSummaries, ...savingsSummaries];

    for (final project in projects) {
      final summary = allSummaries.firstWhere(
        (s) => s.project.id == project.id,
      );

      updatedProjects.add(
        ProjectModel(
          id: project.id,
          name: project.name,
          description: project.description,
          globalBudget: project.globalBudget,
          type: project.type,
          priority: project.priority,
          autoUpdateBudget: project.autoUpdateBudget,
          createdAt: project.createdAt,
          cachedTotalSpent: summary.totalSpent,
          cachedFundedAmount: summary.fundedAmount,
          cachedRemainingToFund: summary.remainingToFund,
        ),
      );

      final projectActivities = activities
          .where((a) => a.projectId == project.id)
          .toList();
      final projectTransactions = transactions
          .where((t) => t.projectId == project.id)
          .toList();

      final activityFunding = _calculator.allocateFundingSequentially(
        activities: projectActivities,
        fundedAmount: summary.fundedAmount,
        transactions: projectTransactions,
      );

      for (final activity in projectActivities) {
        final activityTransactions = projectTransactions
            .where((t) => t.activityId == activity.id)
            .toList();
        final spent = _sumTransactions(
          activityTransactions,
          TransactionType.expense,
        );
        final deposited = _sumTransactions(
          activityTransactions,
          TransactionType.deposit,
        );

        updatedActivities.add(
          ActivityModel(
            id: activity.id,
            projectId: activity.projectId,
            name: activity.name,
            description: activity.description,
            year: activity.year,
            budget: activity.budget,
            autoUpdateBudget: activity.autoUpdateBudget,
            createdAt: activity.createdAt,
            cachedSpent: spent,
            cachedDeposited: deposited,
            cachedFundedAmount: activityFunding[activity.id] ?? 0.0,
          ),
        );
      }
    }

    await _planningDs.saveProjects(updatedProjects);
    await _planningDs.saveActivities(updatedActivities);
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
