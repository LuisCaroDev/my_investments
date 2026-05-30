import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:my_investments/planning/presentation/pages/operational_task_management_page.dart';
import 'package:my_investments/accounts/presentation/pages/transaction_list_page.dart';
import 'package:my_investments/planning/presentation/pages/activity_detail_page.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/data/repositories/activity_repository.dart';
import 'package:my_investments/planning/data/repositories/project_repository.dart';
import 'package:my_investments/planning/data/repositories/operational_task_repository.dart';
import 'package:my_investments/planning/data/services/planning_detail_query_service.dart';
import 'package:my_investments/planning/data/datasources/planning_local_ds.dart';
import 'package:my_investments/planning/domain/entities/activity.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/planning/domain/entities/activity_summary.dart';
import 'package:my_investments/core/domain/entities/financial_account.dart';
import 'package:my_investments/planning/presentation/bloc/project_detail_cubit.dart';
import 'package:my_investments/planning/presentation/bloc/project_detail_state.dart';
import 'package:my_investments/accounts/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/accounts/presentation/bloc/accounts_state.dart';
import 'package:my_investments/planning/presentation/bloc/goals_cubit.dart';
import 'package:my_investments/planning/presentation/bloc/investments_cubit.dart';
import 'package:my_investments/planning/presentation/widgets/add_activity_dialog.dart';
import 'package:my_investments/accounts/presentation/widgets/add_transaction_dialog.dart';
import 'package:my_investments/planning/presentation/widgets/budget_progress.dart';
import 'package:my_investments/planning/presentation/widgets/project_metrics_section.dart';
import 'package:my_investments/planning/presentation/widgets/preview_section.dart';
import 'package:my_investments/planning/presentation/widgets/section_header.dart';
import 'package:my_investments/accounts/presentation/widgets/transaction_tile.dart';
import 'package:my_investments/planning/presentation/widgets/operational_task_tile.dart';
import 'package:my_investments/planning/presentation/widgets/suggested_budget_banner.dart';

List<FinancialAccount> _getAccountsFromContext(BuildContext context) {
  final state = context.read<AccountsCubit>().state;
  if (state is AccountsLoaded) return state.accounts;
  return const [];
}

void _refreshPlanningSummaries(BuildContext context) {
  context.read<AccountsCubit>().loadAccounts();
  context.read<InvestmentsCubit>().loadInvestments();
  context.read<GoalsCubit>().loadGoals();
}

class ProjectDetailPage extends StatelessWidget {
  static const routePattern = '/projects/:projectId';

  static String routeOf({
    required String projectId,
    required String projectName,
  }) => '/projects/$projectId?name=${Uri.encodeComponent(projectName)}';

  final String projectId;
  final String projectName;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    final accountsRepo = context.read<AccountsRepository>();
    final detailQueryService = context.read<PlanningDetailQueryService>();
    final activityRepository = context.read<ActivityRepository>();
    final projectRepository = context.read<ProjectRepository>();
    final operationalTaskRepository = context.read<OperationalTaskRepository>();
    final planningLocalDataSource = context.read<PlanningLocalDataSource>();
    return BlocProvider(
      create: (_) => ProjectDetailCubit(
        detailQueryService: detailQueryService,
        activityRepository: activityRepository,
        projectRepository: projectRepository,
        operationalTaskRepository: operationalTaskRepository,
        accountsRepository: accountsRepo,
        planningLocalDataSource: planningLocalDataSource,
        projectId: projectId,
      )..load(),
      child: _ProjectDetailView(projectName: projectName),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  final String projectName;

  const _ProjectDetailView({required this.projectName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
      builder: (context, state) {
        final footers = switch (state) {
          ProjectDetailLoaded() => [
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
          ],
          _ => const <Widget>[],
        };

        return Scaffold(
          headers: [
            AppBar(
              leading: [...AppBackButton.render(context)],
              title: Text(projectName),
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

  void _addTransaction(BuildContext context) async {
    final cubit = context.read<ProjectDetailCubit>();
    final state = cubit.state;
    if (state is! ProjectDetailLoaded) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        availableCategories: state.detail.projectCategories,
        availableAccounts: _getAccountsFromContext(context),
      ),
    );

    if (result != null && context.mounted) {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: cubit.projectId,
        accountId: result['accountId'] as String? ?? 'initial_statement',
        type: result['type'] as TransactionType,
        amount: result['amount'] as double,
        date: result['date'] as DateTime,
        description: result['description'] as String?,
        operationalTaskId: result['operationalTaskId'] as String?,
        createdAt: DateTime.now(),
      );
      await cubit.addTransaction(transaction);
      if (context.mounted) {
        _refreshPlanningSummaries(context);
      }
    }
  }

  Widget _buildBody(BuildContext context, ProjectDetailState state) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      bottom: false,
      child: switch (state) {
        ProjectDetailLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        ProjectDetailError(message: final msg) => Center(
          child: Text(l10n.common_error_msg(msg)),
        ),
        ProjectDetailLoaded() => _ProjectDetailContent(state: state),
      },
    );
  }
}

class _ProjectDetailContent extends StatelessWidget {
  final ProjectDetailLoaded state;

  const _ProjectDetailContent({required this.state});

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
          if (state.detail.project.type == ProjectType.savingsGoal)
            GoalMetricsSection(detail: state.detail)
          else
            InvestmentMetricsSection(detail: state.detail),

          if (!state.detail.project.autoUpdateBudget &&
              state.detail.suggestedBudget >
                  (state.detail.project.globalBudget ?? 0)) ...[
            const Gap(24),
            SuggestedBudgetBanner(
              suggestedBudget: state.detail.suggestedBudget,
              onUpdate: () {
                final updated = state.detail.project.copyWith(
                  globalBudget: state.detail.suggestedBudget,
                );
                context.read<ProjectDetailCubit>().updateProject(updated);
              },
            ),
          ],

          // ── Categories ───────────────────────
          const Gap(24),
          PreviewSection(
            title: l10n.project_detail_categories_title,
            items: state.detail.projectCategories,
            actionLabel: l10n.project_detail_transactions_see_more,
            onAction: () => _openCategoryManagement(context),
            previewCount: 3,
            spacing: 8,
            emptyIcon: RadixIcons.bookmark,
            emptyTitle: l10n.category_mgmt_empty,
            emptySubtitle: l10n.project_detail_transactions_empty_info,
            itemBuilder: (_, cat) => OperationalTaskTile(task: cat),
          ),

          // ── Project-Level Transactions ───────
          const Gap(24),
          Builder(
            builder: (context) {
              final balance = state.detail.projectLevelBalance;

              return PreviewSection(
                title: l10n.project_detail_transactions_title,
                items: state.detail.projectLevelTransactions,
                actionLabel: l10n.project_detail_transactions_see_more,
                onAction: () => _openTransactionList(context),
                previewCount: 3,
                spacing: 8,
                emptyIcon: RadixIcons.cardStack,
                emptyTitle: l10n.project_detail_transactions_empty,
                emptySubtitle: l10n.project_detail_transactions_empty_info,
                headerBottom: balance != 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.project_detail_summary_net_balance,
                            ).medium,
                            Text(balance.toCompactCurrency(context)).medium(
                              color: balance >= 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.destructive,
                            ),
                          ],
                        ),
                      )
                    : null,
                transformItems: _latestTransactions,
                itemBuilder: (_, t) => TransactionTile(
                  transaction: t,
                  operationalTasks: state.detail.projectCategories,
                  onEdit: () => _editTransaction(context, t),
                  onDelete: () async {
                    await context.read<ProjectDetailCubit>().deleteTransaction(
                      t.id,
                    );
                    if (context.mounted) {
                      _refreshPlanningSummaries(context);
                    }
                  },
                ),
              );
            },
          ),

          // ── Activities ───────────────────────
          const Gap(24),
          SectionHeader(
            title: l10n.project_detail_activities_title,
            trailing: IconButton.outline(
              onPressed: () => _addActivity(context),
              icon: const Icon(RadixIcons.plus, size: 16),
            ),
          ),
          const Gap(8),
          if (state.detail.activitySummaries.isEmpty)
            EmptyState(
              icon: RadixIcons.layers,
              title: l10n.project_detail_activities_empty,
              subtitle: l10n.project_detail_activities_empty_info,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 16.0;
                const minCardWidth = 300.0;
                int columns = (constraints.maxWidth / minCardWidth).floor();
                final cardWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                    columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: state.detail.activitySummaries
                      .map(
                        (s) => SizedBox(
                          width: cardWidth,
                          child: _ActivityCard(
                            summary: s,
                            onEdit: () => _editActivity(context, s.activity),
                            onDelete: () =>
                                _confirmDeleteActivity(context, s.activity),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openCategoryManagement(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProjectDetailCubit>();
    await context.push(
      OperationalTaskManagementPage.routeOf(
        projectId: cubit.projectId,
        title: l10n.category_mgmt_project_title,
      ),
    );
    if (context.mounted) {
      cubit.load();
    }
  }

  void _openTransactionList(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProjectDetailCubit>();
    await context.push(
      TransactionListPage.routeOf(
        projectId: cubit.projectId,
        title: l10n.transaction_list_page_title,
      ),
    );
    if (context.mounted) {
      cubit.load();
    }
  }

  void _editTransaction(BuildContext context, Transaction transaction) async {
    final state = context.read<ProjectDetailCubit>().state;
    if (state is! ProjectDetailLoaded) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        availableCategories: state.detail.projectCategories,
        availableAccounts: _getAccountsFromContext(context),
        initialTransaction: transaction,
      ),
    );
    if (result != null && context.mounted) {
      final cubit = context.read<ProjectDetailCubit>();
      final updated = transaction.copyWith(
        type: result['type'] as TransactionType,
        accountId: result['accountId'] as String? ?? transaction.accountId,
        amount: result['amount'] as double,
        date: result['date'] as DateTime,
        description: result['description'] as String?,
        operationalTaskId: result['operationalTaskId'] as String?,
      );
      await cubit.updateTransaction(updated);
      if (context.mounted) {
        _refreshPlanningSummaries(context);
      }
    }
  }

  List<Transaction> _latestTransactions(List<Transaction> items) {
    final sorted = List<Transaction>.from(items)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(4).toList();
  }

  void _addActivity(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const AddActivityDialog(),
    );
    if (result != null && context.mounted) {
      final cubit = context.read<ProjectDetailCubit>();
      final activity = Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: cubit.projectId,
        name: result['name'] as String,
        description: result['description'] as String?,
        year: result['year'] as int?,
        budget: result['budget'] as double?,
        createdAt: DateTime.now(),
      );
      cubit.addActivity(activity);
    }
  }

  void _editActivity(BuildContext context, Activity activity) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddActivityDialog(
        initialName: activity.name,
        initialDescription: activity.description,
        initialYear: activity.year,
        initialBudget: activity.budget,
      ),
    );
    if (result != null && context.mounted) {
      final cubit = context.read<ProjectDetailCubit>();
      final updated = activity.copyWith(
        name: result['name'] as String,
        description: result['description'] as String?,
        year: result['year'] as int?,
        budget: result['budget'] as double?,
      );
      cubit.updateActivity(updated);
    }
  }

  void _confirmDeleteActivity(BuildContext context, Activity activity) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialog_activity_delete_title),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.dialog_activity_delete_confirmation).small,
              const Gap(8),
              TextField(
                controller: controller,
                placeholder: Text(activity.name),
              ),
            ],
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.common_cancel),
          ),
          PrimaryButton(
            onPressed: () {
              if (controller.text.trim() != activity.name.trim()) return;
              Navigator.of(ctx).pop();
              context.read<ProjectDetailCubit>().deleteActivity(activity.id);
            },
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivitySummary summary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.summary,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProjectDetailCubit>();

    return CardButton(
      onPressed: () async {
        await context.push(
          ActivityDetailPage.routeOf(
            projectId: cubit.projectId,
            activityId: summary.activity.id,
            activityName: summary.activity.name,
          ),
        );
        if (context.mounted) {
          cubit.load();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  RadixIcons.layers,
                  size: 16,
                  color: theme.colorScheme.secondaryForeground,
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.activity.name).medium,
                    if (summary.activity.year != null)
                      Text(
                        l10n.project_detail_activity_year(
                          summary.activity.year!,
                        ),
                      ).muted.small,
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SecondaryBadge(
                    child: Text(
                      l10n.project_detail_activity_transaction_count(
                        summary.transactionCount,
                      ),
                    ),
                  ),
                  const Gap(4),
                  IconButton.ghost(
                    onPressed: () => _showActionsMenu(context),
                    icon: const Icon(RadixIcons.dotsVertical, size: 16),
                  ),
                ],
              ),
            ],
          ),
          const Gap(12),
          if (summary.budget > 0)
            BudgetProgress(
              budget: summary.budget,
              fundedAmount: summary.fundedAmount,
              spent: summary.spent,
              formatCurrency: (v) => v.toCompactCurrency(context),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.project_detail_summary_deposited}: ${summary.deposited.toCompactCurrency(context)}',
                ).small(color: theme.colorScheme.primary),
                Text(
                  '${l10n.project_detail_summary_spent}: ${summary.spent.toCompactCurrency(context)}',
                ).small(color: theme.colorScheme.destructive),
              ],
            ),
        ],
      ),
    );
  }

  void _showActionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDropdown<void>(
      context: context,
      anchorAlignment: Alignment.bottomRight,
      alignment: Alignment.topRight,
      builder: (ctx) => DropdownMenu(
        children: [
          MenuButton(
            leading: const Icon(RadixIcons.pencil1),
            child: Text(l10n.common_edit),
            onPressed: (_) => onEdit(),
          ),
          MenuButton(
            leading: const Icon(RadixIcons.trash),
            child: Text(l10n.common_delete),
            onPressed: (_) => onDelete(),
          ),
        ],
      ),
    );
  }
}
