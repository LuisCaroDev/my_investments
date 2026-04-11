import 'dart:async';

import 'package:flutter/material.dart' as m;
import 'package:flutter/widgets.dart';
import 'package:my_investments/core/presentation/pages/settings_page.dart';
import 'package:my_investments/core/domain/entities/financial_account.dart';
import 'package:my_investments/accounts/presentation/pages/account_transactions_page.dart';
import 'package:my_investments/planning/presentation/pages/activity_detail_page.dart';
import 'package:my_investments/planning/presentation/pages/operational_task_management_page.dart';
import 'package:my_investments/planning/presentation/pages/import_export_page.dart';
import 'package:my_investments/planning/presentation/pages/main_navigation_shell.dart';
import 'package:my_investments/planning/presentation/pages/project_detail_page.dart';
import 'package:my_investments/accounts/presentation/pages/transaction_list_page.dart';

sealed class AppRoute {
  const AppRoute();
  String get location;
}

class HomeRoute extends AppRoute {
  const HomeRoute();

  @override
  String get location => '/';
}

class SettingsRoute extends AppRoute {
  const SettingsRoute();

  @override
  String get location => '/settings';
}

class ImportExportRoute extends AppRoute {
  const ImportExportRoute();

  @override
  String get location => '/settings/import-export';
}

class ProjectDetailRoute extends AppRoute {
  final String projectId;
  final String projectName;

  const ProjectDetailRoute({
    required this.projectId,
    required this.projectName,
  });

  @override
  String get location => '/projects/$projectId';
}

class ActivityDetailRoute extends AppRoute {
  final String projectId;
  final String activityId;
  final String activityName;

  const ActivityDetailRoute({
    required this.projectId,
    required this.activityId,
    required this.activityName,
  });

  @override
  String get location => '/projects/$projectId/activities/$activityId';
}

class TransactionListRoute extends AppRoute {
  final String projectId;
  final String title;
  final String? activityId;

  const TransactionListRoute({
    required this.projectId,
    required this.title,
    this.activityId,
  });

  @override
  String get location {
    final query = activityId == null ? '' : '?activity=$activityId';
    return '/projects/$projectId/transactions$query';
  }
}

class OperationalTaskManagementRoute extends AppRoute {
  final String projectId;
  final String title;
  final String? activityId;

  const OperationalTaskManagementRoute({
    required this.projectId,
    required this.title,
    this.activityId,
  });

  @override
  String get location {
    final query = activityId == null ? '' : '?activity=$activityId';
    return '/projects/$projectId/categories$query';
  }
}

class AccountTransactionsRoute extends AppRoute {
  final FinancialAccount account;

  const AccountTransactionsRoute({required this.account});

  @override
  String get location => '/accounts/${account.id}/transactions';
}

class AppRoutePath {
  final List<AppRoute> stack;

  const AppRoutePath(this.stack);

  factory AppRoutePath.home() => const AppRoutePath([HomeRoute()]);
}

class AppRouteParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final location = routeInformation.location ?? '/';
    final uri = Uri.parse(location);

    if (uri.pathSegments.isEmpty) {
      return AppRoutePath.home();
    }

    if (uri.pathSegments.length == 1 && uri.pathSegments.first == 'settings') {
      return const AppRoutePath([HomeRoute(), SettingsRoute()]);
    }

    if (uri.pathSegments.length == 2 &&
        uri.pathSegments[0] == 'settings' &&
        uri.pathSegments[1] == 'import-export') {
      return const AppRoutePath([
        HomeRoute(),
        SettingsRoute(),
        ImportExportRoute(),
      ]);
    }

    if (uri.pathSegments.length == 2 &&
        uri.pathSegments[0] == 'projects') {
      final projectId = uri.pathSegments[1];
      return AppRoutePath([
        const HomeRoute(),
        ProjectDetailRoute(
          projectId: projectId,
          projectName: projectId,
        ),
      ]);
    }

    if (uri.pathSegments.length == 4 &&
        uri.pathSegments[0] == 'projects' &&
        uri.pathSegments[2] == 'activities') {
      final projectId = uri.pathSegments[1];
      final activityId = uri.pathSegments[3];
      return AppRoutePath([
        const HomeRoute(),
        ActivityDetailRoute(
          projectId: projectId,
          activityId: activityId,
          activityName: activityId,
        ),
      ]);
    }

    if (uri.pathSegments.length == 3 &&
        uri.pathSegments[0] == 'projects' &&
        uri.pathSegments[2] == 'transactions') {
      final projectId = uri.pathSegments[1];
      return AppRoutePath([
        const HomeRoute(),
        TransactionListRoute(
          projectId: projectId,
          title: 'Transactions',
          activityId: uri.queryParameters['activity'],
        ),
      ]);
    }

    if (uri.pathSegments.length == 3 &&
        uri.pathSegments[0] == 'projects' &&
        uri.pathSegments[2] == 'categories') {
      final projectId = uri.pathSegments[1];
      return AppRoutePath([
        const HomeRoute(),
        OperationalTaskManagementRoute(
          projectId: projectId,
          title: 'Tasks',
          activityId: uri.queryParameters['activity'],
        ),
      ]);
    }

    if (uri.pathSegments.length == 3 &&
        uri.pathSegments[0] == 'accounts' &&
        uri.pathSegments[2] == 'transactions') {
      final accountId = uri.pathSegments[1];
      return AppRoutePath([
        const HomeRoute(),
        AccountTransactionsRoute(
          account: FinancialAccount(
            id: accountId,
            name: accountId,
            type: FinancialAccountType.bank,
            balance: 0,
            createdAt: DateTime.now(),
          ),
        ),
      ]);
    }

    return AppRoutePath.home();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    final location =
        configuration.stack.isNotEmpty ? configuration.stack.last.location : '/';
    return RouteInformation(location: location);
  }
}

class _AppRouteEntry {
  final AppRoute route;
  final Completer<Object?>? completer;

  const _AppRouteEntry(this.route, [this.completer]);
}

class AppRouter extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<_AppRouteEntry> _stack = [const _AppRouteEntry(HomeRoute())];

  List<AppRoute> get stack =>
      List.unmodifiable(_stack.map((entry) => entry.route));

  void push(AppRoute route) {
    _stack.add(_AppRouteEntry(route));
    notifyListeners();
  }

  Future<T?> pushForResult<T>(AppRoute route) {
    final completer = Completer<T?>();
    _stack.add(_AppRouteEntry(route, completer));
    notifyListeners();
    return completer.future;
  }

  bool pop([Object? result]) {
    if (_stack.length <= 1) {
      return false;
    }
    final entry = _stack.removeLast();
    if (entry.completer != null && !entry.completer!.isCompleted) {
      entry.completer!.complete(result);
    }
    notifyListeners();
    return true;
  }

  void popToHome() {
    if (_stack.length <= 1) return;
    final popped = _stack.sublist(1);
    _stack.removeRange(1, _stack.length);
    for (final entry in popped) {
      if (entry.completer != null && !entry.completer!.isCompleted) {
        entry.completer!.complete(null);
      }
    }
    notifyListeners();
  }

  @override
  AppRoutePath get currentConfiguration =>
      AppRoutePath(_stack.map((entry) => entry.route).toList());

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _stack
      ..clear()
      ..addAll(
        _ensureHome(configuration.stack)
            .map((route) => _AppRouteEntry(route)),
      );
    notifyListeners();
  }

  List<AppRoute> _ensureHome(List<AppRoute> stack) {
    if (stack.isEmpty || stack.first is! HomeRoute) {
      return [const HomeRoute(), ...stack];
    }
    return stack;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <m.Page>[
      const m.MaterialPage(
        key: ValueKey('home'),
        child: MainNavigationShell(),
      ),
    ];

    for (final entry in _stack.skip(1)) {
      final route = entry.route;
      if (route is SettingsRoute) {
        pages.add(
          const m.MaterialPage(
            key: ValueKey('settings'),
            child: SettingsPage(),
          ),
        );
      } else if (route is ImportExportRoute) {
        pages.add(
          const m.MaterialPage(
            key: ValueKey('import_export'),
            child: ImportExportPage(),
          ),
        );
      } else if (route is ProjectDetailRoute) {
        pages.add(
          m.MaterialPage(
            key: ValueKey('project_${route.projectId}'),
            child: ProjectDetailPage(
              projectId: route.projectId,
              projectName: route.projectName,
            ),
          ),
        );
      } else if (route is ActivityDetailRoute) {
        pages.add(
          m.MaterialPage(
            key: ValueKey('activity_${route.activityId}'),
            child: ActivityDetailPage(
              projectId: route.projectId,
              activityId: route.activityId,
              activityName: route.activityName,
            ),
          ),
        );
      } else if (route is TransactionListRoute) {
        pages.add(
          m.MaterialPage(
            key: ValueKey(
              'transactions_${route.projectId}_${route.activityId ?? 'all'}',
            ),
            child: TransactionListPage(
              projectId: route.projectId,
              title: route.title,
              activityId: route.activityId,
            ),
          ),
        );
      } else if (route is OperationalTaskManagementRoute) {
        pages.add(
          m.MaterialPage(
            key: ValueKey(
              'categories_${route.projectId}_${route.activityId ?? 'all'}',
            ),
            child: OperationalTaskManagementPage(
              projectId: route.projectId,
              title: route.title,
              activityId: route.activityId,
            ),
          ),
        );
      } else if (route is AccountTransactionsRoute) {
        pages.add(
          m.MaterialPage(
            key: ValueKey('account_${route.account.id}'),
            child: AccountTransactionsPage(account: route.account),
          ),
        );
      }
    }

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        return pop(result);
      },
    );
  }
}

extension AppRouterContext on BuildContext {
  AppRouter get appRouter => Router.of(this).routerDelegate as AppRouter;
}
