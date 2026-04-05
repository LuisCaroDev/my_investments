import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/projects/data/datasources/projects_local_ds.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/financial_account.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/domain/entities/category.dart' as domain;
import 'package:my_investments/projects/presentation/widgets/transaction_tile.dart';

class AccountTransactionsPage extends StatelessWidget {
  final FinancialAccount account;

  const AccountTransactionsPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ds = ProjectsLocalDataSource(prefs: snapshot.data!);
        final repo = ProjectsRepository(localDataSource: ds);

        final transactions = repo.getTransactionsForAccount(account.id);
        final categories = repo.getAllCategories();

        return _AccountTransactionsView(
          account: account,
          transactions: transactions,
          categories: categories,
        );
      },
    );
  }
}

class _AccountTransactionsView extends StatelessWidget {
  final FinancialAccount account;
  final List<Transaction> transactions;
  final List<domain.Category> categories;

  const _AccountTransactionsView({
    required this.account,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            ...AppBackButton.render(context),
          ],
          title: Text(account.name),
        ),
        Divider(height: 1),
      ],
      child: SafeArea(
        top: false,
        bottom: false,
        child: sorted.isEmpty
            ? Center(
                child: EmptyState(
                  icon: RadixIcons.calendar,
                  title: l10n.transaction_list_empty,
                  subtitle: l10n.transaction_list_empty_filter,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:
                      sorted
                          .map(
                            (t) => TransactionTile(
                              transaction: t,
                              categories: categories,
                            ),
                          )
                          .toList(),
                ),
              ),
      ),
    );
  }
}
