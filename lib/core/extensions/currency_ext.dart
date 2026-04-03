import 'dart:ui';

import 'package:intl/intl.dart';

extension CurrencyExtension on num {
  String toCurrency({String? locale, String? symbol}) {
    final effectiveLocale = locale ?? PlatformDispatcher.instance.locale.toString();
    final formatter = NumberFormat.currency(
      locale: effectiveLocale,
      symbol: symbol,
    );
    return formatter.format(this);
  }

  String toCompactCurrency({String? locale, String? symbol}) {
    final effectiveLocale = locale ?? PlatformDispatcher.instance.locale.toString();
    final formatter = NumberFormat.compactCurrency(
      locale: effectiveLocale,
      symbol: symbol,
    );
    return formatter.format(this);
  }
}
