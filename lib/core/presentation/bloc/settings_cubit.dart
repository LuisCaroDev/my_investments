import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;

  static const _appLocaleKey = 'settings_app_locale';
  static const _currencyLocaleKey = 'settings_currency_locale';
  static const _currencySymbolKey = 'settings_currency_symbol';
  static const _themeModeKey = 'settings_theme_mode';

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

    emit(SettingsState(
      appLocale: appLocale,
      currencyLocale: currencyLocale,
      currencySymbol: currencySymbol,
      themeMode: themeMode,
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
}
