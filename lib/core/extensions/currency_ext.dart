import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';

extension CurrencyExtension on num {
  String toCurrency(BuildContext context, {String? locale, String? symbol}) {
    final settings = context.read<SettingsCubit>().state;
    final effectiveLocale = locale ?? settings.currencyLocale ?? PlatformDispatcher.instance.locale.toString();
    final effectiveSymbol = symbol ?? settings.currencySymbol;

    // Fix for Soles: Enforce US formatting style to place the symbol at the beginning.
    final parseLocale = effectiveSymbol == 'S/' ? 'en_US' : effectiveLocale;
    
    final formatter = NumberFormat.currency(
      locale: parseLocale,
      symbol: effectiveSymbol,
    );
    return formatter.format(this);
  }

  String toCompactCurrency(BuildContext context, {String? locale, String? symbol}) {
    final settings = context.read<SettingsCubit>().state;
    final effectiveLocale = locale ?? settings.currencyLocale ?? PlatformDispatcher.instance.locale.toString();
    final effectiveSymbol = symbol ?? settings.currencySymbol;

    // Fix for Soles: Enforce US formatting style to place the symbol at the beginning.
    final parseLocale = effectiveSymbol == 'S/' ? 'en_US' : effectiveLocale;

    final formatter = NumberFormat.compactCurrency(
      locale: parseLocale,
      symbol: effectiveSymbol,
    );
    return formatter.format(this);
  }
}
