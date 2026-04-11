import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/accounts/presentation/bloc/transaction_list_state.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';

class TransactionListCubit extends Cubit<TransactionListState> {
  final AccountsRepository _accountsRepository;
  final PlanningRepository _planningRepository;
  final String projectId;
  final String? activityId;

  TransactionListCubit({
    required AccountsRepository accountsRepository,
    required PlanningRepository planningRepository,
    required this.projectId,
    this.activityId,
  }) : _accountsRepository = accountsRepository,
       _planningRepository = planningRepository,
       super(const TransactionListLoading());

  void load() {
    try {
      final transactions = activityId != null
          ? _accountsRepository.getTransactionsForActivity(activityId!)
          : _accountsRepository.getProjectLevelTransactions(projectId);
      final operationalTasks = activityId != null
          ? _planningRepository.getAvailableOperationalTasks(
              projectId,
              activityId!,
            )
          : _planningRepository.getProjectOperationalTasks(projectId);

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
    load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _accountsRepository.updateTransaction(transaction);
    load();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _accountsRepository.deleteTransaction(transactionId);
    load();
  }
}
