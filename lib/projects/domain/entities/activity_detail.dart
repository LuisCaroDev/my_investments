import 'package:my_investments/projects/domain/entities/activity_summary.dart';
import 'package:my_investments/projects/domain/entities/category.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';

class ActivityDetail {
  final ActivitySummary summary;
  final List<Transaction> transactions;
  final List<Category> categories;

  const ActivityDetail({
    required this.summary,
    required this.transactions,
    required this.categories,
  });
}
