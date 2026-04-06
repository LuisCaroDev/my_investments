import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:my_investments/projects/presentation/bloc/activity_detail_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/activity_detail_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:my_investments/core/router/app_router.dart';
import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';

import 'package:my_investments/projects/domain/entities/financial_account.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_state.dart';
import 'package:my_investments/projects/presentation/widgets/add_transaction_dialog.dart';
import 'package:my_investments/projects/presentation/widgets/budget_progress.dart';
import 'package:my_investments/projects/presentation/widgets/section_header.dart';
import 'package:my_investments/projects/presentation/widgets/transaction_tile.dart';
import 'package:my_investments/projects/presentation/widgets/category_tile.dart';

List<FinancialAccount> _getAccountsFromContext(BuildContext context) {
  final state = context.read<AccountsCubit>().state;
  if (state is AccountsLoaded) return state.accounts;
  return const [];
}

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
          create: (_) => ActivityDetailCubit(
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

// ── View ──────────────────────────────────────────────────────

class _ActivityDetailView extends StatelessWidget {
  final String activityName;

  const _ActivityDetailView({required this.activityName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ActivityDetailCubit, ActivityDetailState>(
      builder: (context, state) {
        final footers = [
          if (!state.loading && state.error == null)
            Align(
              alignment: Alignment.bottomRight,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PrimaryButton(
                    onPressed: () => _addTransaction(context),
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
        ];

        return Scaffold(
          headers: [
            AppBar(
              leading: [
                ...AppBackButton.render(context),
              ],
              title: Text(activityName),
            ),
            Divider(height: 1),
          ],
          floatingFooter: true,
          footers: footers,
          child: SafeArea(
            top: false,
            bottom: false,
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  void _addTransaction(BuildContext context) async {
    final cubit = context.read<ActivityDetailCubit>();
    final state = cubit.state;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        availableCategories: state.detail!.categories,
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

  Widget _buildBody(BuildContext context, ActivityDetailState state) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      final l10n = AppLocalizations.of(context)!;
      return Center(child: Text(l10n.common_error_msg(state.error!)));
    }
    return _ActivityContent(state: state);
  }
}

class _ActivityContent extends StatelessWidget {
  final ActivityDetailState state;

  const _ActivityContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          const Gap(8),
          // ── Summary ──────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              const minCardWidth = 180.0;
              int columns = (constraints.maxWidth / minCardWidth).floor();
              if (columns < 2) columns = 2;
              final cardWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.activity_detail_summary_deposited,
                          ).muted.small,
                          const Gap(4),
                          Text(
                            state.detail!.summary.deposited.toCompactCurrency(
                              context,
                            ),
                          ).bold(color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.activity_detail_summary_spent).muted.small,
                          const Gap(4),
                          Text(
                            state.detail!.summary.spent.toCompactCurrency(
                              context,
                            ),
                          ).bold(color: theme.colorScheme.destructive),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.activity_detail_summary_operating,
                          ).muted.small,
                          const Gap(4),
                          Text(
                            state.detail!.summary.operatingBalance
                                .toCompactCurrency(context),
                          ).bold,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: Card(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.activity_detail_summary_net_balance,
                          ).muted.small,
                          const Gap(4),
                          Text(
                            state.detail!.summary.netBalance.toCompactCurrency(
                              context,
                            ),
                          ).bold(
                            color: state.detail!.summary.netBalance < 0
                                ? theme.colorScheme.destructive
                                : theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          if (state.detail!.summary.budget > 0) ...[
            const Gap(16),
            Card(
              padding: const EdgeInsets.all(16),
              child: BudgetProgress(
                budget: state.detail!.summary.budget,
                fundedAmount: state.detail!.summary.fundedAmount,
                spent: state.detail!.summary.spent,
                formatCurrency: (v) => v.toCompactCurrency(context),
              ),
            ),
          ],

          // ── Categories ───────────────────────
          const Gap(24),
          SectionHeader(
            title: l10n.activity_detail_categories_title,
            actionLabel: l10n.activity_detail_transactions_see_more,
            onAction: () => _openCategoryManagement(context),
          ),
          if (state.detail!.categories.isNotEmpty) ...[
            const Gap(8),
            ...state.detail!.categories.take(3).map((cat) {
              final isActivityLevel = cat.activityId != null;
              return CategoryTile(
                category: cat,
                subtitle: isActivityLevel
                    ? null
                    : l10n.activity_detail_category_project_label,
              );
            }),
          ] else ...[
            const Gap(12),
            EmptyState(
              icon: RadixIcons.bookmark,
              title: l10n.category_mgmt_empty,
              subtitle: l10n.activity_detail_transactions_empty_info,
            ),
          ],

          // ── Transactions ─────────────────────
          const Gap(24),
          SectionHeader(
            title: l10n.activity_detail_transactions_title,
            actionLabel: l10n.activity_detail_transactions_see_more,
            onAction: () => _openTransactionList(context),
          ),
          const Gap(12),

          if (state.detail!.transactions.isEmpty)
            EmptyState(
              icon: RadixIcons.cardStack,
              title: l10n.activity_detail_transactions_empty,
              subtitle: l10n.activity_detail_transactions_empty_info,
            )
          else
            ..._latestTransactions(state.detail!.transactions).map(
              (t) => TransactionTile(
                transaction: t,
                categories: state.detail!.categories,
                onEdit: () => _editTransaction(context, t),
                onDelete: () {
                  context.read<ActivityDetailCubit>().deleteTransaction(t.id);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _openCategoryManagement(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ActivityDetailCubit>();
    await context.appRouter.pushForResult(
      CategoryManagementRoute(
        projectId: cubit.projectId,
        activityId: cubit.activityId,
        title: l10n.category_mgmt_activity_title,
      ),
    );
    if (context.mounted) {
      cubit.load();
    }
  }

  void _openTransactionList(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ActivityDetailCubit>();
    await context.appRouter.pushForResult(
      TransactionListRoute(
        projectId: cubit.projectId,
        activityId: cubit.activityId,
        title: l10n.transaction_list_page_title,
      ),
    );
    if (context.mounted) {
      cubit.load();
    }
  }

  void _editTransaction(BuildContext context, Transaction transaction) async {
    final cubit = context.read<ActivityDetailCubit>();
    final state = cubit.state;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        availableCategories: state.detail!.categories,
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

  List<Transaction> _latestTransactions(List<Transaction> items) {
    final sorted = List<Transaction>.from(items)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(4).toList();
  }
}
