import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/core/constants/supabase_config.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:my_investments/core/theme/app_theme.dart';
import 'package:my_investments/core/router/app_router.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';
import 'package:my_investments/accounts/data/datasources/accounts_local_ds.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/accounts/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/planning/presentation/bloc/goals_cubit.dart';
import 'package:my_investments/planning/presentation/bloc/investments_cubit.dart';
import 'package:my_investments/core/i18n/shadcn_localizations_es.dart';
import 'package:my_investments/sync/data/datasources/sync_local_ds.dart';
import 'package:my_investments/sync/data/sync_change_recorder_impl.dart';
import 'package:my_investments/auth/data/repositories/auth_repository.dart';
import 'package:my_investments/auth/presentation/bloc/auth_cubit.dart';
import 'package:my_investments/sync/data/datasources/sync_remote_ds.dart';
import 'package:my_investments/sync/data/repositories/sync_repository.dart';
import 'package:my_investments/sync/domain/usecases/sync_coordinator.dart';
import 'package:my_investments/sync/domain/usecases/sync_service.dart';
import 'package:my_investments/sync/presentation/widgets/sync_coordinator_host.dart';
import 'package:my_investments/core/storage/profile_keys.dart';
import 'package:my_investments/core/storage/profile_ids.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
  final prefs = await SharedPreferences.getInstance();
  await _migrateLegacyKeysToGuest(prefs);

  final authRepo = AuthRepository();

  runApp(MyInvestmentsApp(prefs: prefs, authRepository: authRepo));
}

Future<void> _migrateLegacyKeysToGuest(SharedPreferences prefs) async {
  const legacyKeys = [
    'projects',
    'activities',
    'categories',
    'transactions',
    'financial_accounts',
    'sync_pending_changes',
    'sync_last_sync',
  ];

  for (final key in legacyKeys) {
    final legacyValue = prefs.getString(key);
    if (legacyValue == null) continue;
    final newKey = profileKey(guestProfileId, key);
    if (!prefs.containsKey(newKey)) {
      await prefs.setString(newKey, legacyValue);
    }
    await prefs.remove(key);
  }
}

class FallbackShadcnLocalizationsDelegate
    extends LocalizationsDelegate<ShadcnLocalizations> {
  const FallbackShadcnLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<ShadcnLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'es') {
      return ShadcnLocalizationsEs();
    }
    if (ShadcnLocalizations.delegate.isSupported(locale)) {
      return ShadcnLocalizations.delegate.load(locale);
    }
    return ShadcnLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(FallbackShadcnLocalizationsDelegate old) => false;
}

class MyInvestmentsApp extends StatefulWidget {
  final SharedPreferences prefs;
  final AuthRepository authRepository;

  const MyInvestmentsApp({
    super.key,
    required this.prefs,
    required this.authRepository,
  });

  @override
  State<MyInvestmentsApp> createState() => _MyInvestmentsAppState();
}

class _MyInvestmentsAppState extends State<MyInvestmentsApp> {
  late final AppRouter _router = AppRouter();
  late final AppRouteParser _routeParser = AppRouteParser();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(repository: widget.authRepository),
        ),
        BlocProvider(create: (_) => SettingsCubit(prefs: widget.prefs)),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final profileId = settingsState.activeProfileId;
          final planningDs = PlanningLocalDataSource(
            prefs: widget.prefs,
            profileId: profileId,
          );
          final accountsDs = AccountsLocalDataSource(
            prefs: widget.prefs,
            profileId: profileId,
          );
          final syncLocalDs = SyncLocalDataSource(
            prefs: widget.prefs,
            profileId: profileId,
          );
          final syncRemoteDs = SyncRemoteDataSource(
            client: Supabase.instance.client,
          );
          final syncRepo = SyncRepository(
            remote: syncRemoteDs,
            local: syncLocalDs,
          );
          final syncService = SyncService(repository: syncRepo);
          final syncCoordinator = SyncCoordinator(
            repository: syncRepo,
            service: syncService,
            providers: [planningDs, accountsDs],
            authRepository: widget.authRepository,
            settingsCubit: context.read<SettingsCubit>(),
          );
          final changeRecorder = SyncChangeRecorderImpl(
            local: syncLocalDs,
            onChange: syncCoordinator.onLocalChange,
          );
          final accountsRepo = AccountsRepository(
            localDataSource: accountsDs,
            changeRecorder: changeRecorder,
          );
          final planningRepo = PlanningRepository(
            localDataSource: planningDs,
            transactionsReader: accountsRepo,
            changeRecorder: changeRecorder,
          );

          return KeyedSubtree(
            key: ValueKey('profile-$profileId'),
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider.value(value: widget.prefs),
                RepositoryProvider.value(value: widget.authRepository),
                RepositoryProvider.value(value: syncRepo),
                RepositoryProvider.value(value: syncService),
                RepositoryProvider.value(value: planningDs),
                RepositoryProvider.value(value: accountsDs),
                RepositoryProvider.value(value: planningRepo),
                RepositoryProvider.value(value: accountsRepo),
              ],
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => InvestmentsCubit(
                      repository: planningRepo,
                      accountsRepository: accountsRepo,
                    )..loadInvestments(),
                  ),
                  BlocProvider(
                    create: (_) => GoalsCubit(
                      repository: planningRepo,
                      accountsRepository: accountsRepo,
                    )..loadGoals(),
                  ),
                  BlocProvider(
                    create: (_) => AccountsCubit(
                      repository: accountsRepo,
                      planningRepository: planningRepo,
                    )..loadAccounts(),
                  ),
                ],
                child: SyncCoordinatorHost(
                  coordinator: syncCoordinator,
                  child: ShadcnApp.router(
                    scaling: AdaptiveScaling.only(
                      sizeScaling: 1.5,
                      radiusScaling: 1
                    ),
                    title: 'My Investments',
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    themeMode: settingsState.themeMode,
                    routerDelegate: _router,
                    routeInformationParser: _routeParser,
                    localizationsDelegates: [
                      const FallbackShadcnLocalizationsDelegate(),
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: settingsState.appLocale == 'system'
                        ? null
                        : Locale(settingsState.appLocale),
                    builder: (context, child) {
                      final theme = Theme.of(context);
                      final isDark = theme.brightness == Brightness.dark;

                      return AnnotatedRegion<SystemUiOverlayStyle>(
                        value: SystemUiOverlayStyle(
                          statusBarColor: const Color(
                            0x00000000,
                          ), // Colors.transparent is Material
                          statusBarIconBrightness: isDark
                              ? Brightness.light
                              : Brightness.dark,
                          statusBarBrightness: isDark
                              ? Brightness.dark
                              : Brightness.light,
                          systemNavigationBarColor:
                              theme.colorScheme.background,
                          systemNavigationBarIconBrightness: isDark
                              ? Brightness.light
                              : Brightness.dark,
                        ),
                        child: child ?? const SizedBox.shrink(),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
