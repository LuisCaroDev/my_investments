import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:my_investments/core/theme/app_theme.dart';
import 'package:my_investments/core/router/app_router.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/goals_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/investments_cubit.dart';
import 'package:my_investments/core/i18n/shadcn_localizations_es.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  final ds = ProjectsLocalDataSource(prefs: prefs);
  final repo = ProjectsRepository(localDataSource: ds);

  runApp(MyInvestmentsApp(prefs: prefs, repository: repo));
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
  final ProjectsRepository repository;

  const MyInvestmentsApp({
    super.key,
    required this.prefs,
    required this.repository,
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
          create: (_) =>
              InvestmentsCubit(repository: widget.repository)..loadInvestments(),
        ),
        BlocProvider(
          create: (_) => GoalsCubit(repository: widget.repository)..loadGoals(),
        ),
        BlocProvider(
          create: (_) =>
              AccountsCubit(repository: widget.repository)..loadAccounts(),
        ),
        BlocProvider(create: (_) => SettingsCubit(prefs: widget.prefs)),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return ShadcnApp.router(
            // key: ValueKey(settingsState.props.join('-')),
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
                  systemNavigationBarColor: theme.colorScheme.background,
                  systemNavigationBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
