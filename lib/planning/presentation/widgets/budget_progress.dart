import 'package:capitalflow/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class BudgetProgress extends StatelessWidget {
  final int budgetCents;
  final int fundedAmountCents;
  final int spentCents;
  final String Function(int) formatCurrency;
  final String? budgetLabel;
  final String? fundedLabel;
  final String? spentLabel;
  final String? remainingLabel;
  final bool alwaysShowRemaining;

  const BudgetProgress({
    super.key,
    required this.budgetCents,
    required this.fundedAmountCents,
    required this.spentCents,
    required this.formatCurrency,
    this.budgetLabel,
    this.fundedLabel,
    this.spentLabel,
    this.remainingLabel,
    this.alwaysShowRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final sanitizedSpentCents = spentCents < 0 ? 0 : spentCents;
    final sanitizedFundedCents = fundedAmountCents < 0 ? 0 : fundedAmountCents;
    final displayedSpentCents = budgetCents > 0
        ? sanitizedSpentCents.clamp(0, budgetCents)
        : 0;
    final displayedFundedCents = budgetCents > 0
        ? sanitizedFundedCents.clamp(
            0,
            (budgetCents - displayedSpentCents).clamp(0, budgetCents),
          )
        : 0;
    final coveredCents = displayedSpentCents + displayedFundedCents;
    final remainingCents = budgetCents > 0
        ? (budgetCents - coveredCents).clamp(0, budgetCents)
        : 0;
    final coveredProgress = budgetCents > 0
        ? (coveredCents / budgetCents).clamp(0.0, 1.0)
        : 0.0;
    final spentProgress = budgetCents > 0
        ? (displayedSpentCents / budgetCents).clamp(0.0, 1.0)
        : 0.0;
    final fundedProgress = budgetCents > 0
        ? (displayedFundedCents / budgetCents).clamp(0.0, 1.0)
        : 0.0;
    final resolvedBudgetLabel =
        budgetLabel ?? l10n.widget_budget_progress_budget;
    final resolvedSpentLabel = spentLabel ?? l10n.widget_budget_progress_spent;
    final resolvedFundedLabel =
        fundedLabel ?? l10n.widget_budget_progress_funded;
    final resolvedRemainingLabel =
        remainingLabel ?? l10n.widget_budget_progress_remaining;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$resolvedBudgetLabel ${formatCurrency(budgetCents)}',
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
                  decoration: BoxDecoration(color: theme.colorScheme.muted),
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
                    decoration: BoxDecoration(color: theme.colorScheme.primary),
                  ),
                ),
                if (fundedProgress > 0)
                  FractionallySizedBox(
                    widthFactor: coveredProgress,
                    alignment: Alignment.centerLeft,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: fundedProgress / coveredProgress,
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
              '$resolvedSpentLabel ${formatCurrency(sanitizedSpentCents)}',
            ).small(color: theme.colorScheme.destructive),
            Text(
              '$resolvedFundedLabel ${formatCurrency(sanitizedFundedCents)}',
            ).small(color: theme.colorScheme.cardForeground),
            if (budgetCents > 0 || alwaysShowRemaining)
              Text(
                '$resolvedRemainingLabel ${formatCurrency(remainingCents)}',
              ).muted.small,
          ],
        ),
      ],
    );
  }
}
