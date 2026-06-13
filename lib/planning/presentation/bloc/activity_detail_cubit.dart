import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:capitalflow/accounts/data/repositories/accounts_repository.dart';
import 'package:capitalflow/planning/data/repositories/activity_repository.dart';
import 'package:capitalflow/planning/data/repositories/operational_task_repository.dart';
import 'package:capitalflow/planning/data/datasources/planning_local_ds.dart';
import 'package:capitalflow/planning/data/services/planning_detail_query_service.dart';
import 'package:capitalflow/core/domain/entities/transaction.dart';
import 'package:capitalflow/planning/presentation/bloc/activity_detail_state.dart';
import 'package:capitalflow/planning/domain/entities/activity.dart'
    as domain;
import 'package:capitalflow/planning/domain/entities/operational_task.dart'
    as domain;

class ActivityDetailCubit extends Cubit<ActivityDetailState> {
  final PlanningDetailQueryService _detailQueryService;
  final ActivityRepository _activityRepository;
  final OperationalTaskRepository _operationalTaskRepository;
  final AccountsRepository _accountsRepository;
  final PlanningLocalDataSource _planningLocalDataSource;
  final String projectId;
  final String activityId;
  StreamSubscription? _subscription;

  ActivityDetailCubit({
    required PlanningDetailQueryService detailQueryService,
    required ActivityRepository activityRepository,
    required OperationalTaskRepository operationalTaskRepository,
    required AccountsRepository accountsRepository,
    required PlanningLocalDataSource planningLocalDataSource,
    required this.projectId,
    required this.activityId,
  }) : _detailQueryService = detailQueryService,
       _activityRepository = activityRepository,
       _operationalTaskRepository = operationalTaskRepository,
       _accountsRepository = accountsRepository,
       _planningLocalDataSource = planningLocalDataSource,
       super(const ActivityDetailState()) {
    _subscription = _planningLocalDataSource.activitiesStream.listen((_) {
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
      final detail = _detailQueryService.getActivityDetail(
        projectId,
        activityId,
      );
      emit(ActivityDetailState(loading: false, detail: detail));
    } catch (e) {
      emit(ActivityDetailState(loading: false, error: e.toString()));
    }
  }

  Future<void> updateActivity(domain.Activity activity) async {
    await _activityRepository.updateActivity(activity);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _accountsRepository.addTransaction(transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _accountsRepository.deleteTransaction(transactionId);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _accountsRepository.updateTransaction(transaction);
  }

  Future<void> addOperationalTask(domain.OperationalTask task) async {
    await _operationalTaskRepository.addOperationalTask(task);
  }

  Future<void> updateOperationalTask(domain.OperationalTask task) async {
    await _operationalTaskRepository.updateOperationalTask(task);
  }

  Future<void> deleteOperationalTask(String taskId) async {
    await _operationalTaskRepository.deleteOperationalTask(taskId);
  }
}
