import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/category.dart'
    as domain;
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/pages/category_management_page.dart';
import 'package:my_investments/projects/presentation/widgets/add_transaction_dialog.dart';
import 'package:my_investments/projects/presentation/widgets/budget_progress.dart';
import 'package:my_investments/projects/presentation/widgets/transaction_tile.dart';

/// A dedicated page for viewing an Activity's details, its categories,
/// and transactions. Uses its own Cubit scoped to the activity.
class ActivityDetailPage extends StatelessWidget {
  final String projectId;
  final String activityId;
  final String activityName;

  const ActivityDetailPage({
    super.key,
    required this.projectId,
    required this.activityId,
    required this.activityName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ds = ProjectsLocalDataSource(prefs: snapshot.data!);
        final repo = ProjectsRepository(localDataSource: ds);
        return BlocProvider(
          create: (_) => _ActivityDetailCubit(
            repository: repo,
            projectId: projectId,
            activityId: activityId,
          )..load(),
          child: _ActivityDetailView(activityName: activityName),
        );
      },
    );
  }
}

// ── Private Cubit for Activity Detail ─────────────────────────

const _unsetCategoryFilter = Object();

class _ActivityDetailState {
  final bool loading;
  final String? error;
  final double budget;
  final double deposited;
  final double spent;
  final List<Transaction> transactions;
  final List<domain.Category> categories;
  final String? selectedCategoryId;

  const _ActivityDetailState({
    this.loading = true,
    this.error,
    this.budget = 0,
    this.deposited = 0,
    this.spent = 0,
    this.transactions = const [],
    this.categories = const [],
    this.selectedCategoryId,
  });

  double get balance => deposited - spent;

  List<Transaction> get filteredTransactions {
    if (selectedCategoryId == null) return transactions;
    return transactions
        .where((t) => t.categoryId == selectedCategoryId)
        .toList();
  }

  _ActivityDetailState copyWith({
    bool? loading,
    String? error,
    double? budget,
    double? deposited,
    double? spent,
    List<Transaction>? transactions,
    List<domain.Category>? categories,
    Object? selectedCategoryId = _unsetCategoryFilter,
  }) {
    return _ActivityDetailState(
      loading: loading ?? this.loading,
      error: error,
      budget: budget ?? this.budget,
      deposited: deposited ?? this.deposited,
      spent: spent ?? this.spent,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId == _unsetCategoryFilter
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
    );
  }
}

class _ActivityDetailCubit extends Cubit<_ActivityDetailState> {
  final ProjectsRepository _repository;
  final String projectId;
  final String activityId;

  _ActivityDetailCubit({
    required ProjectsRepository repository,
    required this.projectId,
    required this.activityId,
  }) : _repository = repository,
       super(const _ActivityDetailState());

  void load() {
    try {
      final activities = _repository.getActivitiesForProject(projectId);
      final activity = activities.firstWhere((a) => a.id == activityId);
      final transactions = _repository.getTransactionsForActivity(activityId);
      final categories = _repository.getAvailableCategories(
        projectId,
        activityId,
      );

      final spent = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final deposited = transactions
          .where((t) => t.type == TransactionType.deposit)
          .fold(0.0, (sum, t) => sum + t.amount);

      emit(
        _ActivityDetailState(
          loading: false,
          budget: activity.budget ?? 0,
          deposited: deposited,
          spent: spent,
          transactions: transactions,
          categories: categories,
          selectedCategoryId: state.selectedCategoryId,
        ),
      );
    } catch (e) {
      emit(_ActivityDetailState(loading: false, error: e.toString()));
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    load();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _repository.deleteTransaction(transactionId);
    load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
    load();
  }

  Future<void> addCategory(domain.Category category) async {
    await _repository.addCategory(category);
    load();
  }

  Future<void> updateCategory(domain.Category category) async {
    await _repository.updateCategory(category);
    load();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    load();
  }

  void selectCategory(String? categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }
}

// ── View ──────────────────────────────────────────────────────

class _ActivityDetailView extends StatelessWidget {
  final String activityName;

  const _ActivityDetailView({required this.activityName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_ActivityDetailCubit, _ActivityDetailState>(
      builder: (context, state) {
        return Scaffold(
          headers: [
            AppBar(
              leading: [
                IconButton.ghost(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(RadixIcons.arrowLeft),
                ),
              ],
              title: Text(activityName),
            ),
          ],
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _ActivityDetailState state) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }
    return _ActivityContent(state: state);
  }
}

class _ActivityContent extends StatelessWidget {
  final _ActivityDetailState state;

  const _ActivityContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              OutlineButton(
                onPressed: () => _openCategoryManagement(context),
                size: ButtonSize.small,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RadixIcons.bookmarkFilled, size: 14),
                    Gap(6),
                    Text('Categoría'),
                  ],
                ),
              ),
              const Gap(6),
              PrimaryButton(
                onPressed: () => _addTransaction(context),
                size: ButtonSize.small,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RadixIcons.plus, size: 14),
                    Gap(6),
                    Text('Transacción'),
                  ],
                ),
              ),
            ],
          ),

          const Gap(12),
          // ── Summary ──────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 180,
                child: Card(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Depositado').muted.small,
                      const Gap(4),
                      Text(
                        state.deposited.toCompactCurrency(),
                      ).bold(color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Card(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Gastado').muted.small,
                      const Gap(4),
                      Text(
                        state.spent.toCompactCurrency(),
                      ).bold(color: theme.colorScheme.destructive),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Card(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Balance').muted.small,
                      const Gap(4),
                      Text(state.balance.toCompactCurrency()).bold,
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (state.budget > 0) ...[
            const Gap(16),
            Card(
              padding: const EdgeInsets.all(16),
              child: BudgetProgress(
                budget: state.budget,
                deposited: state.deposited,
                spent: state.spent,
                formatCurrency: (v) => v.toCompactCurrency(),
              ),
            ),
          ],

          // ── Categories ───────────────────────
          if (state.categories.isNotEmpty) ...[
            const Gap(24),
            const Text('Categorías').medium,
            const Gap(8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Chip(
                  onPressed: () =>
                      context.read<_ActivityDetailCubit>().selectCategory(null),
                  style: state.selectedCategoryId == null
                      ? ButtonVariance.primary
                      : ButtonVariance.secondary,
                  child: const Text('Todas'),
                ),
                ...state.categories.map((cat) {
                  final isActivityLevel = cat.activityId != null;
                  final isSelected = state.selectedCategoryId == cat.id;
                  return Chip(
                    onPressed: () => context
                        .read<_ActivityDetailCubit>()
                        .selectCategory(isSelected ? null : cat.id),
                    style: isSelected
                        ? ButtonVariance.primary
                        : ButtonVariance.secondary,
                    child: Text(
                      '${cat.name}${isActivityLevel ? '' : ' (proyecto)'}',
                    ),
                  );
                }),
              ],
            ),
          ],

          // ── Transactions ─────────────────────
          const Gap(24),
          const Text('Transacciones').large.bold,
          const Gap(12),

          if (state.filteredTransactions.isEmpty)
            const EmptyState(
              icon: RadixIcons.cardStack,
              title: 'Sin transacciones',
              subtitle: 'Agrega gastos o depósitos para esta actividad.',
            )
          else
            ...state.filteredTransactions.reversed.map(
              (t) => TransactionTile(
                transaction: t,
                categories: state.categories,
                enableSwipeDelete: true,
                onEdit: () => _editTransaction(context, t),
                onDelete: () {
                  context.read<_ActivityDetailCubit>().deleteTransaction(t.id);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _addTransaction(BuildContext context) async {
    final cubit = context.read<_ActivityDetailCubit>();
    final state = cubit.state;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) =>
          AddTransactionDialog(availableCategories: state.categories),
    );
    if (result != null && context.mounted) {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: cubit.projectId,
        activityId: cubit.activityId,
        type: result['type'] as TransactionType,
        amount: result['amount'] as double,
        date: result['date'] as DateTime,
        description: result['description'] as String?,
        categoryId: result['categoryId'] as String?,
        createdAt: DateTime.now(),
      );
      cubit.addTransaction(transaction);
    }
  }

  void _openCategoryManagement(BuildContext context) {
    final cubit = context.read<_ActivityDetailCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryManagementPage(
          projectId: cubit.projectId,
          activityId: cubit.activityId,
          title: 'Categorías de la Actividad',
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context, Transaction transaction) async {
    final cubit = context.read<_ActivityDetailCubit>();
    final state = cubit.state;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        availableCategories: state.categories,
        initialTransaction: transaction,
      ),
    );
    if (result != null && context.mounted) {
      final updated = transaction.copyWith(
        type: result['type'] as TransactionType,
        amount: result['amount'] as double,
        date: result['date'] as DateTime,
        description: result['description'] as String?,
        categoryId: result['categoryId'] as String?,
      );
      cubit.updateTransaction(updated);
    }
  }

}
