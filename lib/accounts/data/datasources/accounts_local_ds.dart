import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_investments/accounts/data/models/transaction_model.dart';
import 'package:my_investments/accounts/data/models/financial_account_model.dart';

class AccountsLocalDataSource {
  static const _transactionsKey = 'transactions';
  static const _financialAccountsKey = 'financial_accounts';

  final SharedPreferences _prefs;

  const AccountsLocalDataSource({required SharedPreferences prefs})
      : _prefs = prefs;

  // ── Transactions ──────────────────────────────────────────

  List<TransactionModel> getTransactions() {
    final data = _prefs.getString(_transactionsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final data = jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString(_transactionsKey, data);
  }

  // ── Financial Accounts ────────────────────────────────────

  bool hasFinancialAccounts() {
    return _prefs.containsKey(_financialAccountsKey);
  }

  List<FinancialAccountModel> getFinancialAccounts() {
    final data = _prefs.getString(_financialAccountsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => FinancialAccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFinancialAccounts(List<FinancialAccountModel> accounts) async {
    final data = jsonEncode(accounts.map((e) => e.toJson()).toList());
    await _prefs.setString(_financialAccountsKey, data);
  }
}
