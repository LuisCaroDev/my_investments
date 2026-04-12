import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/core/storage/sync_snapshot_provider.dart';
import 'package:my_investments/core/storage/profile_keys.dart';
import 'package:my_investments/accounts/data/models/transaction_model.dart';
import 'package:my_investments/accounts/data/models/financial_account_model.dart';

class AccountsLocalDataSource implements SyncSnapshotProvider {
  static const _transactionsKey = 'transactions';
  static const _financialAccountsKey = 'financial_accounts';

  final SharedPreferences _prefs;
  final String _profileId;

  const AccountsLocalDataSource({
    required SharedPreferences prefs,
    required String profileId,
  })  : _prefs = prefs,
        _profileId = profileId;

  String _key(String key) => profileKey(_profileId, key);

  // ── Transactions ──────────────────────────────────────────

  List<TransactionModel> getTransactions() {
    final data = _prefs.getString(_key(_transactionsKey));
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final data = jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString(_key(_transactionsKey), data);
  }

  // ── Financial Accounts ────────────────────────────────────

  bool hasFinancialAccounts() {
    return _prefs.containsKey(_key(_financialAccountsKey));
  }

  List<FinancialAccountModel> getFinancialAccounts() {
    final data = _prefs.getString(_key(_financialAccountsKey));
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => FinancialAccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFinancialAccounts(List<FinancialAccountModel> accounts) async {
    final data = jsonEncode(accounts.map((e) => e.toJson()).toList());
    await _prefs.setString(_key(_financialAccountsKey), data);
  }

  @override
  Map<String, List<Map<String, dynamic>>> exportSnapshot() {
    return {
      'transactions': getTransactions().map((e) => e.toJson()).toList(),
      'accounts': getFinancialAccounts().map((e) => e.toJson()).toList(),
    };
  }

  @override
  Future<void> importSnapshot(
    Map<String, List<Map<String, dynamic>>> data,
  ) async {
    final transactions = (data['transactions'] ?? [])
        .map((e) => TransactionModel.fromJson(e))
        .toList();
    final accounts = (data['accounts'] ?? [])
        .map((e) => FinancialAccountModel.fromJson(e))
        .toList();

    await saveTransactions(transactions);
    await saveFinancialAccounts(accounts);
  }
}
