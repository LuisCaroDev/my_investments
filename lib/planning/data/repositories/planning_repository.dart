import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/core/domain/repositories/transactions_reader.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/planning/data/models/project_model.dart';
import 'package:my_investments/planning/data/models/activity_model.dart';
import 'package:my_investments/planning/data/models/operational_task_model.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/planning/domain/entities/activity.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart';
import 'package:my_investments/planning/domain/entities/activity_summary.dart';
import 'package:my_investments/planning/domain/entities/project_summary.dart';
import 'package:my_investments/planning/domain/entities/project_detail.dart';
import 'package:my_investments/planning/domain/entities/activity_detail.dart';
import 'package:my_investments/core/storage/sync_change_recorder.dart';

class PlanningRepository {
  final PlanningLocalDataSource _localDataSource;
  final TransactionsReader _transactionsReader;
  final SyncChangeRecorder? _changeRecorder;

  const PlanningRepository({
    required PlanningLocalDataSource localDataSource,
    required TransactionsReader transactionsReader,
    SyncChangeRecorder? changeRecorder,
  }) : _localDataSource = localDataSource,
       _transactionsReader = transactionsReader,
       _changeRecorder = changeRecorder;

  // ── Funding Distribution Algorithm ──────────────────────────

  List<ProjectSummary> _buildProjectSummaries(ProjectType type) {
    var allProjects = _localDataSource.getProjects();
    final allActivities = _localDataSource.getActivities();
    final allTransactions = _transactionsReader.getAllTransactions();

    // 1. Calculate available liquidity from real account balances.
    double totalLiquidity = _calculateAvailableLiquidityFromAccounts(
      allTransactions,
    );

    // 2. Sort all projects by priority ASC
    allProjects.sort((a, b) => a.priority.compareTo(b.priority));

    List<ProjectSummary> allSummaries = [];

    // 3. Iterate and drain liquidity
    for (var project in allProjects) {
      final projectActivities = allActivities
          .where((a) => a.projectId == project.id)
          .toList();
      final projectTransactions = allTransactions
          .where((t) => t.projectId == project.id)
          .toList();

      final totalSpent = projectTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalDeposited = projectTransactions
          .where((t) => t.type == TransactionType.deposit)
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalBudget = _calculateProjectBudget(
        project: project,
        projectActivities: projectActivities,
      );
      final remainingNeed = _calculateRemainingProjectNeed(
        totalBudget: totalBudget,
        totalSpent: totalSpent,
      );

      // Allocate only the money still needed by this project.
      double fundedAmount = 0.0;
      if (remainingNeed > 0) {
        fundedAmount = remainingNeed < totalLiquidity
            ? remainingNeed
            : totalLiquidity;
        if (fundedAmount < 0) fundedAmount = 0; // Negative liquidity guard
        totalLiquidity -= fundedAmount;
      }

      final remainingToFund = remainingNeed > 0
          ? (remainingNeed - fundedAmount)
          : 0.0;

      allSummaries.add(
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

    // 4. Return only the requested type
    return allSummaries.where((s) => s.project.type == type).toList();
  }

  // ── Investments API ───────────────────────────────────────

  List<ProjectSummary> getInvestmentSummaries() {
    return _buildProjectSummaries(ProjectType.investment);
  }

  ProjectDetail getInvestmentDetail(String projectId) =>
      getProjectDetail(projectId);

  Future<void> addInvestment(Project project) async {
    final investment = project.copyWith(type: ProjectType.investment);
    final projects = _localDataSource.getProjects();
    final maxPriority = projects
        .where((p) => p.type == ProjectType.investment)
        .fold(0, (max, p) => p.priority > max ? p.priority : max);

    final model = ProjectModel.fromEntity(
      investment.copyWith(priority: maxPriority + 1),
    );
    projects.add(model);
    await _localDataSource.saveProjects(projects);
    await _changeRecorder?.recordChange(
      entity: 'projects',
      op: SyncChangeOp.add,
      id: model.id,
      payload: model.toJson(),
    );
  }

  Future<void> updateInvestment(Project project) async {
    final projects = _localDataSource.getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = ProjectModel.fromEntity(project);
      await _localDataSource.saveProjects(projects);
      await _changeRecorder?.recordChange(
        entity: 'projects',
        op: SyncChangeOp.update,
        id: project.id,
        payload: projects[index].toJson(),
      );
    }
  }

  Future<void> deleteInvestment(String projectId) =>
      _deleteProjectDataAndCascade(projectId);

  Future<void> reorderInvestments(List<String> orderedIds) async {
    final projects = _localDataSource.getProjects();
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final index = projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        projects[index] = ProjectModel.fromEntity(
          projects[index].copyWith(priority: i),
        );
        await _changeRecorder?.recordChange(
          entity: 'projects',
          op: SyncChangeOp.update,
          id: projects[index].id,
          payload: projects[index].toJson(),
        );
      }
    }
    await _localDataSource.saveProjects(projects);
  }

  // ── Goals API ──────────────────────────────────────────

  List<ProjectSummary> getGoalSummaries() {
    return _buildProjectSummaries(ProjectType.savingsGoal);
  }

  ProjectDetail getGoalDetail(String projectId) => getProjectDetail(projectId);

  Future<void> addGoal(Project project) async {
    final goal = project.copyWith(type: ProjectType.savingsGoal);
    final projects = _localDataSource.getProjects();
    int maxPriority = -1;
    for (var p in projects) {
      if (p.type == ProjectType.savingsGoal && p.priority > maxPriority) {
        maxPriority = p.priority;
      }
    }

    final model = ProjectModel.fromEntity(
      goal.copyWith(priority: maxPriority + 1),
    );
    projects.add(model);
    await _localDataSource.saveProjects(projects);
    await _changeRecorder?.recordChange(
      entity: 'projects',
      op: SyncChangeOp.add,
      id: model.id,
      payload: model.toJson(),
    );
  }

  Future<void> updateGoal(Project project) async {
    final projects = _localDataSource.getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = ProjectModel.fromEntity(project);
      await _localDataSource.saveProjects(projects);
      await _changeRecorder?.recordChange(
        entity: 'projects',
        op: SyncChangeOp.update,
        id: project.id,
        payload: projects[index].toJson(),
      );
    }
  }

  Future<void> deleteGoal(String projectId) =>
      _deleteProjectDataAndCascade(projectId);

  Future<void> reorderGoals(List<String> orderedIds) async {
    final projects = _localDataSource.getProjects();
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final index = projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        projects[index] = ProjectModel.fromEntity(
          projects[index].copyWith(priority: i),
        );
        await _changeRecorder?.recordChange(
          entity: 'projects',
          op: SyncChangeOp.update,
          id: projects[index].id,
          payload: projects[index].toJson(),
        );
      }
    }
    await _localDataSource.saveProjects(projects);
  }

  // ── Priority Reorder (All Projects) ───────────────────────

  Future<void> reorderProjects(List<String> orderedIds) async {
    final projects = _localDataSource.getProjects();
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final index = projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        projects[index] = ProjectModel.fromEntity(
          projects[index].copyWith(priority: i),
        );
        await _changeRecorder?.recordChange(
          entity: 'projects',
          op: SyncChangeOp.update,
          id: projects[index].id,
          payload: projects[index].toJson(),
        );
      }
    }
    await _localDataSource.saveProjects(projects);
  }

  // ── Shared Project Helpers ───────────────────────────────

  ProjectDetail getProjectDetail(String projectId) {
    final projects = _localDataSource.getProjects();
    final project = projects.firstWhere((p) => p.id == projectId);
    final allActivities = _localDataSource.getActivities();
    final projectActivities = allActivities
        .where((a) => a.projectId == projectId)
        .toList();
    final allTransactions = _transactionsReader.getAllTransactions();
    final projectTransactions = allTransactions
        .where((t) => t.projectId == projectId)
        .toList();
    final allCategories = _localDataSource.getCategories();
    // Funding is based on currently available account liquidity only.

    // Project-level details
    final projectLevelTransactions = projectTransactions
        .where((t) => t.activityId == null)
        .toList();
    final projectCategories = allCategories
        .where((c) => c.projectId == projectId && c.activityId == null)
        .toList();

    final totalSpent = projectTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalDeposited = projectTransactions
        .where((t) => t.type == TransactionType.deposit)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalBudget = _calculateProjectBudget(
      project: project,
      projectActivities: projectActivities,
    );

    final myFundedAmount = _calculateFundedAmountForProject(
      project: project,
      projects: projects,
      allActivities: allActivities,
      allTransactions: allTransactions,
    );

    final activityFunding = _allocateFundingSequentially(
      activities: projectActivities,
      fundedAmount: myFundedAmount,
      transactions: projectTransactions,
    );

    // Map activity summaries
    final activitySummaries = projectActivities.map((activity) {
      final activityTransactions = projectTransactions
          .where((t) => t.activityId == activity.id)
          .toList();
      final spent = activityTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final deposited = activityTransactions
          .where((t) => t.type == TransactionType.deposit)
          .fold(0.0, (sum, t) => sum + t.amount);
      final categories = allCategories
          .where((c) => c.activityId == activity.id)
          .toList();

      return ActivitySummary(
        activity: activity,
        spent: spent,
        deposited: deposited,
        fundedAmount: activityFunding[activity.id] ?? 0.0,
        categories: categories,
        transactionCount: activityTransactions.length,
      );
    }).toList();

    final remainingProjectNeed = _calculateRemainingProjectNeed(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
    );
    final remainingToFund = remainingProjectNeed > 0
        ? (remainingProjectNeed - myFundedAmount).clamp(
            0.0,
            remainingProjectNeed,
          )
        : 0.0;

    return ProjectDetail(
      project: project,
      activitySummaries: activitySummaries,
      projectLevelTransactions: projectLevelTransactions,
      projectCategories: projectCategories,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      totalDeposited: totalDeposited,
      fundedAmount: myFundedAmount,
      remainingToFund: remainingToFund,
    );
  }

  Future<void> _deleteProjectDataAndCascade(String projectId) async {
    final projects = _localDataSource.getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _localDataSource.saveProjects(projects);
    await _changeRecorder?.recordChange(
      entity: 'projects',
      op: SyncChangeOp.delete,
      id: projectId,
    );

    final activities = _localDataSource.getActivities();
    final removedActivities = activities
        .where((a) => a.projectId == projectId)
        .toList();
    activities.removeWhere((a) => a.projectId == projectId);
    await _localDataSource.saveActivities(activities);
    for (final activity in removedActivities) {
      await _changeRecorder?.recordChange(
        entity: 'activities',
        op: SyncChangeOp.delete,
        id: activity.id,
      );
    }

    final categories = _localDataSource.getCategories();
    final removedCategories = categories
        .where((c) => c.projectId == projectId)
        .toList();
    categories.removeWhere((c) => c.projectId == projectId);
    await _localDataSource.saveCategories(categories);
    for (final category in removedCategories) {
      await _changeRecorder?.recordChange(
        entity: 'categories',
        op: SyncChangeOp.delete,
        id: category.id,
      );
    }
  }

  // ── Activities ────────────────────────────────────────────

  List<Activity> getActivitiesForProject(String projectId) {
    return _localDataSource
        .getActivities()
        .where((a) => a.projectId == projectId)
        .toList();
  }

  List<Activity> getAllActivities() {
    return _localDataSource.getActivities();
  }

  ActivityDetail getActivityDetail(String projectId, String activityId) {
    final activities = _localDataSource.getActivities();
    final activity = activities.firstWhere((a) => a.id == activityId);
    final projects = _localDataSource.getProjects();
    final project = projects.firstWhere((p) => p.id == projectId);
    final allTransactions = _transactionsReader.getAllTransactions();
    final transactions = allTransactions
        .where((t) => t.activityId == activityId)
        .toList();
    final categories = getAvailableOperationalTasks(projectId, activityId);

    final spent = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final deposited = transactions
        .where((t) => t.type == TransactionType.deposit)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Funding is based on currently available account liquidity only.
    final projectActivities = activities
        .where((a) => a.projectId == projectId)
        .toList();
    final projectFundedAmount = _calculateFundedAmountForProject(
      project: project,
      projects: projects,
      allActivities: activities,
      allTransactions: allTransactions,
    );
    final activityFunding = _allocateFundingSequentially(
      activities: projectActivities,
      fundedAmount: projectFundedAmount,
      transactions: allTransactions
          .where((t) => t.projectId == projectId)
          .toList(),
    );

    final activitySummary = ActivitySummary(
      activity: activity,
      spent: spent,
      deposited: deposited,
      fundedAmount: activityFunding[activityId] ?? 0.0,
      categories: _localDataSource
          .getCategories()
          .where((c) => c.activityId == activityId)
          .toList(),
      transactionCount: transactions.length,
    );

    return ActivityDetail(
      summary: activitySummary,
      transactions: transactions,
      categories: categories,
    );
  }

  double _calculateFundedAmountForProject({
    required Project project,
    required List<Project> projects,
    required List<Activity> allActivities,
    required List<Transaction> allTransactions,
  }) {
    double totalLiquidity = _calculateAvailableLiquidityFromAccounts(
      allTransactions,
    );
    final sortedProjects = List.of(projects)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    double fundedAmount = 0.0;
    for (final p in sortedProjects) {
      final pActivities = allActivities
          .where((a) => a.projectId == p.id)
          .toList();
      final pTransactions = allTransactions
          .where((t) => t.projectId == p.id)
          .toList();
      final pBudget = _calculateProjectBudget(
        project: p,
        projectActivities: pActivities,
      );
      final pSpent = pTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final pRemainingNeed = _calculateRemainingProjectNeed(
        totalBudget: pBudget,
        totalSpent: pSpent,
      );

      double pFundedAmount = 0.0;
      if (pRemainingNeed > 0) {
        pFundedAmount = pRemainingNeed < totalLiquidity
            ? pRemainingNeed
            : totalLiquidity;
        if (pFundedAmount < 0) pFundedAmount = 0;
        totalLiquidity -= pFundedAmount;
      }

      if (p.id == project.id) {
        fundedAmount = pFundedAmount;
        break;
      }
    }

    return fundedAmount;
  }

  double _calculateAvailableLiquidityFromAccounts(
    List<Transaction> transactions,
  ) {
    return transactions.fold(
      0.0,
      (sum, t) =>
          sum + (t.type == TransactionType.deposit ? t.amount : -t.amount),
    );
  }

  Map<String, double> _allocateFundingSequentially({
    required List<Activity> activities,
    required double fundedAmount,
    required List<Transaction> transactions,
  }) {
    final remaining = fundedAmount < 0 ? 0.0 : fundedAmount;
    final allocations = <String, double>{};
    var balance = remaining;

    final sorted = List<Activity>.from(activities)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final activity in sorted) {
      final budget = activity.budget ?? 0.0;
      final spent = transactions
          .where((t) => t.activityId == activity.id)
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final remainingNeed = _calculateRemainingProjectNeed(
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

  double _calculateProjectBudget({
    required Project project,
    required List<Activity> projectActivities,
  }) {
    return project.globalBudget ??
        projectActivities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));
  }

  double _calculateRemainingProjectNeed({
    required double totalBudget,
    required double totalSpent,
  }) {
    if (totalBudget <= 0) return 0.0;
    return (totalBudget - totalSpent).clamp(0.0, totalBudget);
  }

  Future<void> addActivity(Activity activity) async {
    final activities = _localDataSource.getActivities();
    final model = ActivityModel.fromEntity(activity);
    activities.add(model);
    await _localDataSource.saveActivities(activities);
    await _changeRecorder?.recordChange(
      entity: 'activities',
      op: SyncChangeOp.add,
      id: model.id,
      payload: model.toJson(),
    );
  }

  Future<void> updateActivity(Activity activity) async {
    final activities = _localDataSource.getActivities();
    final index = activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      activities[index] = ActivityModel.fromEntity(activity);
      await _localDataSource.saveActivities(activities);
      await _changeRecorder?.recordChange(
        entity: 'activities',
        op: SyncChangeOp.update,
        id: activity.id,
        payload: activities[index].toJson(),
      );
    }
  }

  Future<void> deleteActivity(String activityId) async {
    final activities = _localDataSource.getActivities();
    activities.removeWhere((a) => a.id == activityId);
    await _localDataSource.saveActivities(activities);
    await _changeRecorder?.recordChange(
      entity: 'activities',
      op: SyncChangeOp.delete,
      id: activityId,
    );

    final categories = _localDataSource.getCategories();
    final removedCategories = categories
        .where((c) => c.activityId == activityId)
        .toList();
    categories.removeWhere((c) => c.activityId == activityId);
    await _localDataSource.saveCategories(categories);
    for (final category in removedCategories) {
      await _changeRecorder?.recordChange(
        entity: 'categories',
        op: SyncChangeOp.delete,
        id: category.id,
      );
    }
  }

  // ── Categories ────────────────────────────────────────────

  List<OperationalTask> getProjectOperationalTasks(String projectId) {
    return _localDataSource
        .getCategories()
        .where((c) => c.projectId == projectId && c.activityId == null)
        .toList();
  }

  List<OperationalTask> getAllOperationalTasks() {
    return _localDataSource.getCategories();
  }

  List<OperationalTask> getActivityOperationalTasks(String activityId) {
    return _localDataSource
        .getCategories()
        .where((c) => c.activityId == activityId)
        .toList();
  }

  List<OperationalTask> getAvailableOperationalTasks(
    String projectId,
    String activityId,
  ) {
    return _localDataSource
        .getCategories()
        .where(
          (c) =>
              c.activityId == activityId ||
              (c.projectId == projectId && c.activityId == null),
        )
        .toList();
  }

  Future<void> addOperationalTask(OperationalTask task) async {
    final categories = _localDataSource.getCategories();
    final model = OperationalTaskModel.fromEntity(task);
    categories.add(model);
    await _localDataSource.saveCategories(categories);
    await _changeRecorder?.recordChange(
      entity: 'categories',
      op: SyncChangeOp.add,
      id: model.id,
      payload: model.toJson(),
    );
  }

  Future<void> updateOperationalTask(OperationalTask task) async {
    final categories = _localDataSource.getCategories();
    final index = categories.indexWhere((c) => c.id == task.id);
    if (index != -1) {
      categories[index] = OperationalTaskModel.fromEntity(task);
      await _localDataSource.saveCategories(categories);
      await _changeRecorder?.recordChange(
        entity: 'categories',
        op: SyncChangeOp.update,
        id: task.id,
        payload: categories[index].toJson(),
      );
    }
  }

  Future<void> deleteOperationalTask(String taskId) async {
    final categories = _localDataSource.getCategories();
    categories.removeWhere((c) => c.id == taskId);
    await _localDataSource.saveCategories(categories);
    await _changeRecorder?.recordChange(
      entity: 'categories',
      op: SyncChangeOp.delete,
      id: taskId,
    );
  }
}
