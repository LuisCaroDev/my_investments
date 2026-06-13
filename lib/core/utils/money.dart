import 'dart:math' as math;

int? parseMoneyToCents(String? raw) {
  final input = raw?.trim() ?? '';
  if (input.isEmpty) return null;

  final normalized = input.replaceAll(',', '');
  final match = RegExp(r'^(-?)(\d+)(?:\.(\d+))?$').firstMatch(normalized);
  if (match == null) {
    return null;
  }

  final sign = match.group(1) == '-' ? -1 : 1;
  final units = int.parse(match.group(2)!);
  final fraction = match.group(3) ?? '';

  final paddedFraction = fraction.padRight(3, '0');
  final cents = int.parse(paddedFraction.substring(0, 2));
  final roundingDigit = int.parse(paddedFraction[2]);
  final shouldRoundUp = roundingDigit >= 5;

  var totalCents = (units * 100) + cents;
  if (shouldRoundUp) {
    totalCents += 1;
  }

  return totalCents * sign;
}

String formatCentsForInput(int cents) {
  final sign = cents < 0 ? '-' : '';
  final absoluteCents = cents.abs();
  final units = absoluteCents ~/ 100;
  final fraction = (absoluteCents % 100).toString().padLeft(2, '0');
  return '$sign$units.$fraction';
}

double centsToDecimal(int cents) => cents / 100.0;

int clampMoney(int value, int min, int max) => math.min(math.max(value, min), max);
