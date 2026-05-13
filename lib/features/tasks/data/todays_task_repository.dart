// File: lib/features/tasks/data/todays_task_repository.dart
// Purpose: Domain wrapper for TodaysTaskApiService — typed Today's Task models.
// Used by: features/tasks/providers/todays_task_providers.dart.

import 'todays_task_api_service.dart';
import 'todays_task_models.dart';

class TodaysTaskRepository {
  TodaysTaskRepository({TodaysTaskApiService? api})
      : _api = api ?? TodaysTaskApiService();
  final TodaysTaskApiService _api;

  Future<List<TodayTask>> fetchTodayList() async {
    final list = await _api.fetchTodayList();
    return list.map(TodayTask.fromJson).toList(growable: false);
  }

  Future<TodayTaskDetail> fetchTodayDetail({required String id}) async {
    final j = await _api.fetchTodayDetail(id: id);
    return TodayTaskDetail.fromJson(j);
  }
}
