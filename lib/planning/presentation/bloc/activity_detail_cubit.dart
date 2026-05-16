import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/data/repositories/operational_task_repository.dart';
import 'package:my_investments/planning/data/services/planning_detail_query_service.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/planning/presentation/bloc/activity_detail_state.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart'
    as domain;

class ActivityDetailCubit extends Cubit<ActivityDetailState> {
  final PlanningDetailQueryService _detailQueryService;
  final OperationalTaskRepository _operationalTaskRepository;
  final AccountsRepository _accountsRepository;
  final String projectId;
  final String activityId;

  ActivityDetailCubit({
    required PlanningDetailQueryService detailQueryService,
    required OperationalTaskRepository operationalTaskRepository,
    required AccountsRepository accountsRepository,
    required this.projectId,
    required this.activityId,
  }) : _detailQueryService = detailQueryService,
       _operationalTaskRepository = operationalTaskRepository,
       _accountsRepository = accountsRepository,
       super(const ActivityDetailState());

  void load() {
    try {
      final detail = _detailQueryService.getActivityDetail(
        projectId,
        activityId,
      );
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
    await _operationalTaskRepository.addOperationalTask(task);
    load();
  }

  Future<void> updateOperationalTask(domain.OperationalTask task) async {
    await _operationalTaskRepository.updateOperationalTask(task);
    load();
  }

  Future<void> deleteOperationalTask(String taskId) async {
    await _operationalTaskRepository.deleteOperationalTask(taskId);
    load();
  }
}
