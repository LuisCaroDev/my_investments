import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/planning/presentation/bloc/activity_detail_state.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart'
    as domain;

class ActivityDetailCubit extends Cubit<ActivityDetailState> {
  final PlanningRepository _planningRepository;
  final AccountsRepository _accountsRepository;
  final String projectId;
  final String activityId;

  ActivityDetailCubit({
    required PlanningRepository planningRepository,
    required AccountsRepository accountsRepository,
    required this.projectId,
    required this.activityId,
  }) : _planningRepository = planningRepository,
       _accountsRepository = accountsRepository,
       super(const ActivityDetailState());

  void load() {
    try {
      final detail =
          _planningRepository.getActivityDetail(projectId, activityId);
      emit(ActivityDetailState(loading: false, detail: detail));
    } catch (e) {
      emit(ActivityDetailState(loading: false, error: e.toString()));
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _accountsRepository.addTransaction(transaction);
    load();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _accountsRepository.deleteTransaction(transactionId);
    load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _accountsRepository.updateTransaction(transaction);
    load();
  }

  Future<void> addOperationalTask(domain.OperationalTask task) async {
    await _planningRepository.addOperationalTask(task);
    load();
  }

  Future<void> updateOperationalTask(domain.OperationalTask task) async {
    await _planningRepository.updateOperationalTask(task);
    load();
  }

  Future<void> deleteOperationalTask(String taskId) async {
    await _planningRepository.deleteOperationalTask(taskId);
    load();
  }
}
