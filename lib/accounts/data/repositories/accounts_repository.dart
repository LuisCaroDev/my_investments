import 'package:my_investments/core/constants/ledger.dart';
import 'package:my_investments/core/domain/repositories/transactions_reader.dart';
import 'package:my_investments/accounts/data/datasources/accounts_local_ds.dart';
import 'package:my_investments/accounts/data/models/financial_account_model.dart';
import 'package:my_investments/accounts/data/models/transaction_model.dart';
import 'package:my_investments/accounts/domain/entities/financial_account.dart';
import 'package:my_investments/accounts/domain/entities/transaction.dart';

class AccountsRepository implements TransactionsReader {
  final AccountsLocalDataSource _localDataSource;

  const AccountsRepository({required AccountsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  // ── Financial Accounts ────────────────────────────────────

  List<FinancialAccount> getAccounts() {
    final accounts = _localDataSource.getFinancialAccounts();
    final transactions = _localDataSource.getTransactions();
    return _withComputedBalances(accounts, transactions);
  }

  Future<void> addAccount(FinancialAccount account) async {
    final initialDeposit = account.balance > 0 ? account.balance : 0.0;
    final accounts = _localDataSource.getFinancialAccounts();
    accounts.add(
      FinancialAccountModel.fromEntity(account.copyWith(balance: 0)),
    );
    await _localDataSource.saveFinancialAccounts(accounts);
    if (initialDeposit > 0) {
      await addTransaction(
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          projectId: systemAccountProjectId,
          activityId: null,
          operationalTaskId: null,
          accountId: account.id,
          type: TransactionType.deposit,
          amount: initialDeposit,
          date: DateTime.now(),
          description: 'Initial balance',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateAccount(FinancialAccount account) async {
    final accounts = _localDataSource.getFinancialAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      final current = accounts[index];
      accounts[index] = FinancialAccountModel.fromEntity(
        account.copyWith(balance: current.balance),
      );
      await _localDataSource.saveFinancialAccounts(accounts);
    }
  }

  Future<void> deleteAccount(String accountId) async {
    final accounts = _localDataSource.getFinancialAccounts();
    accounts.removeWhere((a) => a.id == accountId);
    await _localDataSource.saveFinancialAccounts(accounts);
  }

  // ── Transactions ──────────────────────────────────────────

  List<Transaction> getTransactionsForProject(String projectId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.projectId == projectId)
        .toList();
  }

  @override
  List<Transaction> getAllTransactions() {
    return _localDataSource.getTransactions();
  }

  List<Transaction> getTransactionsForAccount(String accountId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.accountId == accountId)
        .toList();
  }

  List<Transaction> getTransactionsForActivity(String activityId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.activityId == activityId)
        .toList();
  }

  List<Transaction> getProjectLevelTransactions(String projectId) {
    return _localDataSource
        .getTransactions()
        .where((t) => t.projectId == projectId && t.activityId == null)
        .toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = _localDataSource.getTransactions();
    transactions.add(TransactionModel.fromEntity(transaction));
    await _localDataSource.saveTransactions(transactions);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final transactions = _localDataSource.getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = TransactionModel.fromEntity(transaction);
      await _localDataSource.saveTransactions(transactions);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    final transactions = _localDataSource.getTransactions();
    transactions.removeWhere((t) => t.id == transactionId);
    await _localDataSource.saveTransactions(transactions);
  }

  Future<void> deleteTransactionsForProject(String projectId) async {
    final transactions = _localDataSource.getTransactions();
    transactions.removeWhere((t) => t.projectId == projectId);
    await _localDataSource.saveTransactions(transactions);
  }

  Future<void> deleteTransactionsForActivity(String activityId) async {
    final transactions = _localDataSource.getTransactions();
    transactions.removeWhere((t) => t.activityId == activityId);
    await _localDataSource.saveTransactions(transactions);
  }

  Future<void> addAccountDeposit({
    required String accountId,
    required double amount,
    String? description,
    DateTime? date,
  }) async {
    await addTransaction(
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: systemAccountProjectId,
        activityId: null,
        operationalTaskId: null,
        accountId: accountId,
        type: TransactionType.deposit,
        amount: amount,
        date: date ?? DateTime.now(),
        description: description,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<FinancialAccount> _withComputedBalances(
    List<FinancialAccount> accounts,
    List<Transaction> transactions,
  ) {
    final totals = <String, double>{};
    for (final transaction in transactions) {
      final delta = transaction.type == TransactionType.deposit
          ? transaction.amount
          : -transaction.amount;
      totals.update(
        transaction.accountId,
        (value) => value + delta,
        ifAbsent: () => delta,
      );
    }

    return accounts
        .map(
          (account) => account.copyWith(
            balance: totals[account.id] ?? 0.0,
          ),
        )
        .toList();
  }
}
