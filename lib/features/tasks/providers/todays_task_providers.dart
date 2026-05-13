// File: lib/features/tasks/providers/todays_task_providers.dart
// Purpose: Riverpod providers for Today's Task list + detail.
// Used by: todays_task_screen.dart, todays_task_detail_screen.dart.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/todays_task_models.dart';
import '../data/todays_task_repository.dart';

final todaysTaskRepositoryProvider =
    Provider<TodaysTaskRepository>((_) => TodaysTaskRepository());

final todaysTaskListProvider = FutureProvider<List<TodayTask>>((ref) {
  return ref.watch(todaysTaskRepositoryProvider).fetchTodayList();
});

final todaysTaskDetailProvider =
    FutureProvider.autoDispose.family<TodayTaskDetail, String>((ref, id) {
  return ref
      .watch(todaysTaskRepositoryProvider)
      .fetchTodayDetail(id: id);
});
