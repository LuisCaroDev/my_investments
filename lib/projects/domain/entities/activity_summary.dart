import 'package:my_investments/projects/domain/entities/activity.dart';
import 'package:my_investments/projects/domain/entities/category.dart';

class ActivitySummary {
  final Activity activity;
  final double spent;
  final double deposited;
  final double capitalInjected;
  final List<Category> categories;
  final int transactionCount;

  const ActivitySummary({
    required this.activity,
    required this.spent,
    required this.deposited,
    required this.capitalInjected,
    required this.categories,
    required this.transactionCount,
  });

  double get budget => activity.budget ?? 0;
  double get operatingBalance => deposited - spent;
  double get netBalance => operatingBalance + capitalInjected;
  double get remainingBudget => budget - deposited;
  double get budgetProgress =>
      budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
}
