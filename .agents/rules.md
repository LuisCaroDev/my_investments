# Project Rules — my_investments

## UI Components

1. **Use shadcn_flutter components** for all UI elements whenever possible. Avoid using Material or Cupertino widgets if a shadcn_flutter equivalent exists.
   - Buttons → `PrimaryButton`, `SecondaryButton`, `DestructiveButton`, `OutlineButton`, `GhostButton`
   - Inputs → `TextField`, `NumberInput`, `Select`, `MultiSelect`
   - Feedback → `Alert`, `Toast`, `Badge`
   - Layout → `Card`, `Dialog`, `Sheet`, `Popover`, `Tabs`
   - Navigation → `NavigationMenu`, `Breadcrumb`, `Pagination`
   - Data display → `Table`, `DataTable`, `Avatar`, `Skeleton`
   - Forms → `Form`, `FormField` with shadcn_flutter validation

2. **Import `shadcn_flutter`** instead of `material.dart` in presentation layer files:
   ```dart
   import 'package:shadcn_flutter/shadcn_flutter.dart';
   ```

3. **Only fall back to Material/Cupertino** when shadcn_flutter does not provide a specific widget (e.g., `Scaffold`, platform-specific system UI).

## State Management

4. **Use flutter_bloc (Cubit or Bloc)** for all state management. Do not use `setState`, `ChangeNotifier`, or other state solutions.

5. **Follow the BLoC architecture skill** defined in `.agents/skills/bloc_architecture/SKILL.md` for folder structure, naming conventions, and patterns.

6. **Keep business logic out of widgets.** All logic must reside in BLoCs/Cubits or use cases.

## Architecture

7. **Follow Screaming Architecture** (feature-first / modular). Top-level folders under `lib/` represent **business domains** (`investments/`, `portfolio/`, `dashboard/`), not technical layers. Each module contains its own `domain/`, `data/`, and `presentation/` layers internally.

8. **Module isolation**: Modules must **never import from each other**. Cross-module communication goes through `core/` abstractions or app-level BLoC composition. Only `core/` and `app/` are shared.

9. **Dependency Rule**: Within each module, dependencies point inward: Presentation → Domain ← Data. Never import `data/` from `domain/`.

## Code Style

9. **Use `const` constructors** wherever possible for widgets and data classes.

10. **Use sealed classes** (Dart 3+) for BLoC states to enable exhaustive `switch` expressions.

11. **Use Spanish for user-facing strings** (this is a personal finance app for Spanish-speaking users) but **English for code** (variable names, comments, documentation).

## Theme

12. **Use ShadcnApp** (or wrap `MaterialApp` with shadcn_flutter theming) as the root widget, configured with the app's theme from `core/theme/`.
