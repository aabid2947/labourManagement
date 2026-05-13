// File: lib/features/tasks/data/task_repository.dart
// Purpose: Domain wrapper for TaskApiService — typed models for the UI.
// Used by: features/tasks/providers/task_providers.dart.

import 'task_api_service.dart';
import 'task_models.dart';

class TaskRepository {
  TaskRepository({TaskApiService? api}) : _api = api ?? TaskApiService();
  final TaskApiService _api;

  Future<List<TaskAchievement>> fetchTasks({
    required DateTime from,
    required DateTime to,
  }) async {
    final list = await _api.fetchTasks(from: from, to: to);
    return list.map(TaskAchievement.fromJson).toList(growable: false);
  }

  Future<TaskDetail> fetchTask({required String id}) async {
    final j = await _api.fetchTask(id: id);
    return TaskDetail.fromJson(j);
  }

  Future<bool> submitRemark({
    required String id,
    required String remark,
    required TaskCompletion completion,
    required List<String> imagesB64,
  }) =>
      _api.submitRemark(
        id: id,
        remark: remark,
        completion: completion.apiValue,
        imagesB64: imagesB64,
      );
}
