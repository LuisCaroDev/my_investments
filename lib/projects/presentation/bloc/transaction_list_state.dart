import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';

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
  final List<Category> categories;
  final String? selectedCategoryId;
  final TransactionSort sort;

  const TransactionListLoaded({
    required this.transactions,
    required this.categories,
    required this.selectedCategoryId,
    required this.sort,
  });

  List<Transaction> get filteredTransactions {
    final filtered = selectedCategoryId == null
        ? transactions
        : transactions.where((t) => t.categoryId == selectedCategoryId).toList();

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
