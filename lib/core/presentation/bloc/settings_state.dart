import 'package:equatable/equatable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/core/storage/profile_ids.dart';

class SettingsState extends Equatable {
  final String appLocale;
  final String? currencyLocale;
  final String? currencySymbol;
  final ThemeMode themeMode;
  final bool isGuestMode;
  final String activeProfileId;
  final bool syncEnabled;

  const SettingsState({
    required this.appLocale,
    this.currencyLocale,
    this.currencySymbol,
    required this.themeMode,
    required this.isGuestMode,
    required this.activeProfileId,
    required this.syncEnabled,
  });

  factory SettingsState.initial() => const SettingsState(
        appLocale: 'system', // 'system', 'es', 'en'
        currencyLocale: null,
        currencySymbol: null,
        themeMode: ThemeMode.system,
        isGuestMode: false,
        activeProfileId: guestProfileId,
        syncEnabled: false,
      );

  SettingsState copyWith({
    String? appLocale,
    String? currencyLocale,
    String? currencySymbol,
    ThemeMode? themeMode,
    bool? isGuestMode,
    String? activeProfileId,
    bool? syncEnabled,
    bool clearCurrency = false,
  }) {
    return SettingsState(
      appLocale: appLocale ?? this.appLocale,
      currencyLocale:
          clearCurrency ? null : (currencyLocale ?? this.currencyLocale),
      currencySymbol:
          clearCurrency ? null : (currencySymbol ?? this.currencySymbol),
      themeMode: themeMode ?? this.themeMode,
      isGuestMode: isGuestMode ?? this.isGuestMode,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      syncEnabled: syncEnabled ?? this.syncEnabled,
    );
  }

  @override
  List<Object?> get props => [
    appLocale,
    currencyLocale,
    currencySymbol,
    themeMode,
    isGuestMode,
    activeProfileId,
    syncEnabled,
  ];
}
