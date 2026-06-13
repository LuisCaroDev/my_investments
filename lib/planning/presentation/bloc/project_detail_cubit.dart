import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:capitalflow/accounts/data/repositories/accounts_repository.dart';
import 'package:capitalflow/planning/data/repositories/activity_repository.dart';
import 'package:capitalflow/planning/data/repositories/project_repository.dart';
import 'package:capitalflow/planning/data/repositories/operational_task_repository.dart';
import 'package:capitalflow/planning/data/datasources/planning_local_ds.dart';
import 'package:capitalflow/planning/data/services/planning_detail_query_service.dart';
import 'package:capitalflow/planning/domain/entities/activity.dart';
import 'package:capitalflow/planning/domain/entities/project.dart';
import 'package:capitalflow/planning/domain/entities/operational_task.dart';
import 'package:capitalflow/core/domain/entities/transaction.dart';
import 'package:capitalflow/planning/presentation/bloc/project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final PlanningDetailQueryService _detailQueryService;
  final ActivityRepository _activityRepository;
  final ProjectRepository _projectRepository;
  final OperationalTaskRepository _operationalTaskRepository;
  final AccountsRepository _accountsRepository;
  final PlanningLocalDataSource _planningLocalDataSource;
  final String projectId;
  StreamSubscription? _projectsSubscription;
  StreamSubscription? _activitiesSubscription;

  ProjectDetailCubit({
    required PlanningDetailQueryService detailQueryService,
    required ActivityRepository activityRepository,
    required ProjectRepository projectRepository,
    required OperationalTaskRepository operationalTaskRepository,
    required AccountsRepository accountsRepository,
    required PlanningLocalDataSource planningLocalDataSource,
    required this.projectId,
  }) : _detailQueryService = detailQueryService,
       _activityRepository = activityRepository,
       _projectRepository = projectRepository,
       _operationalTaskRepository = operationalTaskRepository,
       _accountsRepository = accountsRepository,
       _planningLocalDataSource = planningLocalDataSource,
       super(const ProjectDetailLoading()) {
    _projectsSubscription = _planningLocalDataSource.projectsStream.listen((_) {
      load();
    });
    _activitiesSubscription = _planningLocalDataSource.activitiesStream.listen((
      _,
    ) {
      load();
    });
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    _activitiesSubscription?.cancel();
    return super.close();
  }

  void load() {
    try {
      final detail = _detailQueryService.getProjectDetail(projectId);
      emit(ProjectDetailLoaded(detail: detail));
    } catch (e) {
      emit(ProjectDetailError(message: e.toString()));
    }
  }

  // ── Project ───────────────────────────────────────────────

  Future<void> updateProject(Project project) async {
    await _projectRepository.updateProject(project);
  }

  // ── Activities ────────────────────────────────────────────

  Future<void> addActivity(Activity activity) async {
    await _activityRepository.addActivity(activity);
  }

  Future<void> updateActivity(Activity activity) async {
    await _activityRepository.updateActivity(activity);
  }

  Future<void> deleteActivity(String activityId) async {
    await _activityRepository.deleteActivity(activityId);
    await _accountsRepository.deleteTransactionsForActivity(activityId);
  }

  // ── Operational Tasks ─────────────────────────────────────

  Future<void> addOperationalTask(OperationalTask task) async {
    await _operationalTaskRepository.addOperationalTask(task);
  }

  Future<void> updateOperationalTask(OperationalTask task) async {
    await _operationalTaskRepository.updateOperationalTask(task);
  }

  Future<void> deleteOperationalTask(String taskId) async {
    await _operationalTaskRepository.deleteOperationalTask(taskId);
  }

  // ── Transactions ──────────────────────────────────────────

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
