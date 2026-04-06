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
import 'package:my_investments/projects/presentation/widgets/add_account_deposit_dialog.dart';
import 'package:my_investments/projects/presentation/widgets/transaction_tile.dart';

class AccountTransactionsPage extends StatefulWidget {
  final FinancialAccount account;

  const AccountTransactionsPage({super.key, required this.account});

  @override
  State<AccountTransactionsPage> createState() =>
      _AccountTransactionsPageState();
}

class _AccountTransactionsPageState extends State<AccountTransactionsPage> {
  late final Future<ProjectsRepository> _repoFuture =
      SharedPreferences.getInstance().then(
        (prefs) => ProjectsRepository(
          localDataSource: ProjectsLocalDataSource(prefs: prefs),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProjectsRepository>(
      future: _repoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final repo = snapshot.data!;

        final transactions = repo.getTransactionsForAccount(widget.account.id);
        final categories = repo.getAllCategories();

        return _AccountTransactionsView(
          account: widget.account,
          transactions: transactions,
          categories: categories,
          repository: repo,
          onChanged: () => setState(() {}),
        );
      },
    );
  }
}

class _AccountTransactionsView extends StatelessWidget {
  final FinancialAccount account;
  final List<Transaction> transactions;
  final List<domain.Category> categories;
  final ProjectsRepository repository;
  final VoidCallback onChanged;

  const _AccountTransactionsView({
    required this.account,
    required this.transactions,
    required this.categories,
    required this.repository,
    required this.onChanged,
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
                          .map((t) {
                            final isAccountDeposit =
                                t.projectId ==
                                    ProjectsRepository.systemAccountProjectId &&
                                t.type == TransactionType.deposit;
                            return TransactionTile(
                              transaction: t,
                              categories: categories,
                              onEdit: isAccountDeposit
                                  ? () => _editAccountDeposit(context, t)
                                  : null,
                              onDelete: isAccountDeposit
                                  ? () => _deleteTransaction(context, t)
                                  : null,
                              showActionsOnTap: isAccountDeposit,
                            );
                          })
                          .toList(),
                ),
              ),
      ),
    );
  }

  Future<void> _editAccountDeposit(
    BuildContext context,
    Transaction transaction,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddAccountDepositDialog(
        initialAmount: transaction.amount,
        initialDescription: transaction.description,
      ),
    );
    if (result == null) return;
    await repository.updateTransaction(
      transaction.copyWith(
        amount: result['amount'] as double,
        description: result['description'] as String?,
      ),
    );
    onChanged();
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    await repository.deleteTransaction(transaction.id);
    onChanged();
  }
}
