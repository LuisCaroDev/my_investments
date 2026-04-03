import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/transaction_list_state.dart';

class TransactionListCubit extends Cubit<TransactionListState> {
  final ProjectsRepository _repository;
  final String projectId;
  final String? activityId;

  TransactionListCubit({
    required ProjectsRepository repository,
    required this.projectId,
    this.activityId,
  }) : _repository = repository,
       super(const TransactionListLoading());

  void load() {
    try {
      final transactions = activityId != null
          ? _repository.getTransactionsForActivity(activityId!)
          : _repository.getProjectLevelTransactions(projectId);
      final categories = activityId != null
          ? _repository.getAvailableCategories(projectId, activityId!)
          : _repository.getProjectCategories(projectId);

      emit(
        TransactionListLoaded(
          transactions: transactions,
          categories: categories,
          selectedCategoryId: null,
          sort: TransactionSort.dateDesc,
        ),
      );
    } catch (e) {
      emit(TransactionListError(message: e.toString()));
    }
  }

  void selectCategory(String? categoryId) {
    final state = this.state;
    if (state is! TransactionListLoaded) return;
    emit(
      TransactionListLoaded(
        transactions: state.transactions,
        categories: state.categories,
        selectedCategoryId: categoryId,
        sort: state.sort,
      ),
    );
  }

  void changeSort(TransactionSort sort) {
    final state = this.state;
    if (state is! TransactionListLoaded) return;
    emit(
      TransactionListLoaded(
        transactions: state.transactions,
        categories: state.categories,
        selectedCategoryId: state.selectedCategoryId,
        sort: sort,
      ),
    );
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
    load();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _repository.deleteTransaction(transactionId);
    load();
  }
}
