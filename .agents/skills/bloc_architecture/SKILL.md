---
name: BLoC Architecture
description: Defines the BLoC/Cubit architecture pattern for the my_investments Flutter app, including folder structure, naming conventions, state management rules, and integration with shadcn_flutter components.
---

# BLoC Architecture Skill — my_investments

## Overview

This app uses **flutter_bloc** for state management and **shadcn_flutter** for UI components. The project follows a **Screaming Architecture** (feature-first / modular) where the folder structure "screams" what the application does, not how it's technically organized.

---

## Architecture Philosophy: Screaming Architecture

> "The architecture should scream the intent of the system." — Robert C. Martin

### Principles

1. **Feature-first**: Top-level folders under `lib/` represent **business domains** (investments, portfolio, dashboard), not technical layers (data, domain, presentation).
2. **Self-contained modules**: Each feature module contains its own clean architecture layers internally. A module can be understood, developed, and tested in isolation.
3. **Shared core**: Cross-cutting concerns (theme, networking, DI, extensions) live in a `core/` module.
4. **Dependency direction**: Modules depend on `core/` but never on each other directly. If modules need to communicate, they do so through shared abstractions in `core/` or via the BLoC layer at the app level.

---

## Folder Structure

```
lib/
├── main.dart                          # Entry point: runApp
│
├── app/                               # App shell (root widget, routing, DI)
│   ├── app.dart                       # Root ShadcnApp widget with MultiBlocProvider
│   ├── router.dart                    # App routing/navigation
│   └── di.dart                        # Dependency injection setup
│
├── core/                              # Shared cross-cutting concerns
│   ├── constants/                     # App-wide constants (API URLs, keys)
│   ├── errors/                        # Base exceptions and failure classes
│   ├── extensions/                    # Dart/Flutter extensions
│   ├── network/                       # HTTP client setup, interceptors
│   ├── storage/                       # Local storage abstractions
│   ├── theme/                         # shadcn_flutter theme configuration
│   │   └── app_theme.dart             #   ShadcnApp theme data & color schemes
│   └── widgets/                       # Truly shared/reusable widgets
│
├── investments/                       # 🔊 FEATURE MODULE: Investments
│   ├── domain/                        #   Business rules
│   │   ├── entities/                  #     Pure Dart business objects
│   │   │   └── investment.dart
│   │   ├── repositories/              #     Repository interfaces (contracts)
│   │   │   └── investment_repository.dart
│   │   └── usecases/                  #     Single-purpose use cases
│   │       ├── get_investments.dart
│   │       └── add_investment.dart
│   ├── data/                          #   Data access
│   │   ├── datasources/               #     Remote & local sources
│   │   │   ├── investment_remote_ds.dart
│   │   │   └── investment_local_ds.dart
│   │   ├── models/                    #     DTOs, serialization
│   │   │   └── investment_model.dart
│   │   └── repositories/              #     Repository implementations
│   │       └── investment_repository_impl.dart
│   └── presentation/                  #   UI layer
│       ├── bloc/                      #     Cubit/Bloc + State + Events
│       │   ├── investment_cubit.dart
│       │   └── investment_state.dart
│       ├── pages/                     #     Full-screen pages
│       │   └── investments_page.dart
│       └── widgets/                   #     Feature-specific widgets
│           └── investment_card.dart
│
├── portfolio/                         # 🔊 FEATURE MODULE: Portfolio
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   └── presentation/
│       ├── bloc/
│       ├── pages/
│       └── widgets/
│
├── dashboard/                         # 🔊 FEATURE MODULE: Dashboard
│   ├── domain/
│   ├── data/
│   └── presentation/
│
└── settings/                          # 🔊 FEATURE MODULE: Settings
    ├── domain/
    ├── data/
    └── presentation/
```

### Key Differences from Layer-First Architecture

| Layer-first (❌ old)                        | Screaming / Feature-first (✅ current)          |
| ------------------------------------------ | ----------------------------------------------- |
| `lib/data/repositories/`                   | `lib/investments/data/repositories/`            |
| `lib/domain/entities/`                     | `lib/investments/domain/entities/`              |
| `lib/presentation/features/investments/`   | `lib/investments/presentation/`                 |
| All features share one `data/` folder      | Each module owns its data layer                 |
| Hard to find where a feature lives         | Open `lib/` → feature folders scream at you     |

### When to Create a New Module

Create a new top-level module when:
- The feature represents a **distinct business domain** (investments, auth, portfolio, settings)
- It has **its own data sources** or entities
- It can potentially be **developed/tested independently**

Do NOT create a separate module for:
- A single widget or utility — put it in `core/widgets/` or the parent module's `widgets/`
- A sub-feature that only makes sense within another module — nest it as a subfolder

### Module-to-Module Communication

Modules must **never import from each other directly**. If module A needs data from module B:

1. **Preferred**: Share through `core/` abstractions (interfaces, shared entities)
2. **At app level**: Compose BLoCs in `app/` and pass data down via providers
3. **Events/Streams**: Use a shared event bus or stream from `core/`

```
✅  investments/ → imports from → core/
✅  portfolio/   → imports from → core/
❌  investments/ → imports from → portfolio/   (NEVER)
```

---

## When to Use Bloc vs. Cubit

| Use **Cubit** when                          | Use **Bloc** when                                |
| ------------------------------------------- | ------------------------------------------------ |
| Simple state transitions (toggle, increment)| Complex event-driven logic                       |
| No need for event traceability              | You need event replay or debugging via events    |
| Straightforward async calls (fetch, submit) | Multiple events can produce different transitions|

**Default to Cubit** unless you have a clear need for event-driven architecture.

---

## State Design

Every feature state must use **sealed classes** (Dart 3+):

```dart
// investments/presentation/bloc/investment_state.dart

sealed class InvestmentState {}

class InvestmentInitial extends InvestmentState {}

class InvestmentLoading extends InvestmentState {}

class InvestmentLoaded extends InvestmentState {
  final List<Investment> investments;
  const InvestmentLoaded({required this.investments});
}

class InvestmentError extends InvestmentState {
  final String message;
  const InvestmentError({required this.message});
}
```

### State Rules

1. **States must be immutable** — use `const` constructors and final fields.
2. **Extend `Equatable`** or override `==` / `hashCode` for proper comparison — except sealed classes with simple data.
3. **Name states** as `<Feature><Condition>` (e.g., `InvestmentLoading`, `InvestmentLoaded`).
4. **Common async pattern**: `Initial → Loading → Loaded | Error`.

---

## Cubit / Bloc Rules

### Cubit Example

```dart
// investments/presentation/bloc/investment_cubit.dart

class InvestmentCubit extends Cubit<InvestmentState> {
  final GetInvestmentsUseCase _getInvestments;

  InvestmentCubit({required GetInvestmentsUseCase getInvestments})
      : _getInvestments = getInvestments,
        super(InvestmentInitial());

  Future<void> fetchInvestments() async {
    emit(InvestmentLoading());
    try {
      final result = await _getInvestments();
      emit(InvestmentLoaded(investments: result));
    } catch (e) {
      emit(InvestmentError(message: e.toString()));
    }
  }
}
```

### Bloc Example (when events are needed)

```dart
// investments/presentation/bloc/investment_bloc.dart

class InvestmentBloc extends Bloc<InvestmentEvent, InvestmentState> {
  final GetInvestmentsUseCase _getInvestments;

  InvestmentBloc({required GetInvestmentsUseCase getInvestments})
      : _getInvestments = getInvestments,
        super(InvestmentInitial()) {
    on<FetchInvestments>(_onFetchInvestments);
  }

  Future<void> _onFetchInvestments(
    FetchInvestments event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(InvestmentLoading());
    try {
      final result = await _getInvestments();
      emit(InvestmentLoaded(investments: result));
    } catch (e) {
      emit(InvestmentError(message: e.toString()));
    }
  }
}
```

### Important Rules

1. **Never import UI packages** (`flutter`, `shadcn_flutter`) in BLoC/Cubit files.
2. **Inject dependencies** via constructor — no service locators inside the BLoC.
3. **Keep BLoCs focused** — one feature concern, one BLoC/Cubit. Avoid "god" BLoCs.
4. **No business logic in widgets** — all logic lives in the BLoC/Cubit or use-cases.
5. **Close subscriptions** — override `close()` to cancel streams or timers.

---

## Presentation Layer Integration

### Providing BLoCs

Use `BlocProvider` scoped to the module's page:

```dart
// In the router or page wrapper
BlocProvider(
  create: (context) => InvestmentCubit(
    getInvestments: context.read<GetInvestmentsUseCase>(),
  )..fetchInvestments(),
  child: const InvestmentsPage(),
);
```

For app-wide BLoCs (auth, theme), provide at the root in `app/app.dart`:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => AuthCubit(authRepo: authRepository)),
    BlocProvider(create: (_) => ThemeCubit()),
  ],
  child: const MyInvestmentsApp(),
);
```

### Building UI with shadcn_flutter Components

Always prefer **shadcn_flutter** components over Material/Cupertino equivalents:

```dart
// investments/presentation/pages/investments_page.dart

class InvestmentsPage extends StatelessWidget {
  const InvestmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestmentCubit, InvestmentState>(
      builder: (context, state) {
        return switch (state) {
          InvestmentInitial() => const SizedBox.shrink(),
          InvestmentLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          InvestmentLoaded(:final investments) => _buildList(investments),
          InvestmentError(:final message) => Alert(
              iconSrc: BootstrapIcons.exclamationTriangle,
              title: const Text('Error'),
              content: Text(message),
              destructive: true,
            ),
        };
      },
    );
  }
}
```

### Side Effects with BlocListener

Use `BlocListener` for navigation, toasts, dialogs — never in the `builder`:

```dart
BlocListener<InvestmentCubit, InvestmentState>(
  listener: (context, state) {
    if (state is InvestmentError) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(state.message),
        ),
      );
    }
  },
  child: const InvestmentsView(),
);
```

---

## Use Cases (Domain Layer)

Each use case is a **single-purpose callable class** inside its module:

```dart
// investments/domain/usecases/get_investments.dart

class GetInvestmentsUseCase {
  final InvestmentRepository _repository;

  const GetInvestmentsUseCase({required InvestmentRepository repository})
      : _repository = repository;

  Future<List<Investment>> call() {
    return _repository.getInvestments();
  }
}
```

---

## Repository Pattern

```dart
// investments/domain/repositories/investment_repository.dart (interface)
abstract class InvestmentRepository {
  Future<List<Investment>> getInvestments();
  Future<void> addInvestment(Investment investment);
}

// investments/data/repositories/investment_repository_impl.dart (implementation)
class InvestmentRepositoryImpl implements InvestmentRepository {
  final InvestmentRemoteDataSource _remoteDataSource;

  const InvestmentRepositoryImpl({
    required InvestmentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Investment>> getInvestments() async {
    final models = await _remoteDataSource.fetchInvestments();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addInvestment(Investment investment) {
    return _remoteDataSource.createInvestment(
      InvestmentModel.fromEntity(investment),
    );
  }
}
```

---

## Naming Conventions Summary

| Element         | Convention                                      | Example                          |
| --------------- | ----------------------------------------------- | -------------------------------- |
| Module folder   | `snake_case` (business domain noun)             | `investments`, `portfolio`       |
| BLoC class      | `PascalCase` + `Bloc`/`Cubit`                  | `InvestmentCubit`                |
| Event class     | `PascalCase` verb-noun                          | `FetchInvestments`               |
| State class     | `PascalCase` + condition                        | `InvestmentLoading`              |
| Use case class  | `PascalCase` + `UseCase`                        | `GetInvestmentsUseCase`          |
| Repository      | `PascalCase` + `Repository`                     | `InvestmentRepository`           |
| Page widget     | `PascalCase` + `Page`                           | `InvestmentsPage`                |
| Feature widget  | `PascalCase` descriptive                        | `InvestmentCard`                 |

---

## Checklist for New Feature Modules

1. [ ] Create the module folder: `lib/<module_name>/`
2. [ ] Create domain layer:
   - [ ] Entity in `<module>/domain/entities/`
   - [ ] Repository interface in `<module>/domain/repositories/`
   - [ ] Use case(s) in `<module>/domain/usecases/`
3. [ ] Create data layer:
   - [ ] Model (DTO) in `<module>/data/models/`
   - [ ] Data source in `<module>/data/datasources/`
   - [ ] Repository implementation in `<module>/data/repositories/`
4. [ ] Create presentation layer:
   - [ ] Cubit/Bloc + State in `<module>/presentation/bloc/`
   - [ ] Page in `<module>/presentation/pages/`
   - [ ] Feature widgets in `<module>/presentation/widgets/`
5. [ ] Use **shadcn_flutter** components for all UI elements
6. [ ] Register dependencies in `app/di.dart`
7. [ ] Add route in `app/router.dart`
8. [ ] Wire up with `BlocProvider` at the appropriate level
9. [ ] Verify no cross-module imports (only `core/` and own module)
