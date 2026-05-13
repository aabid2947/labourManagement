// File: lib/features/tasks/data/todays_task_models.dart
// Purpose: Typed models for Today's Task list + detail.
// Used by: todays_task_api_service, todays_task_repository, providers, screens.

import 'package:flutter/foundation.dart';

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };
}

TaskPriority _priorityFromString(String? s) {
  return switch (s) {
    'high' => TaskPriority.high,
    'low' => TaskPriority.low,
    'medium' || _ => TaskPriority.medium,
  };
}

@immutable
class TodayTask {
  const TodayTask({
    required this.id,
    required this.title,
    required this.summary,
    required this.priority,
  });
  final String id;
  final String title;
  final String summary;
  final TaskPriority priority;

  factory TodayTask.fromJson(Map<String, dynamic> j) => TodayTask(
        id: j['id'] as String,
        title: j['title'] as String,
        summary: j['summary'] as String,
        priority: _priorityFromString(j['priority'] as String?),
      );
}

@immutable
class TodayTaskDetail {
  const TodayTaskDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.assignedTo,
    required this.site,
    required this.dueAt,
  });

  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final String assignedTo;
  final String site;
  final DateTime dueAt;

  factory TodayTaskDetail.fromJson(Map<String, dynamic> j) => TodayTaskDetail(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        priority: _priorityFromString(j['priority'] as String?),
        assignedTo: j['assignedTo'] as String,
        site: j['site'] as String,
        dueAt: DateTime.parse(j['dueAt'] as String),
      );
}
