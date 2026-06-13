import 'package:flutter/services.dart';
import 'package:capitalflow/core/constants/supabase_config.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:capitalflow/app/app_dependencies_scope.dart';
import 'package:capitalflow/l10n/app_localizations.dart';
import 'package:capitalflow/core/theme/app_theme.dart';
import 'package:capitalflow/core/router/app_router.dart';
import 'package:capitalflow/core/i18n/shadcn_localizations_es.dart';
import 'package:capitalflow/auth/data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
  final prefs = await SharedPreferences.getInstance();

  final authRepo = AuthRepository();

  runApp(MyInvestmentsApp(prefs: prefs, authRepository: authRepo));
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
  @override
  Widget build(BuildContext context) {
    return AppDependenciesScope(
      prefs: widget.prefs,
      authRepository: widget.authRepository,
      builder: (context, settingsState) => ShadcnApp.router(
        scaling: AdaptiveScaling.only(sizeScaling: 1.5, radiusScaling: 1),
        title: 'CapitalFlow',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settingsState.themeMode,
        routerConfig: appRouter,
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
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: theme.colorScheme.background,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
