// File: lib/features/dashboard/data/dashboard_api_service.dart
// Purpose: Network calls for the dashboard — sites, summary metrics, my expense. Stubs only.
// Used by: features/dashboard/data/dashboard_repository.dart.

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class DashboardApiService {
  DashboardApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): GET /sites — response: [{id, name}]
  Future<List<Map<String, dynamic>>> fetchSites() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      {'id': 'alpha', 'name': 'Project Alpha'},
      {'id': 'beta', 'name': 'Project Beta'},
      {'id': 'gamma', 'name': 'Project Gamma'},
    ];
    // Real: return (await _dio.get('/sites')).data as List<Map<String, dynamic>>;
  }

  // TODO(api): GET /dashboard/summary?siteId= — response:
  //   {totalLabour: int, todayAttendance: {present: int, total: int},
  //    taskVsAchievements: {achieved: int, target: int}}
  Future<Map<String, dynamic>> fetchSummary({required String siteId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const {
      'totalLabour': 48,
      'todayAttendance': {'present': 45, 'total': 55},
      'taskVsAchievements': {'achieved': 17, 'target': 20},
    };
  }

  // TODO(api): GET /dashboard/my-expense?siteId= — response:
  //   {advance: number, currency: string, total: number}
  Future<Map<String, dynamic>> fetchMyExpense({required String siteId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const {
      'advance': 12000,
      'currency': 'INR',
      'total': 13000,
    };
  }

  // ignore: unused_element
  Dio get _client => _dio;
}
