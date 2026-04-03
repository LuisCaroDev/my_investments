import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:my_investments/core/presentation/bloc/settings_cubit.dart';
import 'package:my_investments/core/presentation/bloc/settings_state.dart';
import 'package:my_investments/core/theme/app_theme.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/presentation/bloc/projects_cubit.dart';
import 'package:my_investments/projects/presentation/pages/projects_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyInvestmentsApp(prefs: prefs));
}

class MyInvestmentsApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyInvestmentsApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final ds = ProjectsLocalDataSource(prefs: prefs);
    final repo = ProjectsRepository(localDataSource: ds);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProjectsCubit(repository: repo)..loadProjects()),
        BlocProvider(create: (_) => SettingsCubit(prefs: prefs)),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return ShadcnApp(
            key: ValueKey(settingsState.props.join('-')),
            title: 'My Investments',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
            localizationsDelegates: [
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
                  statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                  systemNavigationBarColor: theme.colorScheme.background,
                  systemNavigationBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const ProjectsPage(),
          );
        },
      ),
    );
  }
}
