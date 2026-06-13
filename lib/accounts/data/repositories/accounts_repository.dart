import 'dart:async';

import 'package:capitalflow/core/constants/ledger.dart';
import 'package:capitalflow/core/domain/repositories/transactions_reader.dart';
import 'package:capitalflow/accounts/data/datasources/accounts_local_ds.dart';
import 'package:capitalflow/accounts/data/models/financial_account_model.dart';
import 'package:capitalflow/accounts/data/models/transaction_model.dart';
import 'package:capitalflow/accounts/domain/entities/financial_account.dart';
import 'package:capitalflow/accounts/domain/entities/transaction.dart';
import 'package:capitalflow/core/storage/sync_change_recorder.dart';
import 'package:capitalflow/core/domain/jobs/transaction_projection_job.dart';

class AccountsRepository implements TransactionsReader {
  final AccountsLocalDataSource _localDataSource;
  final SyncChangeRecorder? _changeRecorder;
  final TransactionProjectionJob _projectionJob;

  const AccountsRepository({
    required AccountsLocalDataSource localDataSource,
    required TransactionProjectionJob projectionJob,
    SyncChangeRecorder? changeRecorder,
  }) : _localDataSource = localDataSource,
       _projectionJob = projectionJob,
       _changeRecorder = changeRecorder;

  // ── Financial Accounts ────────────────────────────────────

  List<FinancialAccount> getAccounts() {
    return _localDataSource.getFinancialAccounts();
  }

  Future<void> addAccount(FinancialAccount account) async {
    final initialDepositCents = account.balanceCents > 0
        ? account.balanceCents
        : 0;
    final accounts = _localDataSource.getFinancialAccounts();
    accounts.add(
      FinancialAccountModel.fromEntity(account.copyWith(balanceCents: 0)),
    );
    await _localDataSource.saveFinancialAccounts(accounts);
    await _changeRecorder?.recordChange(
      entity: 'accounts',
      op: SyncChangeOp.add,
      id: account.id,
      payload: FinancialAccountModel.fromEntity(
        account.copyWith(balanceCents: 0),
      ).toJson(),
    );
    if (initialDepositCents > 0) {
      await addTransaction(
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          projectId: systemAccountProjectId,
          activityId: null,
          operationalTaskId: null,
          accountId: account.id,
          type: TransactionType.deposit,
          amountCents: initialDepositCents,
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
        account.copyWith(balanceCents: current.balanceCents),
      );
      await _localDataSource.saveFinancialAccounts(accounts);
      await _changeRecorder?.recordChange(
        entity: 'accounts',
        op: SyncChangeOp.update,
        id: account.id,
        payload: accounts[index].toJson(),
      );
    }
  }

  Future<void> deleteAccount(String accountId) async {
    final accounts = _localDataSource.getFinancialAccounts();
    accounts.removeWhere((a) => a.id == accountId);
    await _localDataSource.saveFinancialAccounts(accounts);
    await _changeRecorder?.recordChange(
      entity: 'accounts',
      op: SyncChangeOp.delete,
      id: accountId,
    );
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
    await _changeRecorder?.recordChange(
      entity: 'transactions',
      op: SyncChangeOp.add,
      id: transaction.id,
      payload: TransactionModel.fromEntity(transaction).toJson(),
    );
    unawaited(_projectionJob.run());
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final transactions = _localDataSource.getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = TransactionModel.fromEntity(transaction);
      await _localDataSource.saveTransactions(transactions);
      await _changeRecorder?.recordChange(
        entity: 'transactions',
        op: SyncChangeOp.update,
        id: transaction.id,
        payload: transactions[index].toJson(),
      );
      unawaited(_projectionJob.run());
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    final transactions = _localDataSource.getTransactions();
    transactions.removeWhere((t) => t.id == transactionId);
    await _localDataSource.saveTransactions(transactions);
    await _changeRecorder?.recordChange(
      entity: 'transactions',
      op: SyncChangeOp.delete,
      id: transactionId,
    );
    unawaited(_projectionJob.run());
  }

  Future<void> deleteTransactionsForProject(String projectId) async {
    final transactions = _localDataSource.getTransactions();
    final removed = transactions
        .where((t) => t.projectId == projectId)
        .toList();
    transactions.removeWhere((t) => t.projectId == projectId);
    await _localDataSource.saveTransactions(transactions);
    for (final tx in removed) {
      await _changeRecorder?.recordChange(
        entity: 'transactions',
        op: SyncChangeOp.delete,
        id: tx.id,
      );
    }
    unawaited(_projectionJob.run());
  }

  Future<void> deleteTransactionsForActivity(String activityId) async {
    final transactions = _localDataSource.getTransactions();
    final removed = transactions
        .where((t) => t.activityId == activityId)
        .toList();
    transactions.removeWhere((t) => t.activityId == activityId);
    await _localDataSource.saveTransactions(transactions);
    for (final tx in removed) {
      await _changeRecorder?.recordChange(
        entity: 'transactions',
        op: SyncChangeOp.delete,
        id: tx.id,
      );
    }
    unawaited(_projectionJob.run());
  }

  Future<void> addAccountDeposit({
    required String accountId,
    required int amountCents,
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
        amountCents: amountCents,
        date: date ?? DateTime.now(),
        description: description,
        createdAt: DateTime.now(),
      ),
    );
  }
}
