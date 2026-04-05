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

  const ProjectsRepository({required ProjectsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  // ── Data Migration ──────────────────────────────────────────
  
  Future<void> migrateIfNeeded() async {
    if (!_localDataSource.hasFinancialAccounts()) {
      // Create Initial Statement account
      final initialAccount = FinancialAccount(
        id: 'initial_statement',
        name: 'Initial Statement',
        type: FinancialAccountType.bank,
        balance: 0,
        createdAt: DateTime.now(),
      );
      await addAccount(initialAccount);
      
      // We also update projects default type/priority when reading since the constructor sets defaults
      final projects = _localDataSource.getProjects();
      await _localDataSource.saveProjects(projects);

      // Backfill transactions / convert capital injections
      final transactions = _localDataSource.getTransactions();
      bool txChanged = false;
      for (int i = 0; i < transactions.length; i++) {
        // Since TransactionModel.fromJson already converts capitalInjection -> deposit
        // and assigns 'initial_statement' to missing accountId, we just resave them!
        txChanged = true;
      }
      if (txChanged) {
        await _localDataSource.saveTransactions(transactions);
      }
    }
  }

  // ── Financial Accounts ────────────────────────────────────

  List<FinancialAccount> getAccounts() {
    return _localDataSource.getFinancialAccounts();
  }

  Future<void> addAccount(FinancialAccount account) async {
    final accounts = _localDataSource.getFinancialAccounts();
    accounts.add(FinancialAccountModel.fromEntity(account));
    await _localDataSource.saveFinancialAccounts(accounts);
  }

  Future<void> updateAccount(FinancialAccount account) async {
    final accounts = _localDataSource.getFinancialAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      accounts[index] = FinancialAccountModel.fromEntity(account);
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
    final allAccounts = _localDataSource.getFinancialAccounts();

    // 1. Calculate Total Liquidity
    double totalLiquidity = allAccounts.fold(0.0, (sum, acc) => sum + acc.balance);

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
    final allAccounts = _localDataSource.getFinancialAccounts();

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
        categories: categories,
        transactionCount: activityTransactions.length,
      );
    }).toList();

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
    final totalBudget =
        project.globalBudget ??
        projectActivities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));

    // Calculate Funding (needs global liquidity context)
    double totalLiquidity = allAccounts.fold(0.0, (sum, acc) => sum + acc.balance);
    var sortedProjects = List.of(projects)..sort((a, b) => a.priority.compareTo(b.priority));
    
    double myFundedAmount = 0.0;
    for(var p in sortedProjects) {
        final pActivities = allActivities.where((a) => a.projectId == p.id).toList();
        final pBudget = p.globalBudget ?? pActivities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));
        
        double pFundedAmount = 0.0;
        if (pBudget > 0) {
            pFundedAmount = pBudget < totalLiquidity ? pBudget : totalLiquidity;
            if (pFundedAmount < 0) pFundedAmount = 0;
            totalLiquidity -= pFundedAmount;
        }

        if (p.id == project.id) {
            myFundedAmount = pFundedAmount;
            break; // Stop once we calculated our target
        }
    }
    
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
    final transactions = _localDataSource
        .getTransactions()
        .where((t) => t.activityId == activityId)
        .toList();
    final categories = getAvailableCategories(projectId, activityId);

    final spent = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final deposited = transactions
        .where((t) => t.type == TransactionType.deposit)
        .fold(0.0, (sum, t) => sum + t.amount);

    final activitySummary = ActivitySummary(
      activity: activity,
      spent: spent,
      deposited: deposited,
      categories: _localDataSource.getCategories().where((c) => c.activityId == activityId).toList(),
      transactionCount: transactions.length,
    );

    return ActivityDetail(
      summary: activitySummary,
      transactions: transactions,
      categories: categories,
    );
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
}
