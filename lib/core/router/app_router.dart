import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:my_investments/accounts/presentation/pages/account_transactions_page.dart';
import 'package:my_investments/accounts/presentation/pages/accounts_page.dart';
import 'package:my_investments/accounts/presentation/pages/transaction_list_page.dart';
import 'package:my_investments/auth/presentation/pages/home_gate.dart';
import 'package:my_investments/auth/presentation/pages/login_page.dart';
import 'package:my_investments/auth/presentation/pages/welcome_page.dart';
import 'package:my_investments/core/presentation/pages/settings_page.dart';
import 'package:my_investments/planning/presentation/pages/activity_detail_page.dart';
import 'package:my_investments/planning/presentation/pages/goals_page.dart';
import 'package:my_investments/planning/presentation/pages/import_export_page.dart';
import 'package:my_investments/planning/presentation/pages/investments_page.dart';
import 'package:my_investments/planning/presentation/pages/main_navigation_shell.dart';
import 'package:my_investments/planning/presentation/pages/operational_task_management_page.dart';
import 'package:my_investments/planning/presentation/pages/project_detail_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: HomeGate.route,
  routes: [
    GoRoute(
      path: HomeGate.route,
      builder: (context, state) => const HomeGate(),
    ),
    GoRoute(
      path: WelcomePage.route,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: LoginPage.route,
      builder: (context, state) {
        final fromSettings =
            state.uri.queryParameters['fromSettings'] == 'true';
        return LoginPage(fromSettings: fromSettings);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: InvestmentsPage.route,
              builder: (context, state) => const InvestmentsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: GoalsPage.route,
              builder: (context, state) => const GoalsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AccountsPage.route,
              builder: (context, state) => const AccountsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: SettingsPage.route,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    // Detail routes (outside shell to cover it on mobile)
    GoRoute(
      path: ImportExportPage.route,
      builder: (context, state) => const ImportExportPage(),
    ),
    GoRoute(
      path: ProjectDetailPage.routePattern,
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        final projectName =
            state.uri.queryParameters['name'] ?? projectId;
        return ProjectDetailPage(
          projectId: projectId,
          projectName: projectName,
        );
      },
      routes: [
        GoRoute(
          path: ActivityDetailPage.subRoutePattern,
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            final activityId = state.pathParameters['activityId']!;
            final activityName =
                state.uri.queryParameters['name'] ?? activityId;
            return ActivityDetailPage(
              projectId: projectId,
              activityId: activityId,
              activityName: activityName,
            );
          },
        ),
        GoRoute(
          path: TransactionListPage.subRoutePattern,
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            final title = state.uri.queryParameters['title'] ?? '';
            final activityId = state.uri.queryParameters['activity'];
            return TransactionListPage(
              projectId: projectId,
              title: title,
              activityId: activityId,
            );
          },
        ),
        GoRoute(
          path: OperationalTaskManagementPage.subRoutePattern,
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            final title = state.uri.queryParameters['title'] ?? '';
            final activityId = state.uri.queryParameters['activity'];
            return OperationalTaskManagementPage(
              projectId: projectId,
              title: title,
              activityId: activityId,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: AccountTransactionsPage.routePattern,
      builder: (context, state) {
        final accountId = state.pathParameters['accountId']!;
        return AccountTransactionsPage(accountId: accountId);
      },
    ),
  ],
);

/// Convenience extension so pages can call `context.go(...)` and `context.pop()`
/// without importing go_router directly, plus a `popToHome` helper.
extension AppRouterContext on BuildContext {
  /// Navigate to [location], replacing the current entry in the history stack.
  void goTo(String location) => GoRouter.of(this).go(location);

  /// Push [location] on top of the current stack. Returns a [Future] that
  /// resolves with the value passed to [pop], mirroring the old `pushForResult`.
  Future<T?> pushRoute<T>(String location) =>
      GoRouter.of(this).push<T>(location);

  /// Pop the top-most route.
  void popRoute([Object? result]) => GoRouter.of(this).pop(result);

  /// Pop all routes back to the root `/`.
  void popToHome() => GoRouter.of(this).go(HomeGate.route);
}
