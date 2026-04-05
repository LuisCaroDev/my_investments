import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class BudgetProgress extends StatelessWidget {
  final double budget;
  final double fundedAmount;
  final double spent;
  final String Function(num) formatCurrency;

  const BudgetProgress({
    super.key,
    required this.budget,
    required this.fundedAmount,
    required this.spent,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final fundingProgress = budget > 0 ? (fundedAmount / budget).clamp(0.0, 1.0) : 0.0;
    final spentProgress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${l10n.widget_budget_progress_budget} ${formatCurrency(budget)}').muted.small,
            Text('${(fundingProgress * 100).toStringAsFixed(0)}%').muted.small,
          ],
        ),
        const Gap(6),
        SizedBox(
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Funded (primary color)
                FractionallySizedBox(
                  widthFactor: fundingProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Spent overlay (darker)
                FractionallySizedBox(
                  widthFactor: spentProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.widget_budget_progress_funded} ${formatCurrency(fundedAmount)}')
                .small(color: theme.colorScheme.primary),
            Text('${l10n.widget_budget_progress_spent} ${formatCurrency(spent)}')
                .small(color: theme.colorScheme.destructive),
            if (budget > 0)
              Text('${l10n.widget_budget_progress_remaining} ${formatCurrency(budget - fundedAmount)}')
                  .muted.small,
          ],
        ),
      ],
    );
  }
}
