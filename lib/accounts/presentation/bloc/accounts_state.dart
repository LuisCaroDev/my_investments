import 'package:my_investments/core/domain/entities/financial_account.dart';

sealed class AccountsState {
  const AccountsState();
}

class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

class AccountsLoaded extends AccountsState {
  final List<FinancialAccount> accounts;
  const AccountsLoaded({required this.accounts});
}

class AccountsError extends AccountsState {
  final String message;
  const AccountsError({required this.message});
}
