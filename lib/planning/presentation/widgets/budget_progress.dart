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
    final spentAmount = spent < 0 ? 0.0 : spent;
    final allocatedAmount = fundedAmount < 0 ? 0.0 : fundedAmount;
    final displayedSpentAmount = budget > 0
        ? spentAmount.clamp(0.0, budget)
        : 0.0;
    final displayedAllocatedAmount = budget > 0
        ? allocatedAmount.clamp(
            0.0,
            (budget - displayedSpentAmount).clamp(0.0, budget),
          )
        : 0.0;
    final coveredAmount = displayedSpentAmount + displayedAllocatedAmount;
    final remainingAmount = budget > 0
        ? (budget - coveredAmount).clamp(0.0, budget)
        : 0.0;
    final coveredProgress = budget > 0
        ? (coveredAmount / budget).clamp(0.0, 1.0)
        : 0.0;
    final spentProgress = budget > 0
        ? (displayedSpentAmount / budget).clamp(0.0, 1.0)
        : 0.0;
    final allocatedProgress = budget > 0
        ? (displayedAllocatedAmount / budget).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.widget_budget_progress_budget} ${formatCurrency(budget)}',
            ).muted.small,
            Text('${(coveredProgress * 100).toStringAsFixed(0)}%').muted.small,
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
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: coveredProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.cardForeground.withLuminance(.9),
                      // borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Spent area
                FractionallySizedBox(
                  widthFactor: spentProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (allocatedProgress > 0)
                  FractionallySizedBox(
                    widthFactor: coveredProgress,
                    alignment: Alignment.centerLeft,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: allocatedProgress / coveredProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
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
            Text(
              '${l10n.widget_budget_progress_spent} ${formatCurrency(spentAmount)}',
            ).small(color: theme.colorScheme.destructive),
            Text(
              '${l10n.widget_budget_progress_funded} ${formatCurrency(allocatedAmount)}',
            ).small(color: theme.colorScheme.cardForeground),
            if (budget > 0)
              Text(
                '${l10n.widget_budget_progress_remaining} ${formatCurrency(remainingAmount)}',
              ).muted.small,
          ],
        ),
      ],
    );
  }
}
