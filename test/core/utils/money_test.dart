import 'package:flutter_test/flutter_test.dart';
import 'package:capitalflow/core/utils/money.dart';

void main() {
  group('parseMoneyToCents', () {
    test('parses expected decimal inputs', () {
      expect(parseMoneyToCents('0'), 0);
      expect(parseMoneyToCents('1'), 100);
      expect(parseMoneyToCents('1.2'), 120);
      expect(parseMoneyToCents('1.23'), 123);
      expect(parseMoneyToCents('1.235'), 124);
      expect(parseMoneyToCents('0.01'), 1);
      expect(parseMoneyToCents('-1.23'), -123);
    });

    test('returns null for invalid input', () {
      expect(parseMoneyToCents(''), isNull);
      expect(parseMoneyToCents('abc'), isNull);
      expect(parseMoneyToCents('1.2.3'), isNull);
    });
  });

  group('formatCentsForInput', () {
    test('formats integer cents as decimal text', () {
      expect(formatCentsForInput(10000), '100.00');
      expect(formatCentsForInput(2550), '25.50');
      expect(formatCentsForInput(99), '0.99');
      expect(formatCentsForInput(-123), '-1.23');
    });
  });
}
