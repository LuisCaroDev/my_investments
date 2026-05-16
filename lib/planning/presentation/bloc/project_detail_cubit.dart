import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/data/repositories/activity_repository.dart';
import 'package:my_investments/planning/data/repositories/operational_task_repository.dart';
import 'package:my_investments/planning/data/services/planning_detail_query_service.dart';
import 'package:my_investments/planning/domain/entities/activity.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/planning/presentation/bloc/project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final PlanningDetailQueryService _detailQueryService;
  final ActivityRepository _activityRepository;
  final OperationalTaskRepository _operationalTaskRepository;
  final AccountsRepository _accountsRepository;
  final String projectId;

  ProjectDetailCubit({
    required PlanningDetailQueryService detailQueryService,
    required ActivityRepository activityRepository,
    required OperationalTaskRepository operationalTaskRepository,
    required AccountsRepository accountsRepository,
    required this.projectId,
  }) : _detailQueryService = detailQueryService,
       _activityRepository = activityRepository,
       _operationalTaskRepository = operationalTaskRepository,
       _accountsRepository = accountsRepository,
       super(const ProjectDetailLoading());

  void load() {
    try {
      final detail = _detailQueryService.getProjectDetail(projectId);
      emit(ProjectDetailLoaded(detail: detail));
    } catch (e) {
      emit(ProjectDetailError(message: e.toString()));
    }
  }

  // ── Activities ────────────────────────────────────────────

  Future<void> addActivity(Activity activity) async {
    await _activityRepository.addActivity(activity);
    load();
  }

  Future<void> updateActivity(Activity activity) async {
    await _activityRepository.updateActivity(activity);
    load();
  }

  Future<void> deleteActivity(String activityId) async {
    await _activityRepository.deleteActivity(activityId);
    await _accountsRepository.deleteTransactionsForActivity(activityId);
    load();
  }

  // ── Operational Tasks ─────────────────────────────────────

  Future<void> addOperationalTask(OperationalTask task) async {
    await _operationalTaskRepository.addOperationalTask(task);
    load();
  }

  Future<void> updateOperationalTask(OperationalTask task) async {
    await _operationalTaskRepository.updateOperationalTask(task);
    load();
  }

  Future<void> deleteOperationalTask(String taskId) async {
    await _operationalTaskRepository.deleteOperationalTask(taskId);
    load();
  }

  // ── Transactions ──────────────────────────────────────────

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
