// File: lib/features/tasks/data/task_models.dart
// Purpose: Typed models for Task v/s Achievements rows + details + remark payload.
// Used by: task_api_service, task_repository, providers, screens.

import 'package:flutter/foundation.dart';

enum TaskCompletion { partial, full }

extension TaskCompletionX on TaskCompletion {
  String get apiValue => switch (this) {
        TaskCompletion.partial => 'partial',
        TaskCompletion.full => 'full',
      };
  String get label => switch (this) {
        TaskCompletion.partial => 'Partial Completed',
        TaskCompletion.full => 'Fully Completed',
      };
}

/// Server-side enum-ish; left as String for forward compatibility.
class TaskStatus {
  static const String pending = 'Task Pending';
  static const String partialCompleted = 'Partial Completed';
  static const String fullyCompleted = 'Fully Completed';
}

@immutable
class TaskAchievement {
  const TaskAchievement({
    required this.id,
    required this.title,
    required this.assignedDate,
    required this.dueDate,
    required this.agingDays,
    required this.status,
  });

  final String id;
  final String title;
  final DateTime assignedDate;
  final DateTime dueDate;
  /// Positive = overdue (e.g. "2D" red); 0 or negative = "On Time".
  final int agingDays;
  final String status;

  factory TaskAchievement.fromJson(Map<String, dynamic> j) => TaskAchievement(
        id: j['id'] as String,
        title: j['title'] as String,
        assignedDate: DateTime.parse(j['assignedDate'] as String),
        dueDate: DateTime.parse(j['dueDate'] as String),
        agingDays: (j['agingDays'] as num).toInt(),
        status: j['status'] as String,
      );
}

@immutable
class TaskDetail {
  const TaskDetail({
    required this.id,
    required this.title,
    required this.description,
  });
  final String id;
  final String title;
  final String description;

  factory TaskDetail.fromJson(Map<String, dynamic> j) => TaskDetail(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
      );
}
