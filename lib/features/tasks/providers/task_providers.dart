// File: lib/features/tasks/providers/task_providers.dart
// Purpose: Riverpod providers for Task v/s Achievements date range, list, and detail.
// Used by: task_vs_achievements_screen, task_detail_screen, task_remark_screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task_models.dart';
import '../data/task_repository.dart';

final taskRepositoryProvider =
    Provider<TaskRepository>((_) => TaskRepository());

class TaskRange {
  const TaskRange(this.from, this.to);
  final DateTime from;
  final DateTime to;

  TaskRange copyWith({DateTime? from, DateTime? to}) =>
      TaskRange(from ?? this.from, to ?? this.to);
}

class TaskRangeController extends Notifier<TaskRange> {
  @override
  TaskRange build() {
    // Default to the current week — From = today-7, To = today.
    final now = DateTime.now();
    return TaskRange(now.subtract(const Duration(days: 7)), now);
  }

  void setFrom(DateTime d) => state = state.copyWith(from: d);
  void setTo(DateTime d) => state = state.copyWith(to: d);
}

/// IMPORTANT: this provider is intentionally NOT autoDispose. The Task v/s
/// Achievements brief says the date filter must be preserved when the user
/// pops back from a sub-screen (Task Details, Remarks).
final taskRangeProvider =
    NotifierProvider<TaskRangeController, TaskRange>(TaskRangeController.new);

final taskListProvider =
    FutureProvider.autoDispose<List<TaskAchievement>>((ref) {
  final r = ref.watch(taskRangeProvider);
  return ref.watch(taskRepositoryProvider).fetchTasks(from: r.from, to: r.to);
});

final taskDetailProvider =
    FutureProvider.autoDispose.family<TaskDetail, String>((ref, id) {
  return ref.watch(taskRepositoryProvider).fetchTask(id: id);
});
