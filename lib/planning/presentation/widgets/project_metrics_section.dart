import 'package:capitalflow/l10n/app_localizations.dart';
import 'package:capitalflow/planning/domain/entities/project_detail.dart';
import 'package:capitalflow/core/extensions/currency_ext.dart';
import 'package:capitalflow/core/widgets/stat_card.dart';
import 'package:capitalflow/planning/presentation/widgets/budget_progress.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class InvestmentMetricsSection extends StatelessWidget {
  final ProjectDetail detail;

  const InvestmentMetricsSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricsGrid(
          children: [
            StatCard(
              label: l10n.project_detail_summary_deposited,
              value: detail.totalDeposited.toCompactCurrency(context),
              icon: RadixIcons.arrowUp,
              valueColor: theme.colorScheme.primary,
            ),
            StatCard(
              label: l10n.project_detail_summary_spent,
              value: detail.totalSpent.toCompactCurrency(context),
              icon: RadixIcons.arrowDown,
              valueColor: theme.colorScheme.destructive,
            ),
            StatCard(
              label: l10n.project_detail_summary_net_balance,
              value: detail.netBalance.toCompactCurrency(context),
              icon: RadixIcons.barChart,
              valueColor: detail.netBalance < 0
                  ? theme.colorScheme.destructive
                  : theme.colorScheme.primary,
            ),
            StatCard(
              label: l10n.project_detail_summary_budget,
              value: detail.totalBudget.toCompactCurrency(context),
              icon: RadixIcons.target,
            ),
          ],
        ),
        if (detail.totalBudget > 0) ...[
          const Gap(16),
          Card(
            padding: const EdgeInsets.all(16),
            child: BudgetProgress(
              budget: detail.totalBudget,
              fundedAmount: detail.fundedAmount,
              spent: detail.totalSpent,
              formatCurrency: (v) => v.toCompactCurrency(context),
            ),
          ),
        ],
      ],
    );
  }
}

class GoalMetricsSection extends StatelessWidget {
  final ProjectDetail detail;

  const GoalMetricsSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricsGrid(
          children: [
            StatCard(
              label: l10n.goal_detail_summary_saved,
              value: detail.fundedAmount.toCompactCurrency(context),
              icon: RadixIcons.archive,
              valueColor: theme.colorScheme.primary,
            ),
            StatCard(
              label: l10n.goal_detail_summary_spent,
              value: detail.totalSpent.toCompactCurrency(context),
              icon: RadixIcons.arrowDown,
              valueColor: theme.colorScheme.destructive,
            ),
            StatCard(
              label: l10n.goal_detail_summary_target,
              value: detail.totalBudget.toCompactCurrency(context),
              icon: RadixIcons.target,
            ),
            StatCard(
              label: l10n.goal_detail_summary_missing,
              value: detail.remainingToFund.toCompactCurrency(context),
              icon: RadixIcons.backpack,
            ),
          ],
        ),
        if (detail.totalBudget > 0) ...[
          const Gap(16),
          Card(
            padding: const EdgeInsets.all(16),
            child: BudgetProgress(
              budget: detail.totalBudget,
              fundedAmount: detail.fundedAmount,
              spent: detail.totalSpent,
              formatCurrency: (v) => v.toCompactCurrency(context),
              budgetLabel: l10n.widget_goal_progress_target,
              fundedLabel: l10n.widget_goal_progress_saved,
              spentLabel: l10n.widget_goal_progress_spent,
              remainingLabel: l10n.widget_goal_progress_missing,
              alwaysShowRemaining: true,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<Widget> children;

  const _MetricsGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
          children: children
              .map((child) => SizedBox(width: cardWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
