import 'dart:math' as math;

import 'package:capitalflow/planning/domain/entities/activity.dart';
import 'package:capitalflow/planning/domain/entities/operational_task.dart';

class ActivitySummary {
  final Activity activity;
  final int spentCents;
  final int depositedCents;
  final int fundedAmountCents;
  final List<OperationalTask> categories;
  final int transactionCount;

  const ActivitySummary({
    required this.activity,
    required this.spentCents,
    required this.depositedCents,
    required this.fundedAmountCents,
    required this.categories,
    required this.transactionCount,
  });

  int get suggestedBudgetCents =>
      math.max(activity.budgetCents ?? 0, spentCents);
  int get budgetCents => activity.autoUpdateBudget
      ? suggestedBudgetCents
      : (activity.budgetCents ?? 0);
  int get operatingBalanceCents => depositedCents - spentCents;
  // Activities only care about their operating balance now
  int get netBalanceCents => operatingBalanceCents;
  int get remainingBudgetCents => budgetCents - depositedCents;
  double get budgetProgress =>
      budgetCents > 0 ? (spentCents / budgetCents).clamp(0.0, 1.0) : 0.0;
}
