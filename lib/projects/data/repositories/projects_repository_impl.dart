import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/models/project_model.dart';
import 'package:my_investments/projects/data/models/activity_model.dart';
import 'package:my_investments/projects/data/models/category_model.dart';
import 'package:my_investments/projects/data/models/transaction_model.dart';
import 'package:my_investments/projects/data/models/financial_account_model.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/domain/entities/activity_summary.dart';
import 'package:my_investments/projects/domain/entities/project_summary.dart';
import 'package:my_investments/projects/domain/entities/project_detail.dart';
import 'package:my_investments/projects/domain/entities/activity_detail.dart';
import 'package:my_investments/projects/domain/entities/financial_account.dart';

class ProjectsRepository {
  final ProjectsLocalDataSource _localDataSource;
  static const String systemAccountProjectId = '__accounts__';

  const ProjectsRepository({required ProjectsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;
  // ── Financial Accounts ────────────────────────────────────

  List<FinancialAccount> getAccounts() {
    final accounts = _localDataSource.getFinancialAccounts();
    final transactions = _localDataSource.getTransactions();
    return _withComputedBalances(accounts, transactions);
  }

  Future<void> addAccount(FinancialAccount account) async {
    final initialDeposit = account.balance > 0 ? account.balance : 0.0;
    final accounts = _localDataSource.getFinancialAccounts();
    accounts.add(
      FinancialAccountModel.fromEntity(account.copyWith(balance: 0)),
    );
    await _localDataSource.saveFinancialAccounts(accounts);
    if (initialDeposit > 0) {
      await addTransaction(
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          projectId: systemAccountProjectId,
          activityId: null,
          categoryId: null,
          accountId: account.id,
          type: TransactionType.deposit,
          amount: initialDeposit,
          date: DateTime.now(),
          description: 'Initial balance',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateAccount(FinancialAccount account) async {
    final accounts = _localDataSource.getFinancialAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      final current = accounts[index];
      accounts[index] = FinancialAccountModel.fromEntity(
        account.copyWith(balance: current.balance),
      );
      await _localDataSource.saveFinancialAccounts(accounts);
    }
  }

  Future<void> deleteAccount(String accountId) async {
    final accounts = _localDataSource.getFinancialAccounts();
    accounts.removeWhere((a) => a.id == accountId);
    await _localDataSource.saveFinancialAccounts(accounts);
  }

  // ── Funding Distribution Algorithm ──────────────────────────

  List<ProjectSummary> _buildProjectSummaries(ProjectType type) {
    var allProjects = _localDataSource.getProjects();
    final allActivities = _localDataSource.getActivities();
    final allTransactions = _localDataSource.getTransactions();

    // 1. Calculate Total Funding from account deposits
    double totalLiquidity =
        _calculateTotalFundingFromAccountDeposits(allTransactions);

    // 2. Sort all projects by priority ASC
    allProjects.sort((a, b) => a.priority.compareTo(b.priority));

    List<ProjectSummary> allSummaries = [];

    // 3. Iterate and drain liquidity
    for (var project in allProjects) {
      final projectActivities =
          allActivities.where((a) => a.projectId == project.id).toList();
      final projectTransactions =
          allTransactions.where((t) => t.projectId == project.id).toList();

      final totalSpent = projectTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalDeposited = projectTransactions
          .where((t) => t.type == TransactionType.deposit)
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalBudget = project.globalBudget ??
          projectActivities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));

      // Calculate Funding
      double fundedAmount = 0.0;
      if (totalBudget > 0) {
        fundedAmount = totalBudget < totalLiquidity ? totalBudget : totalLiquidity;
        if (fundedAmount < 0) fundedAmount = 0; // Negative liquidity guard
        totalLiquidity -= fundedAmount;
      }

      final remainingToFund = totalBudget > 0 ? (totalBudget - fundedAmount) : 0.0;

      allSummaries.add(ProjectSummary(
        project: project,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        totalDeposited: totalDeposited,
        fundedAmount: fundedAmount,
        remainingToFund: remainingToFund,
        activityCount: projectActivities.length,
      ));
    }

    // 4. Return only the requested type
    return allSummaries.where((s) => s.project.type == type).toList();
  }

  // ── Investments API ───────────────────────────────────────

  List<ProjectSummary> getInvestmentSummaries() {
    return _buildProjectSummaries(ProjectType.investment);
  }

  ProjectDetail getInvestmentDetail(String projectId) => getProjectDetail(projectId);

  Future<void> addInvestment(Project project) async {
    final investment = project.copyWith(type: ProjectType.investment);
    final projects = _localDataSource.getProjects();
    final maxPriority = projects.where((p) => p.type == ProjectType.investment)
      .fold(0, (max, p) => p.priority > max ? p.priority : max);
    
    projects.add(ProjectModel.fromEntity(investment.copyWith(priority: maxPriority + 1)));
    await _localDataSource.saveProjects(projects);
  }

  Future<void> updateInvestment(Project project) async {
    final projects = _localDataSource.getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = ProjectModel.fromEntity(project);
      await _localDataSource.saveProjects(projects);
    }
  }

  Future<void> deleteInvestment(String projectId) => _deleteProjectDataAndCascade(projectId);

  Future<void> reorderInvestments(List<String> orderedIds) async {
    final projects = _localDataSource.getProjects();
    for (int i = 0; i < orderedIds.length; i++) {
        final id = orderedIds[i];
        final index = projects.indexWhere((p) => p.id == id);
        if (index != -1) {
            projects[index] = ProjectModel.fromEntity(projects[index].copyWith(priority: i));
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
    for(var p in projects) {
        if(p.type == ProjectType.savingsGoal && p.priority > maxPriority) {
            maxPriority = p.priority;
        }
    }

    projects.add(ProjectModel.fromEntity(goal.copyWith(priority: maxPriority + 1)));
    await _localDataSource.saveProjects(projects);
  }

  Future<void> updateGoal(Project project) async {
    final projects = _localDataSource.getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = ProjectModel.fromEntity(project);
      await _localDataSource.saveProjects(projects);
    }
  }

  Future<void> deleteGoal(String projectId) => _deleteProjectDataAndCascade(projectId);

  Future<void> reorderGoals(List<String> orderedIds) async {
    final projects = _localDataSource.getProjects();
    for (int i = 0; i < orderedIds.length; i++) {
        final id = orderedIds[i];
        final index = projects.indexWhere((p) => p.id == id);
        if (index != -1) {
            projects[index] = ProjectModel.fromEntity(projects[index].copyWith(priority: i));
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
        projects[index] = ProjectModel.fromEntity(projects[index].copyWith(priority: i));
      }
    }
    await _localDataSource.saveProjects(projects);
  }

  // ── Shared Project Helpers ───────────────────────────────

  ProjectDetail getProjectDetail(String projectId) {
    final projects = _localDataSource.getProjects();
    final project = projects.firstWhere((p) => p.id == projectId);
    final allActivities = _localDataSource.getActivities();
    final projectActivities =
        allActivities.where((a) => a.projectId == projectId).toList();
    final allTransactions = _localDataSource.getTransactions();
    final projectTransactions =
        allTransactions.where((t) => t.projectId == projectId).toList();
    final allCategories = _localDataSource.getCategories();
    // Funding is based on account deposits only.

    // Project-level details
    final projectLevelTransactions = projectTransactions
        .where((t) => t.activityId == null)
        .toList();
    final projectLevelSpent = projectLevelTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final projectCategories = allCategories
        .where((c) => c.projectId == projectId && c.activityId == null)
        .toList();

    final totalSpent = projectTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalDeposited = projectTransactions
        .where((t) => t.type == TransactionType.deposit)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalBudget =
        project.globalBudget ??
        projectActivities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));

    final myFundedAmount = _calculateFundedAmountForProject(
      project: project,
      projects: projects,
      allActivities: allActivities,
      allTransactions: allTransactions,
    );

    final availableFundingForActivities =
        (myFundedAmount - projectLevelSpent).clamp(0.0, myFundedAmount);
    final activityFunding = _allocateFundingSequentially(
      activities: projectActivities,
      fundedAmount: availableFundingForActivities,
    );

    // Map activity summaries
    final activitySummaries = projectActivities.map((activity) {
      final activityTransactions =
          projectTransactions.where((t) => t.activityId == activity.id).toList();
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
    
    final remainingToFund = totalBudget > 0 ? (totalBudget - myFundedAmount) : 0.0;

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

    final activities = _localDataSource.getActivities();
    activities.removeWhere((a) => a.projectId == projectId);
    await _localDataSource.saveActivities(activities);

    final categories = _localDataSource.getCategories();
    categories.removeWhere((c) => c.projectId == projectId);
    await _localDataSource.saveCategories(categories);

    final transactions = _localDataSource.getTransactions();
    transactions.removeWhere((t) => t.projectId == projectId);
    await _localDataSource.saveTransactions(transactions);
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
    final allTransactions = _localDataSource.getTransactions();
    final transactions =
        allTransactions.where((t) => t.activityId == activityId).toList();
    final categories = getAvailableCategories(projectId, activityId);

    final spent = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final deposited = transactions
        .where((t) => t.type == TransactionType.deposit)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Funding is based on account deposits only.
    final projectActivities =
        activities.where((a) => a.projectId == projectId).toList();
    final projectLevelSpent = allTransactions
        .where((t) => t.projectId == projectId && t.activityId == null)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final projectFundedAmount = _calculateFundedAmountForProject(
      project: project,
      projects: projects,
      allActivities: activities,
      allTransactions: allTransactions,
    );
    final availableFundingForActivities =
        (projectFundedAmount - projectLevelSpent)
            .clamp(0.0, projectFundedAmount);
    final activityFunding = _allocateFundingSequentially(
      activities: projectActivities,
      fundedAmount: availableFundingForActivities,
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
    double totalLiquidity =
        _calculateTotalFundingFromAccountDeposits(allTransactions);
    final sortedProjects =
        List.of(projects)..sort((a, b) => a.priority.compareTo(b.priority));

    double fundedAmount = 0.0;
    for (final p in sortedProjects) {
      final pActivities =
          allActivities.where((a) => a.projectId == p.id).toList();
      final pBudget = p.globalBudget ??
          pActivities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));

      double pFundedAmount = 0.0;
      if (pBudget > 0) {
        pFundedAmount = pBudget < totalLiquidity ? pBudget : totalLiquidity;
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

  double _calculateTotalFundingFromAccountDeposits(
    List<Transaction> transactions,
  ) {
    return transactions
        .where(
          (t) =>
              t.projectId == systemAccountProjectId &&
              t.type == TransactionType.deposit,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> _allocateFundingSequentially({
    required List<Activity> activities,
    required double fundedAmount,
  }) {
    final remaining = fundedAmount < 0 ? 0.0 : fundedAmount;
    final allocations = <String, double>{};
    var balance = remaining;

    final sorted = List<Activity>.from(activities)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final activity in sorted) {
      final budget = activity.budget ?? 0.0;
      if (budget <= 0 || balance <= 0) {
        allocations[activity.id] = 0.0;
        continue;
      }
      final allocated = balance < budget ? balance : budget;
      allocations[activity.id] = allocated;
      balance -= allocated;
    }

    return allocations;
  }

  Future<void> addActivity(Activity activity) async {
    final activities = _localDataSource.getActivities();
    activities.add(ActivityModel.fromEntity(activity));
    await _localDataSource.saveActivities(activities);
  }

  Future<void> updateActivity(Activity activity) async {
    final activities = _localDataSource.getActivities();
    final index = activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      activities[index] = ActivityModel.fromEntity(activity);
      await _localDataSource.saveActivities(activities);
    }
  }

  Future<void> deleteActivity(String activityId) async {
    final activities = _localDataSource.getActivities();
    activities.removeWhere((a) => a.id == activityId);
    await _localDataSource.saveActivities(activities);

    final categories = _localDataSource.getCategories();
    categories.removeWhere((c) => c.activityId == activityId);
    await _localDataSource.saveCategories(categories);

    final transactions = _localDataSource.getTransactions();
    transactions.removeWhere((t) => t.activityId == activityId);
    await _localDataSource.saveTransactions(transactions);
  }

  // ── Categories ────────────────────────────────────────────

  List<Category> getProjectCategories(String projectId) {
    return _localDataSource
        .getCategories()
        .where((c) => c.projectId == projectId && c.activityId == null)
        .toList();
  }

  List<Category> getAllCategories() {
    return _localDataSource.getCategories();
  }

  List<Category> getActivityCategories(String activityId) {
    return _localDataSource
        .getCategories()
        .where((c) => c.activityId == activityId)
        .toList();
  }

  List<Category> getAvailableCategories(String projectId, String activityId) {
    return _localDataSource
        .getCategories()
        .where((c) =>
            c.activityId == activityId ||
            (c.projectId == projectId && c.activityId == null))
        .toList();
  }

  Future<void> addCategory(Category category) async {
    final categories = _localDataSource.getCategories();
    categories.add(CategoryModel.fromEntity(category));
    await _localDataSource.saveCategories(categories);
  }

  Future<void> updateCategory(Category category) async {
    final categories = _localDataSource.getCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = CategoryModel.fromEntity(category);
      await _localDataSource.saveCategories(categories);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final categories = _localDataSource.getCategories();
    categories.removeWhere((c) => c.id == categoryId);
    await _localDataSource.saveCategories(categories);
  }

  // ── Transactions ──────────────────────────────────────────

  List<Transaction> getTransactionsForProject(String projectId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.projectId == projectId)
        .toList();
  }

  List<Transaction> getAllTransactions() {
    return _localDataSource.getTransactions();
  }

  List<Transaction> getTransactionsForAccount(String accountId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.accountId == accountId)
        .toList();
  }

  List<Transaction> getTransactionsForActivity(String activityId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.activityId == activityId)
        .toList();
  }

  List<Transaction> getProjectLevelTransactions(String projectId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.projectId == projectId && t.activityId == null)
        .toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = _localDataSource.getTransactions();
    transactions.add(TransactionModel.fromEntity(transaction));
    await _localDataSource.saveTransactions(transactions);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final transactions = _localDataSource.getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = TransactionModel.fromEntity(transaction);
      await _localDataSource.saveTransactions(transactions);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    final transactions = _localDataSource.getTransactions();
    transactions.removeWhere((t) => t.id == transactionId);
    await _localDataSource.saveTransactions(transactions);
  }

  Future<void> addAccountDeposit({
    required String accountId,
    required double amount,
    String? description,
    DateTime? date,
  }) async {
    await addTransaction(
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: systemAccountProjectId,
        activityId: null,
        categoryId: null,
        accountId: accountId,
        type: TransactionType.deposit,
        amount: amount,
        date: date ?? DateTime.now(),
        description: description,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<FinancialAccount> _withComputedBalances(
    List<FinancialAccount> accounts,
    List<Transaction> transactions,
  ) {
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

    return accounts
        .map(
          (account) => account.copyWith(
            balance: totals[account.id] ?? 0.0,
          ),
        )
        .toList();
  }
}
