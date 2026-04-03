import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/models/project_model.dart';
import 'package:my_investments/projects/data/models/activity_model.dart';
import 'package:my_investments/projects/data/models/category_model.dart';
import 'package:my_investments/projects/data/models/transaction_model.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';

class ProjectsRepository {
  final ProjectsLocalDataSource _localDataSource;

  const ProjectsRepository({required ProjectsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  // ── Projects ──────────────────────────────────────────────

  List<Project> getProjects() => _localDataSource.getProjects();

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
