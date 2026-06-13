import 'package:capitalflow/core/domain/entities/transaction.dart';
import 'package:capitalflow/core/domain/repositories/transactions_reader.dart';
import 'package:capitalflow/planning/data/datasources/planning_local_ds.dart';
import 'package:capitalflow/planning/data/repositories/activity_repository.dart';
import 'package:capitalflow/planning/data/repositories/operational_task_repository.dart';
import 'package:capitalflow/planning/data/services/planning_funding_calculator.dart';
import 'package:capitalflow/planning/domain/entities/activity_detail.dart';
import 'package:capitalflow/planning/domain/entities/activity_summary.dart';
import 'package:capitalflow/planning/domain/entities/project.dart';
import 'package:capitalflow/planning/domain/entities/project_detail.dart';
import 'package:capitalflow/planning/domain/entities/project_summary.dart';

class PlanningDetailQueryService {
  final PlanningLocalDataSource _localDataSource;
  final TransactionsReader _transactionsReader;
  final ActivityRepository _activityRepository;
  final OperationalTaskRepository _operationalTaskRepository;
  final PlanningFundingCalculator _fundingCalculator;

  PlanningDetailQueryService({
    required PlanningLocalDataSource localDataSource,
    required TransactionsReader transactionsReader,
    required ActivityRepository activityRepository,
    required OperationalTaskRepository operationalTaskRepository,
    required PlanningFundingCalculator fundingCalculator,
  }) : _localDataSource = localDataSource,
       _transactionsReader = transactionsReader,
       _activityRepository = activityRepository,
       _operationalTaskRepository = operationalTaskRepository,
       _fundingCalculator = fundingCalculator;

  List<ProjectSummary> getProjectSummaries(ProjectType type) {
    return _fundingCalculator.buildProjectSummaries(
      type: type,
      projects: _localDataSource.getProjects(),
      activities: _localDataSource.getActivities(),
      transactions: _transactionsReader.getAllTransactions(),
    );
  }

  ProjectDetail getProjectDetail(String projectId) {
    final projects = _localDataSource.getProjects();
    final project = projects.firstWhere(
      (currentProject) => currentProject.id == projectId,
    );
    final allActivities = _localDataSource.getActivities();
    final projectActivities = allActivities
        .where((activity) => activity.projectId == projectId)
        .toList();
    final allTransactions = _transactionsReader.getAllTransactions();
    final projectTransactions = allTransactions
        .where((transaction) => transaction.projectId == projectId)
        .toList();
    final allTasks = _localDataSource.getCategories();

    final projectLevelTransactions = projectTransactions
        .where((transaction) => transaction.activityId == null)
        .toList();
    final projectTasks = allTasks
        .where((task) => task.projectId == projectId && task.activityId == null)
        .toList();

    final totalSpentCents = _sumTransactions(
      projectTransactions,
      TransactionType.expense,
    );
    final totalDepositedCents = _sumTransactions(
      projectTransactions,
      TransactionType.deposit,
    );
    final totalBudgetCents = _fundingCalculator.calculateProjectBudget(
      project: project,
      projectActivities: projectActivities,
      projectTransactions: projectTransactions,
    );
    final suggestedBudgetCents = _fundingCalculator.calculateSuggestedProjectBudget(
      projectActivities: projectActivities,
      projectTransactions: projectTransactions,
    );
    final fundedAmountCents = _fundingCalculator.calculateFundedAmountForProject(
      project: project,
      projects: projects,
      allActivities: allActivities,
      allTransactions: allTransactions,
    );
    final activityFunding = _fundingCalculator.allocateFundingSequentially(
      activities: projectActivities,
      fundedAmountCents: fundedAmountCents,
      transactions: projectTransactions,
    );

    final activitySummaries = projectActivities.map((activity) {
      final activityTransactions = projectTransactions
          .where((transaction) => transaction.activityId == activity.id)
          .toList();
      final spentCents = _sumTransactions(
        activityTransactions,
        TransactionType.expense,
      );
      final depositedCents = _sumTransactions(
        activityTransactions,
        TransactionType.deposit,
      );
      final categories = allTasks
          .where((task) => task.activityId == activity.id)
          .toList();

      return ActivitySummary(
        activity: activity,
        spentCents: spentCents,
        depositedCents: depositedCents,
        fundedAmountCents: activityFunding[activity.id] ?? 0,
        categories: categories,
        transactionCount: activityTransactions.length,
      );
    }).toList();

    final remainingProjectNeedCents = _fundingCalculator
        .calculateRemainingProjectNeed(
          totalBudgetCents: totalBudgetCents,
          totalSpentCents: totalSpentCents,
        );
    final remainingToFundCents = remainingProjectNeedCents > 0
        ? (remainingProjectNeedCents - fundedAmountCents).clamp(
            0,
            remainingProjectNeedCents,
          )
        : 0;

    final projectLevelSpentCents = _sumTransactions(
      projectLevelTransactions,
      TransactionType.expense,
    );
    final projectLevelDepositedCents = _sumTransactions(
      projectLevelTransactions,
      TransactionType.deposit,
    );
    final projectLevelBalanceCents =
        projectLevelDepositedCents - projectLevelSpentCents;

    return ProjectDetail(
      project: project,
      activitySummaries: activitySummaries,
      projectLevelTransactions: projectLevelTransactions,
      projectCategories: projectTasks,
      totalBudgetCents: totalBudgetCents,
      totalSpentCents: totalSpentCents,
      totalDepositedCents: totalDepositedCents,
      fundedAmountCents: fundedAmountCents,
      remainingToFundCents: remainingToFundCents,
      projectLevelBalanceCents: projectLevelBalanceCents,
      suggestedBudgetCents: suggestedBudgetCents,
    );
  }

  ActivityDetail getActivityDetail(String projectId, String activityId) {
    final activities = _activityRepository.getAllActivities();
    final activity = activities.firstWhere(
      (currentActivity) => currentActivity.id == activityId,
    );
    final projects = _localDataSource.getProjects();
    final project = projects.firstWhere(
      (currentProject) => currentProject.id == projectId,
    );
    final allTransactions = _transactionsReader.getAllTransactions();
    final transactions = allTransactions
        .where((transaction) => transaction.activityId == activityId)
        .toList();
    final categories = _operationalTaskRepository.getAvailableOperationalTasks(
      projectId,
      activityId,
    );

    final spentCents = _sumTransactions(transactions, TransactionType.expense);
    final depositedCents = _sumTransactions(
      transactions,
      TransactionType.deposit,
    );
    final projectActivities = activities
        .where((currentActivity) => currentActivity.projectId == projectId)
        .toList();
    final projectFundedAmountCents = _fundingCalculator
        .calculateFundedAmountForProject(
          project: project,
          projects: projects,
          allActivities: activities,
          allTransactions: allTransactions,
        );
    final activityFunding = _fundingCalculator.allocateFundingSequentially(
      activities: projectActivities,
      fundedAmountCents: projectFundedAmountCents,
      transactions: allTransactions
          .where((transaction) => transaction.projectId == projectId)
          .toList(),
    );

    final summary = ActivitySummary(
      activity: activity,
      spentCents: spentCents,
      depositedCents: depositedCents,
      fundedAmountCents: activityFunding[activityId] ?? 0,
      categories: _operationalTaskRepository.getActivityOperationalTasks(
        activityId,
      ),
      transactionCount: transactions.length,
    );

    return ActivityDetail(
      summary: summary,
      transactions: transactions,
      categories: categories,
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
