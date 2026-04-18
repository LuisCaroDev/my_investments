---
name: Navigation (GoRouter)
description: Defines the navigation patterns and rules using GoRouter for the my_investments Flutter app.
---

# Navigation (GoRouter)

This document outlines the standard navigation patterns for the `my_investments` application using `go_router`. All screens must follow these conventions to ensure type-safety, maintainability, and deep-linking support.

## 1. Route Definitions in Pages

Every navigable screen must define its route as a static property. This centralizes path definitions and makes refactoring easier.

### A. Simple Routes
For pages without parameters:
```dart
class SettingsPage extends StatelessWidget {
  static const route = '/settings';
  // ...
}
```

### B. Routes with Parameters
For pages requiring data (IDs, titles, etc.), use a combination of `routePattern` and a `routeOf` helper method.

```dart
class ProjectDetailPage extends StatelessWidget {
  static const routePattern = '/projects/:projectId';

  /// Generates the full route path for this page.
  static String routeOf({
    required String projectId,
    required String projectName,
  }) {
    // Required IDs go in path parameters
    // Optional or UI-only data goes in query parameters
    final name = Uri.encodeComponent(projectName);
    return '/projects/$projectId?name=$name';
  }

  final String projectId;
  final String projectName;
  // ...
}
```

### C. Sub-routes
When defining child routes within a parent (useful for `GoRouter` nesting and path parameter inheritance):

```dart
class ActivityDetailPage extends StatelessWidget {
  static const subRoutePattern = 'activities/:activityId';
  
  static String routeOf({
    required String projectId,
    required String activityId,
    required String activityName,
  }) => '/projects/$projectId/activities/$activityId?name=${Uri.encodeComponent(activityName)}';
}
```

## 2. Global Router Configuration

All routes must be registered in `lib/core/router/app_router.dart`. 

### StatefulShellRoute (Tabs)
The main application uses a `StatefulShellRoute` to maintain the state of individual tabs.

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return MainNavigationShell(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: InvestmentsPage.route, ...)]),
    StatefulShellBranch(routes: [GoRoute(path: GoalsPage.route, ...)]),
    // ...
  ],
)
```

## 3. Navigating from UI

Use the `AppRouterContext` extension on `BuildContext` to perform navigation. This provides an ergonomic API while abstracting the underlying `go_router` implementation.

| Method | Description |
|--------|-------------|
| `context.goTo(path)` | Replaces the current route (similar to `GoRouter.go`). |
| `context.pushRoute<T>(path)` | Pushes a route onto the stack and returns a `Future<T?>`. Replaces `pushForResult`. |
| `context.popRoute([result])` | Pops the top-most route and optionally returns a value. |
| `context.popToHome()` | Jumps directly to the initial route (`/`). |

### Examples

**Standard Navigation**:
```dart
onPressed: () => context.goTo(SettingsPage.route);
```

**Navigation with Parameters**:
```dart
onPressed: () => context.goTo(
  ProjectDetailPage.routeOf(
    projectId: project.id,
    projectName: project.name,
  ),
);
```

**Waiting for Result (Dialog Replacement)**:
```dart
final result = await context.pushRoute<bool>(EditProjectPage.routeOf(id: '123'));
if (result == true) {
  // refresh logic
}
```

## 4. Parameter Retrieval

Retrieve parameters from the `GoRouterState` inside the `builder` function in `app_router.dart`, and pass them to the page constructor.

```dart
GoRoute(
  path: ProjectDetailPage.routePattern,
  builder: (context, state) {
    final projectId = state.pathParameters['projectId']!;
    final projectName = state.uri.queryParameters['name'] ?? 'Project';
    return ProjectDetailPage(
      projectId: projectId,
      projectName: projectName,
    );
  },
)
```

## 5. Summary Rules
1. **Never** hardcode string paths in the UI. Always use `PageName.route` or `PageName.routeOf(...)`.
2. **Path Parameters** (`:id`) should only be used for essential resource identification.
3. **Query Parameters** (`?key=val`) should be used for UI-only info or optional filters.
4. **Data Fetching**: Prefer passing IDs and fetching data in the destination page (via Bloc/Cubit) rather than passing full domain objects, especially for pages that can be deep-linked.
