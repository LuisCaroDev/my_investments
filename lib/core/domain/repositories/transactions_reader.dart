import 'package:capitalflow/core/domain/entities/transaction.dart';

abstract class TransactionsReader {
  List<Transaction> getAllTransactions();
}
