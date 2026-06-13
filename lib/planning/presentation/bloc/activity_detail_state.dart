import 'package:capitalflow/planning/domain/entities/activity_detail.dart';

class ActivityDetailState {
  final bool loading;
  final String? error;
  final ActivityDetail? detail;

  const ActivityDetailState({this.loading = true, this.error, this.detail});
}
