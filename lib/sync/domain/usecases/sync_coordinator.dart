import 'dart:async';

import 'package:my_investments/core/constants/supabase_config.dart';
import 'package:my_investments/core/storage/sync_snapshot_provider.dart';
import 'package:my_investments/auth/data/repositories/auth_repository.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/sync/data/repositories/sync_repository.dart';
import 'package:my_investments/sync/domain/usecases/sync_service.dart';

class SyncCoordinator {
  final SyncService _service;
  final SyncRepository _repository;
  final List<SyncSnapshotProvider> _providers;
  final AuthRepository _authRepository;
  final SettingsCubit _settingsCubit;

  Timer? _debounce;
  bool _syncing = false;
  bool _initialized = false;

  SyncCoordinator({
    required SyncService service,
    required SyncRepository repository,
    required List<SyncSnapshotProvider> providers,
    required AuthRepository authRepository,
    required SettingsCubit settingsCubit,
  })  : _service = service,
        _repository = repository,
        _providers = providers,
        _authRepository = authRepository,
        _settingsCubit = settingsCubit;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _ensureSynced();
  }

  void onLocalChange() {
    if (!_canSync) return;
    _schedulePush();
  }

  Future<void> onSyncEnabledChanged(bool enabled) async {
    if (!enabled) {
      _debounce?.cancel();
      return;
    }
    await _ensureSynced();
  }

  Future<void> onAuthenticated() async {
    if (!_settingsCubit.state.syncEnabled) return;
    await _ensureSynced();
  }

  void dispose() {
    _debounce?.cancel();
  }

  bool get _canSync {
    if (!SupabaseConfig.isConfigured) return false;
    if (!_settingsCubit.state.syncEnabled) return false;
    return _authRepository.currentUser != null;
  }

  Future<void> _ensureSynced() async {
    if (!_canSync) return;
    await _pullIfRemoteNewer();
    if (_repository.getPendingChanges().isNotEmpty) {
      await _pushNow();
    }
  }

  Future<void> _pullIfRemoteNewer() async {
    final user = _authRepository.currentUser;
    if (user == null) return;
    try {
      await _service.pullIfRemoteNewer(
        userId: user.id,
        providers: _providers,
      );
    } catch (_) {}
  }

  void _schedulePush() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), _pushNow);
  }

  Future<void> _pushNow() async {
    if (!_canSync) return;
    if (_syncing) return;
    final user = _authRepository.currentUser;
    if (user == null) return;
    _syncing = true;
    try {
      await _service.pushSnapshot(
        userId: user.id,
        providers: _providers,
      );
    } catch (_) {
      // ignore errors to avoid blocking UI; manual backup/restore remains
    } finally {
      _syncing = false;
    }
  }
}
