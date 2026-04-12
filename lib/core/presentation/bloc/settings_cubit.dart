import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_investments/core/storage/profile_ids.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;

  static const _appLocaleKey = 'settings_app_locale';
  static const _currencyLocaleKey = 'settings_currency_locale';
  static const _currencySymbolKey = 'settings_currency_symbol';
  static const _themeModeKey = 'settings_theme_mode';
  static const _guestModeKey = 'settings_guest_mode';
  static const _activeProfileKey = 'settings_active_profile';
  static const _syncEnabledKeyPrefix = 'settings_sync_enabled_';

  SettingsCubit({required this.prefs}) : super(SettingsState.initial()) {
    _loadSettings();
  }

  void _loadSettings() {
    final appLocale = prefs.getString(_appLocaleKey) ?? 'system';
    final currencyLocale = prefs.getString(_currencyLocaleKey);
    final currencySymbol = prefs.getString(_currencySymbolKey);
    final themeName = prefs.getString(_themeModeKey) ?? 'system';
    final themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => ThemeMode.system,
    );
    final isGuestMode = prefs.getBool(_guestModeKey) ?? false;
    final storedProfile = prefs.getString(_activeProfileKey);
    final activeProfileId =
        isGuestMode ? guestProfileId : (storedProfile ?? guestProfileId);
    final syncEnabled = _loadSyncEnabled(activeProfileId);

    emit(SettingsState(
      appLocale: appLocale,
      currencyLocale: currencyLocale,
      currencySymbol: currencySymbol,
      themeMode: themeMode,
      isGuestMode: isGuestMode,
      activeProfileId: activeProfileId,
      syncEnabled: syncEnabled,
    ));
  }

  Future<void> updateAppLocale(String locale) async {
    await prefs.setString(_appLocaleKey, locale);
    emit(state.copyWith(appLocale: locale));
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await prefs.setString(_themeModeKey, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setGuestMode(bool isGuest) async {
    await prefs.setBool(_guestModeKey, isGuest);
    if (isGuest) {
      await _setActiveProfile(guestProfileId);
      emit(state.copyWith(
        isGuestMode: true,
        activeProfileId: guestProfileId,
        syncEnabled: false,
      ));
      return;
    }
    emit(state.copyWith(isGuestMode: false));
  }

  Future<void> setActiveProfileId(String profileId) async {
    await _setActiveProfile(profileId);
    final syncEnabled = _loadSyncEnabled(profileId);
    emit(state.copyWith(
      activeProfileId: profileId,
      syncEnabled: syncEnabled,
      isGuestMode: profileId == guestProfileId ? state.isGuestMode : false,
    ));
  }

  Future<void> setSyncEnabled(bool enabled) async {
    if (state.activeProfileId == guestProfileId) {
      emit(state.copyWith(syncEnabled: false));
      return;
    }
    await prefs.setBool(_syncKeyForProfile(state.activeProfileId), enabled);
    emit(state.copyWith(syncEnabled: enabled));
  }

  Future<void> updateCurrency(String? locale, String? symbol) async {
    if (locale == null && symbol == null) {
      await prefs.remove(_currencyLocaleKey);
      await prefs.remove(_currencySymbolKey);
      emit(state.copyWith(clearCurrency: true));
    } else {
      if (locale != null) await prefs.setString(_currencyLocaleKey, locale);
      if (symbol != null) await prefs.setString(_currencySymbolKey, symbol);
      emit(state.copyWith(
        currencyLocale: locale,
        currencySymbol: symbol,
      ));
    }
  }

  String _syncKeyForProfile(String profileId) {
    return '$_syncEnabledKeyPrefix$profileId';
  }

  bool _loadSyncEnabled(String profileId) {
    if (profileId == guestProfileId) return false;
    return prefs.getBool(_syncKeyForProfile(profileId)) ?? false;
  }

  Future<void> _setActiveProfile(String profileId) async {
    await prefs.setString(_activeProfileKey, profileId);
  }
}
