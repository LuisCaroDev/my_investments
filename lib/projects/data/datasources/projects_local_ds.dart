import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/projects/data/models/project_model.dart';
import 'package:my_investments/projects/data/models/activity_model.dart';
import 'package:my_investments/projects/data/models/category_model.dart';
import 'package:my_investments/projects/data/models/transaction_model.dart';

class ProjectsLocalDataSource {
  static const _projectsKey = 'projects';
  static const _activitiesKey = 'activities';
  static const _categoriesKey = 'categories';
  static const _transactionsKey = 'transactions';

  final SharedPreferences _prefs;

  const ProjectsLocalDataSource({required SharedPreferences prefs})
      : _prefs = prefs;

  // ── Projects ──────────────────────────────────────────────

  List<ProjectModel> getProjects() {
    final data = _prefs.getString(_projectsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProjects(List<ProjectModel> projects) async {
    final data = jsonEncode(projects.map((e) => e.toJson()).toList());
    await _prefs.setString(_projectsKey, data);
  }

  // ── Activities ────────────────────────────────────────────

  List<ActivityModel> getActivities() {
    final data = _prefs.getString(_activitiesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveActivities(List<ActivityModel> activities) async {
    final data = jsonEncode(activities.map((e) => e.toJson()).toList());
    await _prefs.setString(_activitiesKey, data);
  }

  // ── Categories ────────────────────────────────────────────

  List<CategoryModel> getCategories() {
    final data = _prefs.getString(_categoriesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<CategoryModel> categories) async {
    final data = jsonEncode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_categoriesKey, data);
  }

  // ── Transactions ──────────────────────────────────────────

  List<TransactionModel> getTransactions() {
    final data = _prefs.getString(_transactionsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final data = jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString(_transactionsKey, data);
  }
}
