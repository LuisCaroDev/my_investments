import 'package:flutter_test/flutter_test.dart';
import 'package:capitalflow/core/domain/entities/transaction.dart';
import 'package:capitalflow/planning/data/services/planning_funding_calculator.dart';
import 'package:capitalflow/planning/domain/entities/activity.dart';
import 'package:capitalflow/planning/domain/entities/project.dart';

void main() {
  group('PlanningFundingCalculator', () {
    test('builds summaries in cents', () {
      const calculator = PlanningFundingCalculator();
      final project = Project(
        id: 'p1',
        name: 'Project',
        globalBudgetCents: 10000,
        createdAt: DateTime(2026),
      );
      final activity = Activity(
        id: 'a1',
        projectId: 'p1',
        name: 'Activity',
        budgetCents: 6000,
        createdAt: DateTime(2026),
      );
      final transactions = [
        Transaction(
          id: 't1',
          projectId: 'p1',
          activityId: 'a1',
          operationalTaskId: null,
          accountId: 'acc1',
          type: TransactionType.deposit,
          amountCents: 10000,
          date: DateTime(2026),
          description: null,
          createdAt: DateTime(2026),
        ),
        Transaction(
          id: 't2',
          projectId: 'p1',
          activityId: 'a1',
          operationalTaskId: null,
          accountId: 'acc1',
          type: TransactionType.expense,
          amountCents: 2550,
          date: DateTime(2026),
          description: null,
          createdAt: DateTime(2026),
        ),
      ];

      final summaries = calculator.buildProjectSummaries(
        type: ProjectType.investment,
        projects: [project],
        activities: [activity],
        transactions: transactions,
      );

      expect(summaries.single.totalBudgetCents, 10000);
      expect(summaries.single.totalSpentCents, 2550);
      expect(summaries.single.totalDepositedCents, 10000);
      expect(summaries.single.fundedAmountCents, 7450);
      expect(summaries.single.remainingToFundCents, 0);
      expect(summaries.single.netBalanceCents, 7450);
    });
  });
}
