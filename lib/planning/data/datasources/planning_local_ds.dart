import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/storage/sync_snapshot_provider.dart';
import 'package:my_investments/core/storage/profile_keys.dart';
import 'package:my_investments/planning/data/models/project_model.dart';
import 'package:my_investments/planning/data/models/activity_model.dart';
import 'package:my_investments/planning/data/models/operational_task_model.dart';

class PlanningLocalDataSource implements SyncSnapshotProvider {
  static const _projectsKey = 'projects';
  static const _activitiesKey = 'activities';
  static const _categoriesKey = 'categories';

  final SharedPreferences _prefs;
  final String _profileId;

  const PlanningLocalDataSource({
    required SharedPreferences prefs,
    required String profileId,
  })  : _prefs = prefs,
        _profileId = profileId;

  String _key(String key) => profileKey(_profileId, key);

  // ── Projects ──────────────────────────────────────────────

  List<ProjectModel> getProjects() {
    final data = _prefs.getString(_key(_projectsKey));
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProjects(List<ProjectModel> projects) async {
    final data = jsonEncode(projects.map((e) => e.toJson()).toList());
    await _prefs.setString(_key(_projectsKey), data);
  }

  // ── Activities ────────────────────────────────────────────

  List<ActivityModel> getActivities() {
    final data = _prefs.getString(_key(_activitiesKey));
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveActivities(List<ActivityModel> activities) async {
    final data = jsonEncode(activities.map((e) => e.toJson()).toList());
    await _prefs.setString(_key(_activitiesKey), data);
  }

  // ── Categories ────────────────────────────────────────────

  List<OperationalTaskModel> getCategories() {
    final data = _prefs.getString(_key(_categoriesKey));
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => OperationalTaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<OperationalTaskModel> categories) async {
    final data = jsonEncode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_key(_categoriesKey), data);
  }

  @override
  Map<String, List<Map<String, dynamic>>> exportSnapshot() {
    return {
      'projects': getProjects().map((e) => e.toJson()).toList(),
      'activities': getActivities().map((e) => e.toJson()).toList(),
      'categories': getCategories().map((e) => e.toJson()).toList(),
    };
  }

  @override
  Future<void> importSnapshot(
    Map<String, List<Map<String, dynamic>>> data,
  ) async {
    final projects = (data['projects'] ?? [])
        .map((e) => ProjectModel.fromJson(e))
        .toList();
    final activities = (data['activities'] ?? [])
        .map((e) => ActivityModel.fromJson(e))
        .toList();
    final categories = (data['categories'] ?? [])
        .map((e) => OperationalTaskModel.fromJson(e))
        .toList();

    await saveProjects(projects);
    await saveActivities(activities);
    await saveCategories(categories);
  }
}
