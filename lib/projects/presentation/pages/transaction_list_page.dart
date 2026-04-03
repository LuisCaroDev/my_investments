import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/transaction_list_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/transaction_list_state.dart';
import 'package:my_investments/projects/presentation/widgets/add_transaction_dialog.dart';
import 'package:my_investments/projects/presentation/widgets/transaction_tile.dart';

class TransactionListPage extends StatelessWidget {
  final String projectId;
  final String title;
  final String? activityId;

  const TransactionListPage({
    super.key,
    required this.projectId,
    required this.title,
    this.activityId,
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
          create: (_) => TransactionListCubit(
            repository: repo,
            projectId: projectId,
            activityId: activityId,
          )..load(),
          child: _TransactionListView(title: title),
        );
      },
    );
  }
}

class _TransactionListView extends StatelessWidget {
  final String title;

  const _TransactionListView({required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TransactionListCubit, TransactionListState>(
      builder: (context, state) {
        final footers = switch (state) {
          TransactionListLoaded() => [
            Align(
              alignment: Alignment.bottomRight,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PrimaryButton(
                    onPressed: () => _addTransaction(context, state),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(RadixIcons.plus, size: 16),
                        const Gap(6),
                        Text(l10n.common_add),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          _ => const <Widget>[],
        };

        return Scaffold(
          headers: [
            AppBar(
              leading: [
                IconButton.ghost(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(RadixIcons.arrowLeft),
                ),
              ],
              title: Text(title),
            ),
          ],
          floatingFooter: true,
          footers: footers,
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TransactionListState state) {
    final l10n = AppLocalizations.of(context)!;
    return switch (state) {
      TransactionListLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      TransactionListError(message: final msg) => Center(
        child: Text(l10n.common_error_msg(msg)),
      ),
      TransactionListLoaded() => _TransactionListContent(state: state),
    };
  }

  void _addTransaction(
    BuildContext context,
    TransactionListLoaded state,
  ) async {
    final cubit = context.read<TransactionListCubit>();
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
}

class _TransactionListContent extends StatelessWidget {
  final TransactionListLoaded state;

  const _TransactionListContent({required this.state});

  static Map<TransactionSort, String> _getSortLabels(AppLocalizations l10n) => {
    TransactionSort.dateDesc: l10n.transaction_list_sort_date_desc,
    TransactionSort.dateAsc: l10n.transaction_list_sort_date_asc,
    TransactionSort.amountDesc: l10n.transaction_list_sort_amount_desc,
    TransactionSort.amountAsc: l10n.transaction_list_sort_amount_asc,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final sortLabels = _getSortLabels(l10n);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: theme.density.baseContentPadding,
        left: theme.density.baseContentPadding,
        right: theme.density.baseContentPadding,
        bottom: theme.density.baseContentPadding + 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.transaction_list_filter_category).small.medium,
              const Spacer(),
              OutlineButton(
                onPressed: () => _showSortMenu(context),
                size: ButtonSize.small,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RadixIcons.mixerHorizontal, size: 14),
                    const Gap(6),
                    Text(sortLabels[state.sort] ?? l10n.transaction_list_sort_label),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Chip(
                onPressed: () =>
                    context.read<TransactionListCubit>().selectCategory(null),
                style: state.selectedCategoryId == null
                    ? ButtonVariance.primary
                    : ButtonVariance.secondary,
                child: Text(l10n.transaction_list_category_all),
              ),
              ...state.categories.map((cat) {
                final isSelected = state.selectedCategoryId == cat.id;
                return Chip(
                  onPressed: () => context
                      .read<TransactionListCubit>()
                      .selectCategory(isSelected ? null : cat.id),
                  style: isSelected
                      ? ButtonVariance.primary
                      : ButtonVariance.secondary,
                  child: Text(cat.name),
                );
              }),
            ],
          ),
          const Gap(16),
          if (state.filteredTransactions.isEmpty)
            EmptyState(
              icon: RadixIcons.cardStack,
              title: l10n.transaction_list_empty,
              subtitle: l10n.transaction_list_empty_filter,
            )
          else
            ...state.filteredTransactions.map(
              (t) => TransactionTile(
                transaction: t,
                categories: state.categories,
                onEdit: () => _editTransaction(context, t),
                onDelete: () {
                  context.read<TransactionListCubit>().deleteTransaction(t.id);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showSortMenu(BuildContext context) {
    showDropdown<void>(
      context: context,
      anchorAlignment: Alignment.bottomRight,
      alignment: Alignment.topRight,
      builder: (ctx) {
        final l10n = AppLocalizations.of(context)!;
        final sortLabels = _getSortLabels(l10n);
        return DropdownMenu(
          children: TransactionSort.values
              .map(
                (sort) => MenuButton(
                  child: Text(sortLabels[sort] ?? sort.name),
                  onPressed: (_) =>
                      context.read<TransactionListCubit>().changeSort(sort),
                ),
              )
              .toList(),
        );
      },
    );
  }

  void _editTransaction(BuildContext context, Transaction transaction) async {
    final cubit = context.read<TransactionListCubit>();
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
