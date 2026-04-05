import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/models/project_model.dart';
import 'package:my_investments/projects/data/models/activity_model.dart';
import 'package:my_investments/projects/data/models/category_model.dart';
import 'package:my_investments/projects/data/models/transaction_model.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/domain/entities/activity_summary.dart';
import 'package:my_investments/projects/domain/entities/project_summary.dart';
import 'package:my_investments/projects/domain/entities/project_detail.dart';
import 'package:my_investments/projects/domain/entities/activity_detail.dart';

class ProjectsRepository {
  final ProjectsLocalDataSource _localDataSource;

  const ProjectsRepository({required ProjectsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  // ── Projects ──────────────────────────────────────────────

  List<Project> getProjects() => _localDataSource.getProjects();

  List<ProjectSummary> getProjectSummaries() {
    final projects = _localDataSource.getProjects();
    final allActivities = _localDataSource.getActivities();
    final allTransactions = _localDataSource.getTransactions();

    return projects.map((project) {
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
      final totalCapitalInjected = projectTransactions
          .where((t) => t.type == TransactionType.capitalInjection)
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalBudget =
          project.globalBudget ??
          projectActivities.fold<double>(
            0.0,
            (sum, a) => sum + (a.budget ?? 0),
          );

      return ProjectSummary(
        project: project,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        totalDeposited: totalDeposited,
        totalCapitalInjected: totalCapitalInjected,
        activityCount: projectActivities.length,
      );
    }).toList();
  }

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
      final capitalInjected = activityTransactions
          .where((t) => t.type == TransactionType.capitalInjection)
          .fold(0.0, (sum, t) => sum + t.amount);
      final categories = allCategories
          .where((c) => c.activityId == activity.id)
          .toList();

      return ActivitySummary(
        activity: activity,
        spent: spent,
        deposited: deposited,
        capitalInjected: capitalInjected,
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
    final totalCapitalInjected = projectTransactions
        .where((t) => t.type == TransactionType.capitalInjection)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalBudget =
        project.globalBudget ??
        projectActivities.fold<double>(0.0, (sum, a) => sum + (a.budget ?? 0));

    return ProjectDetail(
      project: project,
      activitySummaries: activitySummaries,
      projectLevelTransactions: projectLevelTransactions,
      projectCategories: projectCategories,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      totalDeposited: totalDeposited,
      totalCapitalInjected: totalCapitalInjected,
    );
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
    final capitalInjected = transactions
        .where((t) => t.type == TransactionType.capitalInjection)
        .fold(0.0, (sum, t) => sum + t.amount);

    final activitySummary = ActivitySummary(
      activity: activity,
      spent: spent,
      deposited: deposited,
      capitalInjected: capitalInjected,
      categories: _localDataSource.getCategories().where((c) => c.activityId == activityId).toList(),
      transactionCount: transactions.length,
    );

    return ActivityDetail(
      summary: activitySummary,
      transactions: transactions,
      categories: categories,
    );
  }

  Future<void> addProject(Project project) async {
    final projects = _localDataSource.getProjects();
    projects.add(ProjectModel.fromEntity(project));
    await _localDataSource.saveProjects(projects);
  }

  Future<void> updateProject(Project project) async {
    final projects = _localDataSource.getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = ProjectModel.fromEntity(project);
      await _localDataSource.saveProjects(projects);
    }
  }

  Future<void> deleteProject(String projectId) async {
    final projects = _localDataSource.getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _localDataSource.saveProjects(projects);

    // Cascade delete
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

    // Cascade delete categories and transactions
    final categories = _localDataSource.getCategories();
    categories.removeWhere((c) => c.activityId == activityId);
    await _localDataSource.saveCategories(categories);

    final transactions = _localDataSource.getTransactions();
    transactions.removeWhere((t) => t.activityId == activityId);
    await _localDataSource.saveTransactions(transactions);
  }

  // ── Categories ────────────────────────────────────────────

  /// Returns categories scoped to a project (activityId == null).
  List<Category> getProjectCategories(String projectId) {
    return _localDataSource
        .getCategories()
        .where((c) => c.projectId == projectId && c.activityId == null)
        .toList();
  }

  List<Category> getAllCategories() {
    return _localDataSource.getCategories();
  }

  /// Returns categories scoped to an activity.
  List<Category> getActivityCategories(String activityId) {
    return _localDataSource
        .getCategories()
        .where((c) => c.activityId == activityId)
        .toList();
  }

  /// Returns all available categories for an activity:
  /// activity-scoped + project-scoped.
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

  List<Transaction> getTransactionsForActivity(String activityId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.activityId == activityId)
        .toList();
  }

  /// Project-level transactions (no activity assigned).
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
