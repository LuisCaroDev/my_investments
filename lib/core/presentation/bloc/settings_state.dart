import 'package:equatable/equatable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SettingsState extends Equatable {
  final String appLocale;
  final String? currencyLocale;
  final String? currencySymbol;
  final ThemeMode themeMode;

  const SettingsState({
    required this.appLocale,
    this.currencyLocale,
    this.currencySymbol,
    required this.themeMode,
  });

  factory SettingsState.initial() => const SettingsState(
        appLocale: 'system', // 'system', 'es', 'en'
        currencyLocale: null,
        currencySymbol: null,
        themeMode: ThemeMode.system,
      );

  SettingsState copyWith({
    String? appLocale,
    String? currencyLocale,
    String? currencySymbol,
    ThemeMode? themeMode,
    bool clearCurrency = false,
  }) {
    return SettingsState(
      appLocale: appLocale ?? this.appLocale,
      currencyLocale:
          clearCurrency ? null : (currencyLocale ?? this.currencyLocale),
      currencySymbol:
          clearCurrency ? null : (currencySymbol ?? this.currencySymbol),
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [
    appLocale,
    currencyLocale,
    currencySymbol,
    themeMode,
  ];
}
