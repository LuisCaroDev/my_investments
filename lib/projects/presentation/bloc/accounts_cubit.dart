import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/financial_account.dart';
import 'package:my_investments/projects/presentation/bloc/accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final ProjectsRepository _repository;

  AccountsCubit({required ProjectsRepository repository})
    : _repository = repository,
      super(const AccountsInitial());

  void loadAccounts() {
    emit(const AccountsLoading());
    try {
      final accounts = _repository.getAccounts();
      emit(AccountsLoaded(accounts: accounts));
    } catch (e) {
      emit(AccountsError(message: e.toString()));
    }
  }

  Future<void> addAccount(FinancialAccount account) async {
    await _repository.addAccount(account);
    loadAccounts();
  }

  Future<void> updateAccount(FinancialAccount account) async {
    await _repository.updateAccount(account);
    loadAccounts();
  }

  Future<void> deleteAccount(String accountId) async {
    await _repository.deleteAccount(accountId);
    loadAccounts();
  }

  Future<void> addAccountDeposit({
    required String accountId,
    required double amount,
    String? description,
  }) async {
    await _repository.addAccountDeposit(
      accountId: accountId,
      amount: amount,
      description: description,
    );
    loadAccounts();
  }

  Future<void> reorderProjectPriorities(List<String> orderedIds) async {
    await _repository.reorderProjects(orderedIds);
  }
}
