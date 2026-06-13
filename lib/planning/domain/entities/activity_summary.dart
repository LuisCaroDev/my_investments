import 'dart:math' as math;

import 'package:capitalflow/planning/domain/entities/activity.dart';
import 'package:capitalflow/planning/domain/entities/operational_task.dart';

class ActivitySummary {
  final Activity activity;
  final double spent;
  final double deposited;
  final double fundedAmount;
  final List<OperationalTask> categories;
  final int transactionCount;

  const ActivitySummary({
    required this.activity,
    required this.spent,
    required this.deposited,
    required this.fundedAmount,
    required this.categories,
    required this.transactionCount,
  });

  double get suggestedBudget => math.max(activity.budget ?? 0.0, spent);
  double get budget =>
      activity.autoUpdateBudget ? suggestedBudget : (activity.budget ?? 0.0);
  double get operatingBalance => deposited - spent;
  // Activities only care about their operating balance now
  double get netBalance => operatingBalance;
  double get remainingBudget => budget - deposited;
  double get budgetProgress =>
      budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
}
