import 'package:my_investments/accounts/presentation/bloc/accounts_cubit.dart';
import 'package:my_investments/l10n/app_localizations.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:my_investments/core/widgets/app_back_button.dart';
import 'package:my_investments/core/widgets/empty_state.dart';
import 'package:my_investments/core/constants/ledger.dart';
import 'package:my_investments/accounts/data/repositories/accounts_repository.dart';
import 'package:my_investments/planning/data/repositories/planning_repository.dart';
import 'package:my_investments/core/domain/entities/financial_account.dart';
import 'package:my_investments/core/domain/entities/transaction.dart';
import 'package:my_investments/planning/domain/entities/operational_task.dart'
    as domain;
import 'package:my_investments/accounts/presentation/widgets/add_account_deposit_dialog.dart';
import 'package:my_investments/accounts/presentation/widgets/transaction_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_investments/accounts/presentation/bloc/accounts_state.dart';

class AccountTransactionsPage extends StatefulWidget {
  static const routePattern = '/accounts/:accountId';

  static String routeOf(String accountId) => '/accounts/$accountId';

  final String accountId;

  const AccountTransactionsPage({super.key, required this.accountId});

  @override
  State<AccountTransactionsPage> createState() =>
      _AccountTransactionsPageState();
}

class _AccountTransactionsPageState extends State<AccountTransactionsPage> {
  @override
  Widget build(BuildContext context) {
    final accountsState = context.read<AccountsCubit>().state;
    final FinancialAccount? account = accountsState is AccountsLoaded
        ? accountsState.accounts.firstWhere((a) => a.id == widget.accountId)
        : null;

    if (account == null) {
      return const Scaffold(child: Center(child: CircularProgressIndicator()));
    }

    final accountsRepository = context.read<AccountsRepository>();
    final planningRepository = context.read<PlanningRepository>();
    final transactions = accountsRepository.getTransactionsForAccount(
      account.id,
    );
    final operationalTasks = planningRepository.getAllOperationalTasks();

    return _AccountTransactionsView(
      account: account,
      transactions: transactions,
      operationalTasks: operationalTasks,
      accountsRepository: accountsRepository,
      onChanged: () => setState(() {}),
    );
  }
}

class _AccountTransactionsView extends StatelessWidget {
  final FinancialAccount account;
  final List<Transaction> transactions;
  final List<domain.OperationalTask> operationalTasks;
  final AccountsRepository accountsRepository;
  final VoidCallback onChanged;

  const _AccountTransactionsView({
    required this.account,
    required this.transactions,
    required this.operationalTasks,
    required this.accountsRepository,
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
          leading: [...AppBackButton.render(context)],
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
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: sorted.map((t) {
                    final isAccountDeposit =
                        t.projectId == systemAccountProjectId &&
                        t.type == TransactionType.deposit;
                    return TransactionTile(
                      transaction: t,
                      operationalTasks: operationalTasks,
                      onEdit: isAccountDeposit
                          ? () => _editAccountDeposit(context, t)
                          : null,
                      onDelete: isAccountDeposit
                          ? () => _deleteTransaction(context, t)
                          : null,
                      showActionsOnTap: isAccountDeposit,
                    );
                  }).toList(),
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
    await accountsRepository.updateTransaction(
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
    await accountsRepository.deleteTransaction(transaction.id);
    onChanged();
  }
}
