# Financial Accounts, Goals, and Priority-based Funding Plan (V3)

Transitioning to a **Priority-based Virtual Funding** model where account balances are automatically allocated to Projects and Goals based on their priority.

## User Review Required

> [!IMPORTANT]
> **No more 'Capital Injected'**: The `capitalInjection` transaction type and all `totalCapitalInjected` fields will be **removed**. Funding becomes a virtual state derived from account balances.
> **Backend simulation**: The distribution logic will live in `ProjectsRepository` (data layer) so the presentation layer only receives pre-calculated `fundedAmount` and `remainingToFund` stats.

> [!WARNING]
> **Breaking change for existing data**: Existing `capitalInjection` transactions will become orphaned (ignored in calculations). Consider adding a data-migration step during import or on first launch to preserve historical records (e.g. by converting them to `deposit` type, or archiving them).

> [!IMPORTANT]
> **Separate UI, Shared Data**: Investments and Goals share the same `Project` entity and DB table (differentiated by a `type` field), but they have **completely separate screens** in the UI. The bottom navigation has **3 tabs**: Investments | Goals | Accounts.

1.  **Differentiated Accounts**: Accounts can be `bank` or `loan`. Both contribute to your total liquidity.
2.  **Separate API boundaries**: Investments and Goals share the same `Project` entity at the domain level, but the **repository exposes separate methods** for each (`getInvestmentSummaries`, `getGoalSummaries`, `addInvestment`, `addGoal`, etc.). This way, when migrating to REST APIs, each maps to its own endpoint. The data source (SharedPreferences) still uses a single shared table internally.
3.  **Separate UI screens**: Each has its own page, cubit, and navigation tab.
4.  **Universal "Remaining to Fund"**: Both Investments and Goals will show how much money is still needed from your accounts to cover their total budget.
5.  **Removal of Capital Injection**: The `capitalInjection` transaction type will be removed from the codebase. Funding is now a virtual state calculated from your combined account balances.
6.  **Priority-based Funding**: Each project gets a `priority` (int, lower = higher priority). The funding algorithm iterates **all** projects (investments + goals combined) sorted by priority ascending and drains the liquidity pool.
7.  **Transaction Money Source**: Every transaction now tracks which `FinancialAccount` it came from via an `accountId` field. A default **"Initial Statement"** account is auto-created on first launch to backfill existing transactions.

---

## Proposed Changes

### Domain Layer (`lib/projects/domain/entities`)

#### [NEW] [financial_account.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/domain/entities/financial_account.dart)

New entity representing a bank account or loan:

```dart
enum FinancialAccountType { bank, loan }

class FinancialAccount {
  final String id;
  final String name;
  final FinancialAccountType type;
  final double balance;
  final DateTime createdAt;

  const FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.createdAt,
  });

  FinancialAccount copyWith({ ... });
}
```

---

#### [MODIFY] [project.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/domain/entities/project.dart)

Add `type` and `priority` fields:

```diff
+enum ProjectType { investment, savingsGoal }

 class Project {
   final String id;
   final String name;
   final String? description;
   final double? globalBudget;
+  final ProjectType type;
+  final int priority;
   final DateTime createdAt;

   const Project({
     required this.id,
     required this.name,
     this.description,
     this.globalBudget,
+    this.type = ProjectType.investment,
+    this.priority = 0,
     required this.createdAt,
   });
```

**Impact**: `ProjectModel`, `AddProjectDialog`, `ImportExportPage` all need updating.

---

#### [MODIFY] [project_summary.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/domain/entities/project_summary.dart)

Replace `totalCapitalInjected` with virtual funding fields:

```diff
 class ProjectSummary {
   final Project project;
   final double totalBudget;
   final double totalSpent;
   final double totalDeposited;
-  final double totalCapitalInjected;
+  final double fundedAmount;      // virtual, from funding distribution
+  final double remainingToFund;   // virtual, budget - fundedAmount
   final int activityCount;

   double get operatingBalance => totalDeposited - totalSpent;
-  double get netBalance => operatingBalance + totalCapitalInjected;
-  double get remainingBudget => totalBudget - totalDeposited;
+  double get netBalance => operatingBalance + fundedAmount;
   double get budgetProgress =>
       totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
+  double get fundingProgress =>
+      totalBudget > 0 ? (fundedAmount / totalBudget).clamp(0.0, 1.0) : 0.0;
 }
```

---

#### [MODIFY] [project_detail.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/domain/entities/project_detail.dart)

Same replacement — remove `totalCapitalInjected`, add `fundedAmount` + `remainingToFund`:

```diff
 class ProjectDetail {
   ...
-  final double totalCapitalInjected;
+  final double fundedAmount;
+  final double remainingToFund;
   ...
-  double get netBalance => operatingBalance + totalCapitalInjected;
+  double get netBalance => operatingBalance + fundedAmount;
 }
```

---

#### [MODIFY] [activity_summary.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/domain/entities/activity_summary.dart)

Remove `capitalInjected`:

```diff
 class ActivitySummary {
   final Activity activity;
   final double spent;
   final double deposited;
-  final double capitalInjected;
   final List<Category> categories;
   final int transactionCount;
   ...
-  double get netBalance => operatingBalance + capitalInjected;
+  double get netBalance => operatingBalance;
 }
```

---

#### [MODIFY] [transaction.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/domain/entities/transaction.dart)

Remove `capitalInjection` from the enum and add `accountId`:

```diff
-enum TransactionType { expense, deposit, capitalInjection }
+enum TransactionType { expense, deposit }

 class Transaction {
   final String id;
   final String projectId;
   final String? activityId;
   final String? categoryId;
+  final String accountId;  // required — which financial account this money came from
   final TransactionType type;
   ...
 }
```

**Impact**: `TransactionModel`, `AddTransactionDialog`, `TransactionTile`, `ImportExportPage` all need updating.

---

### Data Layer (`lib/projects/data`)

#### [NEW] [financial_account_model.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/data/models/financial_account_model.dart)

DTO extending `FinancialAccount` with `fromJson` / `toJson` / `fromEntity`:

```dart
class FinancialAccountModel extends FinancialAccount {
  // Same pattern as ProjectModel
  factory FinancialAccountModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  factory FinancialAccountModel.fromEntity(FinancialAccount entity);
}
```

---

#### [MODIFY] [project_model.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/data/models/project_model.dart)

Add `type` and `priority` to JSON serialization:

```diff
 class ProjectModel extends Project {
   const ProjectModel({
     ...
+    required super.type,
+    required super.priority,
   });

   factory ProjectModel.fromJson(Map<String, dynamic> json) {
     return ProjectModel(
       ...
+      type: ProjectType.values.byName(json['type'] as String? ?? 'investment'),
+      priority: (json['priority'] as num?)?.toInt() ?? 0,
     );
   }

   Map<String, dynamic> toJson() {
     return {
       ...
+      'type': type.name,
+      'priority': priority,
     };
   }
 }
```

---

#### [MODIFY] [projects_local_ds.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/data/datasources/projects_local_ds.dart)

Add `financial_accounts` CRUD methods:

```dart
static const _accountsKey = 'financial_accounts';

List<FinancialAccountModel> getAccounts() { ... }
Future<void> saveAccounts(List<FinancialAccountModel> accounts) async { ... }
```

---

#### [MODIFY] [projects_repository_impl.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/data/repositories/projects_repository_impl.dart)

This is the **core change**. The repository becomes the API boundary with **separate methods for investments and goals** (future REST-ready).

**New API surface:**

```dart
// ── Investments (future: GET /api/investments) ──
List<ProjectSummary> getInvestmentSummaries();
ProjectDetail getInvestmentDetail(String projectId);
Future<void> addInvestment(Project project);       // forces type = investment
Future<void> updateInvestment(Project project);
Future<void> deleteInvestment(String projectId);

// ── Goals (future: GET /api/goals) ──
List<ProjectSummary> getGoalSummaries();
ProjectDetail getGoalDetail(String projectId);
Future<void> addGoal(Project project);              // forces type = savingsGoal
Future<void> updateGoal(Project project);
Future<void> deleteGoal(String projectId);

// ── Accounts (future: GET /api/accounts) ──
List<FinancialAccount> getAccounts();
Future<void> addAccount(FinancialAccount account);
Future<void> updateAccount(FinancialAccount account);
Future<void> deleteAccount(String accountId);
```

Internally, the `getInvestmentSummaries()` and `getGoalSummaries()` methods both call a **shared private method** `_buildProjectSummaries(ProjectType type)` that:
1. Filters projects from the data source by `type`.
2. Runs the **Funding Distribution Algorithm** (computed over **all** projects regardless of type, to drain liquidity correctly by global priority).
3. Returns only the summaries matching the requested type, **sorted by priority ascending** (drag order).

**Reorder methods** (for drag-to-reorder):

```dart
// Called when user reorders via drag on ProjectsPage
Future<void> reorderInvestments(List<String> orderedIds) async {
  // Assigns priority = index for each ID, saves to data source
}

// Called when user reorders via drag on GoalsPage
Future<void> reorderGoals(List<String> orderedIds) async {
  // Same logic for goals
}
```

**Funding Distribution Algorithm** (pseudo-code):

```
totalLiquidity = sum of all account balances
ALL projects (investments + goals) sorted ASC by priority

for each project in sorted order:
  budget = project.totalBudget
  funded = min(budget, remainingLiquidity)
  remainingLiquidity -= funded
  project.fundedAmount = funded
  project.remainingToFund = budget - funded

return only projects where type == requestedType
```

**Remove all `capitalInjection` filtering** from all methods.

> [!NOTE]
> The existing generic `getProjectSummaries()` can remain as a private helper or be removed. The public API is now type-specific.

---

### Presentation Layer (`lib/projects/presentation`)

#### [NEW] [main_navigation_page.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/pages/main_navigation_page.dart)

Bottom navigation shell with **3 tabs**:

| Tab | Icon | Label | Content |
|-----|------|-------|---------|
| Investments | `RadixIcons.cube` | Investments | `ProjectsPage` (existing, filtered to `investment` type) |
| Goals | `RadixIcons.target` | Goals | `GoalsPage` (new, filtered to `savingsGoal` type) |
| Accounts | `RadixIcons.cardStackPlus` | Accounts | `AccountsPage` (new) |

Uses `IndexedStack` to preserve tab state. This replaces `ProjectsPage` as the `home:` in `main.dart`.

---

#### [NEW] [accounts_page.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/pages/accounts_page.dart)

A page listing all `FinancialAccount` entries with:
- **Header stat cards**: Total Liquidity, Bank Accounts total, Loans total.
- **Account list**: Each card shows name, type badge (`Bank`/`Loan`), and balance.
- **FAB**: "New Account" button → opens `AddFinancialAccountDialog`.
- **Actions menu** per card: Edit, Delete.

---

#### [NEW] [accounts_cubit.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/bloc/accounts_cubit.dart)

```dart
class AccountsCubit extends Cubit<AccountsState> {
  final ProjectsRepository _repository;

  AccountsCubit({required ProjectsRepository repository})
    : _repository = repository, super(const AccountsInitial());

  void loadAccounts() { ... }
  Future<void> addAccount(FinancialAccount account) async { ... }
  Future<void> updateAccount(FinancialAccount account) async { ... }
  Future<void> deleteAccount(String accountId) async { ... }
}
```

---

#### [NEW] [accounts_state.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/bloc/accounts_state.dart)

```dart
sealed class AccountsState { const AccountsState(); }
class AccountsInitial extends AccountsState { ... }
class AccountsLoading extends AccountsState { ... }
class AccountsLoaded extends AccountsState {
  final List<FinancialAccount> accounts;
  final double totalLiquidity;
  ...
}
class AccountsError extends AccountsState { ... }
```

---

#### [NEW] [add_financial_account_dialog.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/widgets/add_financial_account_dialog.dart)

Dialog with fields:
- **Name** (TextField)
- **Type** (ButtonGroup: Bank / Loan)
- **Balance** (TextField, numeric)

Supports both create and edit mode (like `AddProjectDialog`).

---

#### [NEW] [goals_page.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/pages/goals_page.dart)

A dedicated page for **Savings Goals** (mirrors `ProjectsPage` structure but filtered to `savingsGoal` type):
- **Header stat cards**: Total Goal Budget, Total Funded, Total Remaining.
- **Goals list**: Each card shows name, funding progress bar, funded/remaining amounts.
- **FAB**: "New Goal" → opens `AddProjectDialog` with `type` pre-set to `savingsGoal` (type selector hidden).
- **Actions menu** per card: Edit, Delete.

This page uses its own `GoalsCubit` which calls `_repository.getProjectSummaries()` and filters to `savingsGoal` type.

---

#### [NEW] [goals_cubit.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/bloc/goals_cubit.dart)

```dart
class GoalsCubit extends Cubit<GoalsState> {
  final ProjectsRepository _repository;

  GoalsCubit({required ProjectsRepository repository})
    : _repository = repository, super(const GoalsInitial());

  void loadGoals() {
    // Calls the goal-specific repository method (no filtering here)
    final summaries = _repository.getGoalSummaries();
    emit(GoalsLoaded(summaries: summaries));
  }

  Future<void> addGoal(Project project) async {
    await _repository.addGoal(project);
    loadGoals();
  }
  Future<void> updateGoal(Project project) async { ... }
  Future<void> deleteGoal(String projectId) async { ... }
}
```

---

#### [NEW] [goals_state.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/bloc/goals_state.dart)

```dart
sealed class GoalsState { const GoalsState(); }
class GoalsInitial extends GoalsState { ... }
class GoalsLoading extends GoalsState { ... }
class GoalsLoaded extends GoalsState {
  final List<ProjectSummary> summaries;
  ...
}
class GoalsError extends GoalsState { ... }
```

---

#### [MODIFY] [add_project_dialog.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/widgets/add_project_dialog.dart)

Accept a `projectType` parameter from the caller:

```diff
 class AddProjectDialog extends StatefulWidget {
+  final ProjectType projectType;  // defaults to investment, passed by caller
   ...
 }
```

- When opened from `ProjectsPage` → `projectType = ProjectType.investment` (type selector hidden).
- When opened from `GoalsPage` → `projectType = ProjectType.savingsGoal` (type selector hidden).
- **No priority field** — priority is set visually via drag-to-reorder on the list.
- New projects are appended at the **end** of the list (lowest priority). User can drag them up.
- Return `type` in the result map.

---

#### [MODIFY] [projects_page.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/pages/projects_page.dart)

- The `ProjectsCubit.loadProjects()` now calls `_repository.getInvestmentSummaries()` (no client-side filtering).
- Replace the **Capital Injected** stat card with **Total Funded** (virtual).
- Replace the **Net Balance** computation to use `fundedAmount`.
- On `_ProjectCard`: show **Funding Progress** bar instead of (or alongside) budget progress.
- On `_showAddProjectDialog`: pass `type: ProjectType.investment`, no priority needed.
- **Drag-to-reorder priority**: Wrap the project list in `SortableLayer` → each `_ProjectCard` wrapped in `Sortable<String>` with `onAcceptTop` / `onAcceptBottom` callbacks. On drop, call `cubit.reorderInvestments(newOrderedIds)` which persists the new priority values.

```dart
// Usage pattern:
SortableLayer(
  child: Column(
    children: summaries.map((s) => Sortable<String>(
      data: SortableData(s.project.id),
      onAcceptTop: (data) => _reorder(data.data, s.project.id, above: true),
      onAcceptBottom: (data) => _reorder(data.data, s.project.id, above: false),
      child: _ProjectCard(summary: s),
    )).toList(),
  ),
)
```

---

#### [MODIFY] [project_detail_page.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/pages/project_detail_page.dart)

- Replace the **Capital Injected** stat card with **Funded Amount**.
- Replace **Net Balance** computation (uses `fundedAmount`).
- Add a **Remaining to Fund** stat card.
- Remove `capitalInjection` transaction type from the add-transaction flow.

---

#### [MODIFY] [activity_detail_page.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/pages/activity_detail_page.dart)

- Remove the **Capital Injected** stat card.
- Remove **Net Balance** stat card (activities no longer track capital).
- Keep Deposited, Spent, Operating Balance, Budget.

---

#### [MODIFY] [add_transaction_dialog.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/widgets/add_transaction_dialog.dart)

- Remove the `capitalInjection` button from the type `ButtonGroup`.
- Only show `expense` and `deposit`.
- **Add an account selector**: The dialog receives a `List<FinancialAccount> availableAccounts` and shows a dropdown/picker for the user to select which account the money comes from. The selected `accountId` is returned in the result map.

---

#### [MODIFY] [budget_progress.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/widgets/budget_progress.dart)

Add an optional `funded` parameter to display a **funding layer** on the progress bar:

```diff
 class BudgetProgress extends StatelessWidget {
   final double budget;
   final double deposited;
   final double spent;
+  final double? funded;  // virtual funded amount
   final String Function(num) formatCurrency;
```

When `funded` is provided, render an additional progress layer showing the funding coverage.

---

#### [MODIFY] [main.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/main.dart)

- Replace `home: const ProjectsPage()` with `home: const MainNavigationPage()`.
- Add `AccountsCubit` and `GoalsCubit` to `MultiBlocProvider`.

---

### Import/Export

#### [MODIFY] [import_export_page.dart](file:///Users/luiscarodev/development/personal/my_investments/lib/projects/presentation/pages/import_export_page.dart)

Add a 5th CSV section: `## accounts.csv`

**Export** — add columns: `id, name, type, balance, created_at`.
**Import** — parse the new section and call `ds.saveAccounts(...)`.
**Projects CSV** — add `type` and `priority` columns.
**Transactions CSV** — add `account_id` column. Handle legacy `capitalInjection` type gracefully (convert to `deposit` and assign to "Initial Statement" account on import).

---

### Localization (`lib/l10n`)

#### [MODIFY] app_en.arb & app_es.arb

New keys to add:

| Key | EN | ES |
|-----|----|----|
| `nav_investments` | Investments | Inversiones |
| `nav_goals` | Goals | Metas |
| `nav_accounts` | Accounts | Cuentas |
| `goals_title` | Savings Goals | Metas de Ahorro |
| `goals_add_button` | New Goal | Nueva Meta |
| `goals_empty_title` | No goals yet | Aún no tienes metas |
| `goals_empty_subtitle` | Create savings goals to track your progress towards financial targets. | Crea metas de ahorro para rastrear tu progreso hacia tus objetivos financieros. |
| `goals_summary_total_budget` | Total Goal Budget | Presupuesto Total de Metas |
| `goals_summary_funded` | Total Funded | Total Financiado |
| `goals_summary_remaining` | Remaining | Por Financiar |
| `accounts_title` | Financial Accounts | Cuentas Financieras |
| `accounts_add_button` | New Account | Nueva Cuenta |
| `accounts_empty_title` | No accounts yet | Aún no tienes cuentas |
| `accounts_empty_subtitle` | Add your bank accounts and loans to track your available liquidity. | Agrega tus cuentas bancarias y préstamos para rastrear tu liquidez disponible. |
| `accounts_summary_total_liquidity` | Total Liquidity | Liquidez Total |
| `accounts_summary_banks` | Banks | Bancos |
| `accounts_summary_loans` | Loans | Préstamos |
| `accounts_delete_title` | Delete account | Eliminar cuenta |
| `accounts_delete_confirmation` | Are you sure you want to delete this account? | ¿Seguro que quieres eliminar esta cuenta? |
| `dialog_account_new_title` | New Account | Nueva Cuenta |
| `dialog_account_edit_title` | Edit Account | Editar Cuenta |
| `dialog_account_name_placeholder` | E.g.: Main Bank Account | Ej: Cuenta Bancaria Principal |
| `dialog_account_type_label` | Account Type | Tipo de Cuenta |
| `dialog_account_type_bank` | Bank | Banco |
| `dialog_account_type_loan` | Loan | Préstamo |
| `dialog_account_balance_label` | Balance | Saldo |

| `projects_summary_funded` | Funded | Financiado |
| `projects_summary_remaining` | Remaining to Fund | Por Financiar |
| `widget_budget_progress_funded` | Funded: | Financiado: |

**Keys to remove** (or repurpose):
- `projects_summary_capital` → replaced by `projects_summary_funded`
- `project_detail_summary_capital` → replaced by `projects_summary_funded`
- `activity_detail_summary_capital` → remove
- `dialog_tx_type_capital`, `dialog_tx_new_capital`, `dialog_tx_edit_capital` → remove
- `dialog_project_type_label`, `dialog_project_type_investment`, `dialog_project_type_savings` → no longer needed (type is implicit per screen)

---

## Data Migration Strategy

On first launch after this update (detected by checking if the `financial_accounts` key exists in SharedPreferences):

1. **Create the "Initial Statement" default account**:
   ```dart
   FinancialAccount(
     id: 'initial_statement',
     name: 'Initial Statement',
     type: FinancialAccountType.bank,
     balance: 0,  // placeholder — user can update later
     createdAt: DateTime.now(),
   )
   ```

2. **Backfill all existing transactions**: Set `accountId = 'initial_statement'` for every transaction that has no `accountId`.

3. **Convert `capitalInjection` transactions**: Change their `type` to `deposit` and assign `accountId = 'initial_statement'`.

4. **Default existing projects**: Set `type = ProjectType.investment` and `priority = 0` for all projects missing these fields.

This migration runs once, silently, in the repository constructor or a dedicated `migrate()` method called from `main.dart` before the app starts.

---

All open questions have been resolved:
- **Migration**: Auto-convert `capitalInjection` → `deposit`, backfill with "Initial Statement" account.
- **Priority**: Visual drag-to-reorder using shadcn_flutter `SortableLayer` + `Sortable`.
- **Existing projects**: Default to `investment` type, priority = 0.

---

## Verification Plan

### Automated Tests
- **Funding distribution**: Unit test the algorithm inside `ProjectsRepository`:
  - Total Liquidity $1500 → Project Prio 1 (Budget $1200) gets $1200 funded → Project Prio 2 (Budget $500) gets $300 funded, $200 remaining.
  - Zero accounts → all projects have $0 funded.
  - Zero-budget projects are skipped.
  - Equal-priority projects share funding in insertion order.
- **Entity tests**: Verify `ProjectSummary.fundingProgress`, `remainingToFund` computed properties.
- **Migration tests**: Verify backfill assigns `initial_statement` to all existing transactions, converts `capitalInjection` → `deposit`, and sets project defaults.
- **Import/Export roundtrip**: Export → re-import → verify data integrity including accounts, `accountId` on transactions, and project type/priority.

### Manual Verification
1. Create 2 accounts: Bank ($500) + Loan ($1000) = $1500 Total.
2. On **Investments tab**: Create Investment Prio 1 (Budget $1200).
3. On **Goals tab**: Create Goal Prio 2 (Budget $500).
4. **Verify on Investments tab**: Prio 1 shows 100% funded ($0 remaining).
5. **Verify on Goals tab**: Prio 2 shows $300 funded ($200 remaining).
6. Edit Bank account balance to $200 → total liquidity $1200 → Prio 1 still 100%, Prio 2 drops to $0 funded.
7. Delete an account → liquidity recalculates → both tabs update.
8. Navigate between all 3 tabs → state preserved.
9. Export data → verify `accounts.csv` section present with correct data.
10. Import data on fresh install → accounts, investments, goals, and transactions restored.
