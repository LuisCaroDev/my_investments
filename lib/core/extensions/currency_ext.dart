import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:capitalflow/core/presentation/bloc/settings_cubit.dart';
import 'package:capitalflow/core/utils/money.dart';

extension CurrencyCentsExtension on int {
  String toCurrency(BuildContext context, {String? locale, String? symbol}) {
    final settings = context.read<SettingsCubit>().state;
    final effectiveLocale =
        locale ??
        settings.currencyLocale ??
        PlatformDispatcher.instance.locale.toString();
    final effectiveSymbol = symbol ?? settings.currencySymbol;

    // Fix for Soles: Enforce US formatting style to place the symbol at the beginning.
    final parseLocale = effectiveSymbol == 'S/' ? 'en_US' : effectiveLocale;

    final formatter = NumberFormat.currency(
      locale: parseLocale,
      symbol: effectiveSymbol,
    );
    return formatter.format(centsToDecimal(this));
  }

  String toCompactCurrency(
    BuildContext context, {
    String? locale,
    String? symbol,
  }) {
    final settings = context.read<SettingsCubit>().state;
    final effectiveLocale =
        locale ??
        settings.currencyLocale ??
        PlatformDispatcher.instance.locale.toString();
    final effectiveSymbol = symbol ?? settings.currencySymbol;

    // Fix for Soles: Enforce US formatting style to place the symbol at the beginning.
    final parseLocale = effectiveSymbol == 'S/' ? 'en_US' : effectiveLocale;

    final formatter = NumberFormat.compactCurrency(
      locale: parseLocale,
      symbol: effectiveSymbol,
    );
    return formatter.format(centsToDecimal(this));
  }
}
