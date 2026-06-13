import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:capitalflow/accounts/data/repositories/accounts_repository.dart';
import 'package:capitalflow/accounts/data/datasources/accounts_local_ds.dart';
import 'package:capitalflow/core/domain/entities/financial_account.dart';
import 'package:capitalflow/accounts/presentation/bloc/accounts_state.dart';
import 'package:capitalflow/planning/data/repositories/project_repository.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final AccountsRepository _repository;
  final AccountsLocalDataSource _localDataSource;
  final ProjectRepository _projectRepository;
  StreamSubscription? _subscription;

  AccountsCubit({
    required AccountsRepository repository,
    required AccountsLocalDataSource localDataSource,
    required ProjectRepository projectRepository,
  }) : _repository = repository,
       _localDataSource = localDataSource,
       _projectRepository = projectRepository,
       super(const AccountsInitial()) {
    _subscription = _localDataSource.accountsStream.listen((models) {
      emit(AccountsLoaded(accounts: models));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

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
  }

  Future<void> updateAccount(FinancialAccount account) async {
    await _repository.updateAccount(account);
  }

  Future<void> deleteAccount(String accountId) async {
    await _repository.deleteAccount(accountId);
  }

  Future<void> addAccountDeposit({
    required String accountId,
    required int amountCents,
    String? description,
  }) async {
    await _repository.addAccountDeposit(
      accountId: accountId,
      amountCents: amountCents,
      description: description,
    );
  }

  Future<void> reorderProjectPriorities(List<String> orderedIds) async {
    await _projectRepository.reorderProjects(orderedIds);
  }
}
