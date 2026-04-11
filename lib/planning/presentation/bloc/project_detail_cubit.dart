import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/domain/entities/activity.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/planning/presentation/bloc/project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final PlanningRepository _planningRepository;
  final AccountsRepository _accountsRepository;
  final String projectId;

  ProjectDetailCubit({
    required PlanningRepository planningRepository,
    required AccountsRepository accountsRepository,
    required this.projectId,
  }) : _planningRepository = planningRepository,
       _accountsRepository = accountsRepository,
       super(const ProjectDetailLoading());

  void load() {
    try {
      final detail = _planningRepository.getProjectDetail(projectId);
      emit(ProjectDetailLoaded(detail: detail));
    } catch (e) {
      emit(ProjectDetailError(message: e.toString()));
    }
  }

  // ── Activities ────────────────────────────────────────────

  Future<void> addActivity(Activity activity) async {
    await _planningRepository.addActivity(activity);
    load();
  }

  Future<void> updateActivity(Activity activity) async {
    await _planningRepository.updateActivity(activity);
    load();
  }

  Future<void> deleteActivity(String activityId) async {
    await _planningRepository.deleteActivity(activityId);
    await _accountsRepository.deleteTransactionsForActivity(activityId);
    load();
  }

  // ── Operational Tasks ─────────────────────────────────────

  Future<void> addOperationalTask(OperationalTask task) async {
    await _planningRepository.addOperationalTask(task);
    load();
  }

  Future<void> updateOperationalTask(OperationalTask task) async {
    await _planningRepository.updateOperationalTask(task);
    load();
  }

  Future<void> deleteOperationalTask(String taskId) async {
    await _planningRepository.deleteOperationalTask(taskId);
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
