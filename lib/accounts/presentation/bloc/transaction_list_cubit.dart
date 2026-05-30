import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/accounts/data/datasources/accounts_local_ds.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/accounts/presentation/bloc/transaction_list_state.dart';
import 'package:my_investments/planning/data/repositories/operational_task_repository.dart';

class TransactionListCubit extends Cubit<TransactionListState> {
  final AccountsRepository _accountsRepository;
  final AccountsLocalDataSource _accountsLocalDataSource;
  final OperationalTaskRepository _operationalTaskRepository;
  final String projectId;
  final String? activityId;
  StreamSubscription? _subscription;

  TransactionListCubit({
    required AccountsRepository accountsRepository,
    required AccountsLocalDataSource accountsLocalDataSource,
    required OperationalTaskRepository operationalTaskRepository,
    required this.projectId,
    this.activityId,
  }) : _accountsRepository = accountsRepository,
       _accountsLocalDataSource = accountsLocalDataSource,
       _operationalTaskRepository = operationalTaskRepository,
       super(const TransactionListLoading()) {
    _subscription = _accountsLocalDataSource.transactionsStream.listen((_) {
      load();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void load() {
    try {
      final transactions = activityId != null
          ? _accountsRepository.getTransactionsForActivity(activityId!)
          : _accountsRepository.getProjectLevelTransactions(projectId);
      final operationalTasks = activityId != null
          ? _operationalTaskRepository.getAvailableOperationalTasks(
              projectId,
              activityId!,
            )
          : _operationalTaskRepository.getProjectOperationalTasks(projectId);

      emit(
        TransactionListLoaded(
          transactions: transactions,
          operationalTasks: operationalTasks,
          selectedOperationalTaskId: null,
          sort: TransactionSort.dateDesc,
        ),
      );
    } catch (e) {
      emit(TransactionListError(message: e.toString()));
    }
  }

  void selectOperationalTask(String? taskId) {
    final state = this.state;
    if (state is! TransactionListLoaded) return;
    emit(
      TransactionListLoaded(
        transactions: state.transactions,
        operationalTasks: state.operationalTasks,
        selectedOperationalTaskId: taskId,
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
        operationalTasks: state.operationalTasks,
        selectedOperationalTaskId: state.selectedOperationalTaskId,
        sort: sort,
      ),
    );
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _accountsRepository.addTransaction(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _accountsRepository.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _accountsRepository.deleteTransaction(transactionId);
  }
}
