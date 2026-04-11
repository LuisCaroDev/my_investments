import 'package:my_investments/planning/domain/entities/activity_summary.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';

class ActivityDetail {
  final ActivitySummary summary;
  final List<Transaction> transactions;
  final List<OperationalTask> categories;

  const ActivityDetail({
    required this.summary,
    required this.transactions,
    required this.categories,
  });
}
