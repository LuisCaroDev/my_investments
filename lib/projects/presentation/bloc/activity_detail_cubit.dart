import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_investments/projects/data/repositories/projects_repository_impl.dart';
import 'package:my_investments/projects/domain/entities/transaction.dart';
import 'package:my_investments/projects/presentation/bloc/activity_detail_state.dart';
import 'package:my_investments/projects/domain/entities/category.dart'
    as domain;

class ActivityDetailCubit extends Cubit<ActivityDetailState> {
  final ProjectsRepository _repository;
  final String projectId;
  final String activityId;

  ActivityDetailCubit({
    required ProjectsRepository repository,
    required this.projectId,
    required this.activityId,
  }) : _repository = repository,
       super(const ActivityDetailState());

  void load() {
    try {
      final detail = _repository.getActivityDetail(projectId, activityId);
      emit(ActivityDetailState(loading: false, detail: detail));
    } catch (e) {
      emit(ActivityDetailState(loading: false, error: e.toString()));
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    load();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _repository.deleteTransaction(transactionId);
    load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
    load();
  }

  Future<void> addCategory(domain.Category category) async {
    await _repository.addCategory(category);
    load();
  }

  Future<void> updateCategory(domain.Category category) async {
    await _repository.updateCategory(category);
    load();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    load();
  }
}
