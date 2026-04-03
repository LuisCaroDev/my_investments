import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String appLocale;
  final String? currencyLocale;
  final String? currencySymbol;

  const SettingsState({
    required this.appLocale,
    this.currencyLocale,
    this.currencySymbol,
  });

  factory SettingsState.initial() => const SettingsState(
        appLocale: 'system', // 'system', 'es', 'en'
        currencyLocale: null,
        currencySymbol: null,
      );

  SettingsState copyWith({
    String? appLocale,
    String? currencyLocale,
    String? currencySymbol,
    bool clearCurrency = false,
  }) {
    return SettingsState(
      appLocale: appLocale ?? this.appLocale,
      currencyLocale: clearCurrency ? null : (currencyLocale ?? this.currencyLocale),
      currencySymbol: clearCurrency ? null : (currencySymbol ?? this.currencySymbol),
    );
  }

  @override
  List<Object?> get props => [appLocale, currencyLocale, currencySymbol];
}
