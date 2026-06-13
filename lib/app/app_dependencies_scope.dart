import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:capitalflow/accounts/data/datasources/accounts_local_ds.dart';
import 'package:capitalflow/accounts/data/repositories/accounts_repository.dart';
import 'package:capitalflow/accounts/presentation/bloc/accounts_cubit.dart';
import 'package:capitalflow/auth/data/repositories/auth_repository.dart';
import 'package:capitalflow/auth/presentation/bloc/auth_cubit.dart';
import 'package:capitalflow/core/presentation/bloc/settings_cubit.dart';
import 'package:capitalflow/core/presentation/bloc/settings_state.dart';
import 'package:capitalflow/planning/data/datasources/planning_local_ds.dart';
import 'package:capitalflow/planning/data/repositories/activity_repository.dart';
import 'package:capitalflow/planning/data/repositories/operational_task_repository.dart';
import 'package:capitalflow/planning/data/repositories/project_repository.dart';
import 'package:capitalflow/planning/data/services/planning_detail_query_service.dart';
import 'package:capitalflow/planning/data/services/planning_funding_calculator.dart';
import 'package:capitalflow/planning/presentation/bloc/goals_cubit.dart';
import 'package:capitalflow/planning/presentation/bloc/investments_cubit.dart';
import 'package:capitalflow/sync/data/datasources/sync_local_ds.dart';
import 'package:capitalflow/sync/data/datasources/sync_remote_ds.dart';
import 'package:capitalflow/sync/data/repositories/sync_repository.dart';
import 'package:capitalflow/sync/data/sync_change_recorder_impl.dart';
import 'package:capitalflow/sync/domain/usecases/sync_coordinator.dart';
import 'package:capitalflow/sync/domain/usecases/sync_service.dart';
import 'package:capitalflow/sync/presentation/widgets/sync_coordinator_host.dart';
import 'package:capitalflow/core/domain/jobs/transaction_projection_job.dart';

class AppDependenciesScope extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthRepository authRepository;
  final Widget Function(BuildContext context, SettingsState settingsState)
  builder;

  const AppDependenciesScope({
    super.key,
    required this.prefs,
    required this.authRepository,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(repository: authRepository)),
        BlocProvider(create: (_) => SettingsCubit(prefs: prefs)),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return _ProfileDependenciesScope(
            prefs: prefs,
            authRepository: authRepository,
            settingsState: settingsState,
            builder: builder,
          );
        },
      ),
    );
  }
}

class _ProfileDependenciesScope extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthRepository authRepository;
  final SettingsState settingsState;
  final Widget Function(BuildContext context, SettingsState settingsState)
  builder;

  const _ProfileDependenciesScope({
    required this.prefs,
    required this.authRepository,
    required this.settingsState,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final profileId = settingsState.activeProfileId;
    final planningDs = PlanningLocalDataSource(
      prefs: prefs,
      profileId: profileId,
    );
    final accountsDs = AccountsLocalDataSource(
      prefs: prefs,
      profileId: profileId,
    );
    final syncLocalDs = SyncLocalDataSource(prefs: prefs, profileId: profileId);
    final syncRemoteDs = SyncRemoteDataSource(client: Supabase.instance.client);
    final syncRepo = SyncRepository(remote: syncRemoteDs, local: syncLocalDs);
    final syncService = SyncService(repository: syncRepo);
    final syncCoordinator = SyncCoordinator(
      repository: syncRepo,
      service: syncService,
      providers: [planningDs, accountsDs],
      authRepository: authRepository,
      settingsCubit: context.read<SettingsCubit>(),
    );
    final changeRecorder = SyncChangeRecorderImpl(
      local: syncLocalDs,
      onChange: syncCoordinator.onLocalChange,
    );
    const planningFundingCalculator = PlanningFundingCalculator();

    final projectionJob = TransactionProjectionJob(
      accountsDs: accountsDs,
      planningDs: planningDs,
      calculator: planningFundingCalculator,
    );
    accountsDs.setProjectionJob(projectionJob);
    planningDs.setProjectionJob(projectionJob);

    final accountsRepo = AccountsRepository(
      localDataSource: accountsDs,
      projectionJob: projectionJob,
      changeRecorder: changeRecorder,
    );
    final projectRepository = ProjectRepository(
      localDataSource: planningDs,
      changeRecorder: changeRecorder,
    );
    final activityRepository = ActivityRepository(
      localDataSource: planningDs,
      changeRecorder: changeRecorder,
    );
    final operationalTaskRepository = OperationalTaskRepository(
      localDataSource: planningDs,
      changeRecorder: changeRecorder,
    );
    final planningDetailQueryService = PlanningDetailQueryService(
      localDataSource: planningDs,
      transactionsReader: accountsRepo,
      activityRepository: activityRepository,
      operationalTaskRepository: operationalTaskRepository,
      fundingCalculator: planningFundingCalculator,
    );

    return KeyedSubtree(
      key: ValueKey('profile-$profileId'),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: prefs),
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider.value(value: syncRepo),
          RepositoryProvider.value(value: syncService),
          RepositoryProvider.value(value: planningDs),
          RepositoryProvider.value(value: accountsDs),
          RepositoryProvider.value(value: projectRepository),
          RepositoryProvider.value(value: activityRepository),
          RepositoryProvider.value(value: operationalTaskRepository),
          RepositoryProvider.value(value: planningFundingCalculator),
          RepositoryProvider.value(value: planningDetailQueryService),
          RepositoryProvider.value(value: accountsRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => InvestmentsCubit(
                projectRepository: projectRepository,
                detailQueryService: planningDetailQueryService,
                accountsRepository: accountsRepo,
                planningLocalDataSource: planningDs,
              )..loadInvestments(),
            ),
            BlocProvider(
              create: (_) => GoalsCubit(
                projectRepository: projectRepository,
                detailQueryService: planningDetailQueryService,
                accountsRepository: accountsRepo,
                planningLocalDataSource: planningDs,
              )..loadGoals(),
            ),
            BlocProvider(
              create: (_) => AccountsCubit(
                repository: accountsRepo,
                localDataSource: accountsDs,
                projectRepository: projectRepository,
              )..loadAccounts(),
            ),
          ],
          child: SyncCoordinatorHost(
            coordinator: syncCoordinator,
            child: builder(context, settingsState),
          ),
        ),
      ),
    );
  }
}
