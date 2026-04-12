import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:my_investments/core/storage/profile_keys.dart';
import 'package:my_investments/sync/domain/entities/pending_change.dart';

class SyncLocalDataSource {
  static const _pendingChangesKey = 'sync_pending_changes';
  static const _lastSyncKey = 'sync_last_sync';
  static const _deviceIdKey = 'sync_device_id';

  final SharedPreferences _prefs;
  final String _profileId;

  const SyncLocalDataSource({
    required SharedPreferences prefs,
    required String profileId,
  })  : _prefs = prefs,
        _profileId = profileId;

  String _key(String key) => profileKey(_profileId, key);

  List<PendingChange> getPendingChanges() {
    final data = _prefs.getString(_key(_pendingChangesKey));
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => PendingChange.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePendingChanges(List<PendingChange> changes) async {
    final data = jsonEncode(changes.map((e) => e.toJson()).toList());
    await _prefs.setString(_key(_pendingChangesKey), data);
  }

  Future<void> addPendingChange(PendingChange change) async {
    final changes = getPendingChanges();
    changes.add(change);
    await savePendingChanges(changes);
  }

  Future<void> clearPendingChanges() async {
    await _prefs.remove(_key(_pendingChangesKey));
  }

  DateTime? getLastSync() {
    final value = _prefs.getString(_key(_lastSyncKey));
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> setLastSync(DateTime time) async {
    await _prefs.setString(_key(_lastSyncKey), time.toIso8601String());
  }

  String getOrCreateDeviceId() {
    final existing = _prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final deviceId = const Uuid().v4();
    _prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }
}
