import 'package:my_investments/planning/domain/entities/operational_task.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';

enum TransactionSort { dateDesc, dateAsc, amountDesc, amountAsc }

sealed class TransactionListState {
  const TransactionListState();
}

class TransactionListLoading extends TransactionListState {
  const TransactionListLoading();
}

class TransactionListError extends TransactionListState {
  final String message;

  const TransactionListError({required this.message});
}

class TransactionListLoaded extends TransactionListState {
  final List<Transaction> transactions;
  final List<OperationalTask> operationalTasks;
  final String? selectedOperationalTaskId;
  final TransactionSort sort;

  const TransactionListLoaded({
    required this.transactions,
    required this.operationalTasks,
    required this.selectedOperationalTaskId,
    required this.sort,
  });

  List<Transaction> get filteredTransactions {
    final filtered = selectedOperationalTaskId == null
        ? transactions
        : transactions
            .where((t) => t.operationalTaskId == selectedOperationalTaskId)
            .toList();

    final sorted = List<Transaction>.from(filtered);
    sorted.sort((a, b) {
      return switch (sort) {
        TransactionSort.dateDesc => b.date.compareTo(a.date),
        TransactionSort.dateAsc => a.date.compareTo(b.date),
        TransactionSort.amountDesc => b.amount.compareTo(a.amount),
        TransactionSort.amountAsc => a.amount.compareTo(b.amount),
      };
    });
    return sorted;
  }
}
