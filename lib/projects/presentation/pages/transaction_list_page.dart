import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/financial_account.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_state.dart';
import 'package:my_investments/projects/presentation/bloc/transaction_list_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/transaction_list_state.dart';
import 'package:my_investments/projects/presentation/widgets/add_transaction_dialog.dart';
import 'package:my_investments/projects/presentation/widgets/transaction_tile.dart';

List<FinancialAccount> _getAccountsFromContext(BuildContext context) {
  final state = context.read<AccountsCubit>().state;
  if (state is AccountsLoaded) return state.accounts;
  return const [];
}

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
                ...AppBackButton.render(context),
              ],
              title: Text(title),
            ),
            Divider(height: 1),
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
    return SafeArea(
      top: false,
      bottom: false,
      child: switch (state) {
        TransactionListLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        TransactionListError(message: final msg) => Center(
          child: Text(l10n.common_error_msg(msg)),
        ),
        TransactionListLoaded() => _TransactionListContent(state: state),
      },
    );
  }

  void _addTransaction(
    BuildContext context,
    TransactionListLoaded state,
  ) async {
    final cubit = context.read<TransactionListCubit>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        availableCategories: state.categories,
        availableAccounts: _getAccountsFromContext(context),
      ),
    );
    if (result != null && context.mounted) {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: cubit.projectId,
        activityId: cubit.activityId,
        accountId: result['accountId'] as String? ?? 'initial_statement',
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
          Select<String?>(
            value: state.selectedCategoryId,
            onChanged: (value) {
              context.read<TransactionListCubit>().selectCategory(value);
            },
            placeholder: Text(l10n.transaction_list_category_all),
            itemBuilder: (context, value) {
              if (value == null) {
                return Text(l10n.transaction_list_category_all);
              }
              final category = state.categories.firstWhere((c) => c.id == value);
              return Text(category.name);
            },
            popup: (context) {
              final activityCategories =
                  state.categories.where((c) => c.activityId != null).toList();
              final projectCategories =
                  state.categories.where((c) => c.activityId == null).toList();

              return SelectPopup(
                items: SelectItemList(
                  children: [
                    SelectItemButton(
                      value: null,
                      child: Text(l10n.transaction_list_category_all),
                    ),
                    if (activityCategories.isNotEmpty)
                      SelectGroup(
                        headers: [
                          SelectLabel(child: Text(l10n.common_activity)),
                        ],
                        children: activityCategories
                            .map(
                              (cat) => SelectItemButton(
                                value: cat.id,
                                child: Text(cat.name),
                              ),
                            )
                            .toList(),
                      ),
                    if (projectCategories.isNotEmpty)
                      SelectGroup(
                        headers: [SelectLabel(child: Text(l10n.common_project))],
                        children: projectCategories
                            .map(
                              (cat) => SelectItemButton(
                                value: cat.id,
                                child: Text(cat.name),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              );
            },
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
        availableAccounts: _getAccountsFromContext(context),
        initialTransaction: transaction,
      ),
    );
    if (result != null && context.mounted) {
      final updated = transaction.copyWith(
        type: result['type'] as TransactionType,
        accountId: result['accountId'] as String? ?? transaction.accountId,
        amount: result['amount'] as double,
        date: result['date'] as DateTime,
        description: result['description'] as String?,
        categoryId: result['categoryId'] as String?,
      );
      cubit.updateTransaction(updated);
    }
  }
}
