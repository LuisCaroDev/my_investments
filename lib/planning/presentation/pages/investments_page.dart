import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:my_investments/core/extensions/currency_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:my_investments/planning/presentation/pages/project_detail_page.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/core/widgets/stat_card.dart';
import 'package:my_investments/planning/domain/entities/project.dart';
import 'package:my_investments/planning/domain/entities/project_summary.dart';
import 'package:my_investments/planning/presentation/bloc/investments_cubit.dart';
import 'package:my_investments/planning/presentation/bloc/investments_state.dart';
import 'package:my_investments/planning/presentation/widgets/add_project_dialog.dart';
import 'package:my_investments/planning/presentation/widgets/budget_progress.dart';

class InvestmentsPage extends StatelessWidget {
  static const route = '/investments';

  const InvestmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      headers: [
        AppBar(title: Text(l10n.nav_investments)),
        Divider(height: 1),
      ],
      floatingFooter: true,
      footers: [
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              onPressed: () => _showAddProjectDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(RadixIcons.plus, size: 16),
                  Gap(6),
                  Text(l10n.projects_add_button),
                ],
              ),
            ),
          ),
        ),
      ],
      child: SafeArea(
        top: false,
        bottom: false,
        child: BlocBuilder<InvestmentsCubit, InvestmentsState>(
          builder: (context, state) {
            return switch (state) {
              InvestmentsInitial() || InvestmentsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              InvestmentsError(message: final msg) => Center(
                child: Text(l10n.common_error_msg(msg)),
              ),
              InvestmentsLoaded(summaries: final summaries) =>
                summaries.isEmpty
                    ? EmptyState(
                        icon: RadixIcons.archive,
                        title: l10n.projects_empty_title,
                        subtitle: l10n.projects_empty_subtitle,
                      )
                    : _ProjectsList(summaries: summaries),
            };
          },
        ),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const AddProjectDialog(),
    );
    if (result != null && context.mounted) {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result['name'] as String,
        description: result['description'] as String?,
        globalBudget: result['budget'] as double?,
        createdAt: DateTime.now(),
      );
      context.read<InvestmentsCubit>().addInvestment(project);
    }
  }
}

class _ProjectsList extends StatelessWidget {
  final List<ProjectSummary> summaries;

  const _ProjectsList({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Calculate portfolio totals
    final totalBudget = summaries.fold(0.0, (sum, s) => sum + s.totalBudget);
    final totalSpent = summaries.fold(0.0, (sum, s) => sum + s.totalSpent);
    final totalDeposited = summaries.fold(
      0.0,
      (sum, s) => sum + s.totalDeposited,
    );
    final totalFundedAmount = summaries.fold(
      0.0,
      (sum, s) => sum + s.fundedAmount,
    );
    final totalNetBalance = summaries.fold(0.0, (sum, s) => sum + s.netBalance);

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
          // ── Portfolio Summary ─────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final l10n = AppLocalizations.of(context)!;
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
                      label: l10n.projects_summary_deposited,
                      value: totalDeposited.toCompactCurrency(context),
                      icon: RadixIcons.download,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: l10n.projects_summary_spent,
                      value: totalSpent.toCompactCurrency(context),
                      icon: RadixIcons.minusCircled,
                      valueColor: Theme.of(context).colorScheme.destructive,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: l10n.projects_summary_budget,
                      value: totalBudget.toCompactCurrency(context),
                      icon: RadixIcons.target,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: l10n.projects_summary_funded,
                      value: totalFundedAmount.toCompactCurrency(context),
                      icon: RadixIcons.drawingPinSolid,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: l10n.projects_summary_net_balance,
                      value: totalNetBalance.toCompactCurrency(context),
                      icon: RadixIcons.barChart,
                      valueColor: totalNetBalance < 0
                          ? Theme.of(context).colorScheme.destructive
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      label: l10n.projects_list_title,
                      value: summaries.length.toString(),
                      icon: RadixIcons.cube,
                    ),
                  ),
                ],
              );
            },
          ),
          const Gap(24),

          // ── Projects Grid ────────────────────
          Text(l10n.projects_list_title).large.bold,
          const Gap(12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: summaries
                .map(
                  (s) => SizedBox(width: 340, child: _ProjectCard(summary: s)),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectSummary summary;

  const _ProjectCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CardButton(
      onPressed: () {
        context.push(
          ProjectDetailPage.routeOf(
            projectId: summary.project.id,
            projectName: summary.project.name,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  RadixIcons.cube,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.project.name).medium,
                    if (summary.project.description != null)
                      OverflowMarquee(
                        child: Text(summary.project.description!).muted.small,
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SecondaryBadge(
                    child: Text(
                      l10n.projects_item_activity_count(summary.activityCount),
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
          const Gap(16),
          if (summary.totalBudget > 0)
            BudgetProgress(
              budget: summary.totalBudget,
              fundedAmount: summary.fundedAmount,
              spent: summary.totalSpent,
              formatCurrency: (v) => v.toCompactCurrency(context),
            ),
          if (summary.totalBudget == 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.projects_summary_deposited).muted.small,
                    Text(
                      summary.totalDeposited.toCompactCurrency(context),
                    ).semiBold(color: theme.colorScheme.primary),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l10n.projects_summary_spent).muted.small,
                    Text(
                      summary.totalSpent.toCompactCurrency(context),
                    ).semiBold(color: theme.colorScheme.muted),
                  ],
                ),
              ],
            ),
          ],
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
            onPressed: (_) => _editProject(context),
          ),
          MenuButton(
            leading: const Icon(RadixIcons.trash),
            child: Text(l10n.common_delete),
            onPressed: (_) => _confirmDeleteProject(context),
          ),
        ],
      ),
    );
  }

  void _editProject(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddProjectDialog(
        initialName: summary.project.name,
        initialDescription: summary.project.description,
        initialBudget: summary.project.globalBudget,
      ),
    );
    if (result != null && context.mounted) {
      final updated = summary.project.copyWith(
        name: result['name'] as String,
        description: result['description'] as String?,
        globalBudget: result['budget'] as double?,
      );
      context.read<InvestmentsCubit>().updateInvestment(updated);
    }
  }

  void _confirmDeleteProject(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.projects_delete_title),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.projects_delete_confirmation).small,
              const Gap(8),
              TextField(
                controller: controller,
                placeholder: Text(summary.project.name),
              ),
            ],
          ),
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.common_cancel),
          ),
          PrimaryButton(
            onPressed: () {
              if (controller.text.trim() != summary.project.name.trim()) return;
              Navigator.of(ctx).pop(true);
            },
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<InvestmentsCubit>().deleteInvestment(summary.project.id);
    }
  }
}
