import 'package:intl/intl.dart';

void main() {
  final pe = NumberFormat.currency(locale: 'es_PE', symbol: 'S/');
  final us = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final es = NumberFormat.currency(locale: 'es_ES', symbol: '€');

  print('es_PE: ${pe.format(15.00)}');
  print('en_US: ${us.format(15.00)}');
  print('es_ES: ${es.format(15.00)}');
}
