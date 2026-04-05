import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/core/widgets/stat_card.dart';
import 'package:my_investments/projects/domain/entities/financial_account.dart';
import 'package:my_investments/projects/domain/entities/project.dart';
import 'package:my_investments/projects/domain/entities/project_summary.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_state.dart';
import 'package:my_investments/projects/presentation/bloc/goals_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/goals_state.dart';
import 'package:my_investments/projects/presentation/bloc/investments_cubit.dart';
import 'package:my_investments/projects/presentation/bloc/investments_state.dart';
import 'package:my_investments/projects/presentation/pages/account_transactions_page.dart';
import 'package:my_investments/projects/presentation/widgets/add_financial_account_dialog.dart';
import 'package:flutter/material.dart'
    show ReorderableDragStartListener, ReorderableListView, WidgetsBinding;

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      headers: [
        AppBar(
          title: Text(l10n.nav_accounts),
          trailing: [
            IconButton.ghost(
              onPressed: () => _showPriorityDialog(context),
              icon: const Icon(RadixIcons.mixerHorizontal),
            ),
          ],
        ),
        Divider(height: 1),
      ],
      floatingFooter: true,
      footers: [
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              onPressed: () => _showAddAccountDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(RadixIcons.plus, size: 16),
                  Gap(6),
                  Text(l10n.common_add), // l10n.accounts_add_button ? fallback to common_add for now
                ],
              ),
            ),
          ),
        ),
      ],
      child: SafeArea(
        top: false,
        bottom: false,
        child: BlocBuilder<AccountsCubit, AccountsState>(
          builder: (context, state) {
            return switch (state) {
              AccountsInitial() || AccountsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AccountsError(message: final msg) => Center(
                child: Text(l10n.common_error_msg(msg)),
              ),
              AccountsLoaded(accounts: final accounts) =>
                accounts.isEmpty
                    ? EmptyState(
                        icon: RadixIcons.cube,
                        title: l10n.accounts_empty,
                        subtitle: l10n.accounts_empty,
                      )
                    : _AccountsList(accounts: accounts),
            };
          },
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => const AddFinancialAccountDialog(),
    );
  }

  void _showPriorityDialog(BuildContext context) async {
    final investmentsCubit = context.read<InvestmentsCubit>();
    final goalsCubit = context.read<GoalsCubit>();
    if (investmentsCubit.state is! InvestmentsLoaded) {
      investmentsCubit.loadInvestments();
    }
    if (goalsCubit.state is! GoalsLoaded) {
      goalsCubit.loadGoals();
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => const _PriorityDialog(),
    );
  }
}

class _PriorityDialog extends StatefulWidget {
  const _PriorityDialog();

  @override
  State<_PriorityDialog> createState() => _PriorityDialogState();
}

class _PriorityDialogState extends State<_PriorityDialog> {
  List<_PriorityItem> _items = const [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<InvestmentsCubit, InvestmentsState>(
      builder: (context, invState) {
        return BlocBuilder<GoalsCubit, GoalsState>(
          builder: (context, goalState) {
            final loaded = invState is InvestmentsLoaded && goalState is GoalsLoaded;
            if (loaded) {
              final nextItems = _buildPriorityItems(
                invState.summaries,
                goalState.summaries,
              );
              if (_items.isEmpty || _items.length != nextItems.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _items = nextItems);
                });
              }
            }

            return AlertDialog(
              title: Text(l10n.dialog_priority_title),
              content: SizedBox(
                width: 440,
                child:
                    !loaded
                        ? const Center(child: CircularProgressIndicator())
                        : _items.isEmpty
                            ? Text(l10n.accounts_empty)
                            : ReorderableListView(
                                buildDefaultDragHandles: false,
                                shrinkWrap: true,
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final item = _items.removeAt(oldIndex);
                                    _items.insert(newIndex, item);
                                  });
                                },
                                children:
                                    [
                                      for (int i = 0; i < _items.length; i++)
                                        Padding(
                                          key: ValueKey(_items[i].id),
                                          padding:  EdgeInsets.only(
                                            bottom: i == _items.length - 1 ? 0 : 8,
                                          ),
                                          child: _PriorityTile(
                                            item: _items[i],
                                            index: i,
                                          ),
                                        ),
                                    ],
                              ),
              ),
              actions: [
                OutlineButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.common_cancel),
                ),
                PrimaryButton(
                  onPressed:
                      _items.isEmpty
                          ? null
                          : () async {
                              final ids = _items.map((e) => e.id).toList();
                              final accountsCubit = context.read<AccountsCubit>();
                              final investmentsCubit =
                                  context.read<InvestmentsCubit>();
                              final goalsCubit = context.read<GoalsCubit>();
                              final navigator = Navigator.of(context);
                              await accountsCubit.reorderProjectPriorities(ids);
                              if (!context.mounted) return;
                              investmentsCubit.loadInvestments();
                              goalsCubit.loadGoals();
                              navigator.pop();
                            },
                  child: Text(l10n.common_save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<_PriorityItem> _buildPriorityItems(
    List<ProjectSummary> investments,
    List<ProjectSummary> goals,
  ) {
    final items = [
      ...investments.map(
        (s) => _PriorityItem(
          id: s.project.id,
          name: s.project.name,
          type: ProjectType.investment,
          priority: s.project.priority,
        ),
      ),
      ...goals.map(
        (s) => _PriorityItem(
          id: s.project.id,
          name: s.project.name,
          type: ProjectType.savingsGoal,
          priority: s.project.priority,
        ),
      ),
    ];
    items.sort((a, b) => a.priority.compareTo(b.priority));
    return items;
  }
}

class _PriorityItem {
  final String id;
  final String name;
  final ProjectType type;
  final int priority;

  const _PriorityItem({
    required this.id,
    required this.name,
    required this.type,
    required this.priority,
  });
}

class _PriorityTile extends StatelessWidget {
  final _PriorityItem item;
  final int index;

  const _PriorityTile({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeLabel =
        item.type == ProjectType.investment
            ? l10n.nav_investments
            : l10n.nav_goals;

    return Card(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Icon(RadixIcons.dragHandleDots2, size: 16),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name).medium,
                Text(typeLabel).muted.small,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountsList extends StatelessWidget {
  final List<FinancialAccount> accounts;

  const _AccountsList({required this.accounts});

  @override
  Widget build(BuildContext context) {
    final totalBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
          // ── Summary ─────────────────
          LayoutBuilder(
            builder: (context, constraints) {

              const spacing = 12.0;
              const minCardWidth = 200.0;
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
                    child: StatCard(
                      label: l10n.project_detail_summary_net_balance, // generic "Balance"
                      value: totalBalance.toCompactCurrency(context),
                      icon: RadixIcons.barChart,
                      valueColor: totalBalance < 0
                          ? Theme.of(context).colorScheme.destructive
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              );
            },
          ),
          const Gap(24),

          // ── Accounts Grid ────────────────────
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: accounts
                .map(
                  (a) => SizedBox(width: 340, child: _AccountCard(account: a)),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final FinancialAccount account;

  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardButton(
      onPressed: () => _openTransactions(context),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name).medium,
                    ],
                  ),
                ),
                IconButton.ghost(
                  onPressed: () => _showActionsMenu(context),
                  icon: const Icon(RadixIcons.dotsVertical, size: 16),
                ),
              ],
            ),
            const Gap(16),
            Text('Balance').muted.small,
            Text(account.balance.toCompactCurrency(context)).semiBold(
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _openTransactions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountTransactionsPage(account: account),
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
            onPressed: (_) {
              showDialog<void>(
                context: context,
                builder: (ctx) =>
                    AddFinancialAccountDialog(initialAccount: account),
              );
            },
          ),
        ],
      ),
    );
  }
}
