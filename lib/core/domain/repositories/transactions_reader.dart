import 'package:my_investments/core/domain/entities/transaction.dart';

abstract class TransactionsReader {
  List<Transaction> getAllTransactions();
}
