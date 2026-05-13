// File: lib/features/dashboard/data/dashboard_models.dart
// Purpose: Typed models for the dashboard payloads.
// Used by: dashboard_repository.dart, dashboard_screen.dart.

class Site {
  const Site({required this.id, required this.name});
  final String id;
  final String name;
  factory Site.fromJson(Map<String, dynamic> j) =>
      Site(id: j['id'] as String, name: j['name'] as String);
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalLabour,
    required this.attendancePresent,
    required this.attendanceTotal,
    required this.taskAchieved,
    required this.taskTarget,
  });
  final int totalLabour;
  final int attendancePresent;
  final int attendanceTotal;
  final int taskAchieved;
  final int taskTarget;
}

class MyExpense {
  const MyExpense({
    required this.advance,
    required this.total,
    required this.currency,
  });
  final num advance;
  final num total;
  final String currency;
}
