// File: lib/features/dashboard/data/dashboard_repository.dart
// Purpose: Domain wrapper for DashboardApiService — typed models for the UI.
// Used by: features/dashboard/providers/dashboard_providers.dart.

import 'dashboard_api_service.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  DashboardRepository({DashboardApiService? api})
      : _api = api ?? DashboardApiService();
  final DashboardApiService _api;

  Future<List<Site>> fetchSites() async {
    final list = await _api.fetchSites();
    return list.map(Site.fromJson).toList(growable: false);
  }

  Future<DashboardSummary> fetchSummary({required String siteId}) async {
    final j = await _api.fetchSummary(siteId: siteId);
    final att = j['todayAttendance'] as Map<String, dynamic>;
    final task = j['taskVsAchievements'] as Map<String, dynamic>;
    return DashboardSummary(
      totalLabour: j['totalLabour'] as int,
      attendancePresent: att['present'] as int,
      attendanceTotal: att['total'] as int,
      taskAchieved: task['achieved'] as int,
      taskTarget: task['target'] as int,
    );
  }

  Future<MyExpense> fetchMyExpense({required String siteId}) async {
    final j = await _api.fetchMyExpense(siteId: siteId);
    return MyExpense(
      advance: j['advance'] as num,
      total: j['total'] as num,
      currency: j['currency'] as String,
    );
  }
}
