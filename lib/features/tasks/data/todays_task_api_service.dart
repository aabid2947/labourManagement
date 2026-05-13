// File: lib/features/tasks/data/todays_task_api_service.dart
// Purpose: Network stubs for the Today's Task list + per-task details.
// Used by: features/tasks/data/todays_task_repository.dart.

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class TodaysTaskApiService {
  TodaysTaskApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): GET /tasks/today — response: [{id, title, summary, priority}]
  Future<List<Map<String, dynamic>>> fetchTodayList() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      {
        'id': 'tt-1',
        'title': 'Site Safety Inspection',
        'summary': 'Check all safety equipment and report issues',
        'priority': 'high',
      },
      {
        'id': 'tt-2',
        'title': 'Labour Attendance Verification',
        'summary': "Verify today's labour attendance on site",
        'priority': 'medium',
      },
      {
        'id': 'tt-3',
        'title': 'Material Quality Check',
        'summary': 'Check quality of delivered materials',
        'priority': 'medium',
      },
      {
        'id': 'tt-4',
        'title': 'Work Progress Review',
        'summary': "Review today's work progress with the team",
        'priority': 'medium',
      },
      {
        'id': 'tt-5',
        'title': 'Site Photo Update',
        'summary': 'Capture and upload site photos',
        'priority': 'low',
      },
      {
        'id': 'tt-6',
        'title': 'Daily Report Submission',
        'summary': 'Submit daily work report before EOD',
        'priority': 'high',
      },
    ];
    // Real: return ((await _dio.get('/tasks/today')).data as List)
    //     .cast<Map<String, dynamic>>();
  }

  // TODO(api): GET /tasks/today/{id} — response: {full task}
  Future<Map<String, dynamic>> fetchTodayDetail({required String id}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final descriptions = <String, String>{
      'tt-1':
          'Walk every active zone on site, confirm PPE compliance, signage, '
              'and equipment safety. File issues with photo evidence where applicable.',
      'tt-2':
          'Reconcile in-app attendance against floor headcount, flag mismatches '
              'with the contractor before noon.',
      'tt-3':
          'Spot-check incoming material batches for spec compliance. Document '
              'serial numbers, attach sample QC photos, and reject non-conforming items.',
      'tt-4':
          'Hold a 10-minute stand-up with each crew lead to confirm achievements '
              "against today's milestones; capture blockers for the daily report.",
      'tt-5':
          'Capture progress photos for every active zone (wide + close-up). '
              'Upload via the in-app camera flow with zone + timestamp metadata.',
      'tt-6':
          "Compile today's manpower, materials, and progress numbers into the "
              'daily report and submit before EOD.',
    };
    return {
      'id': id,
      'title': const {
        'tt-1': 'Site Safety Inspection',
        'tt-2': 'Labour Attendance Verification',
        'tt-3': 'Material Quality Check',
        'tt-4': 'Work Progress Review',
        'tt-5': 'Site Photo Update',
        'tt-6': 'Daily Report Submission',
      }[id] ?? 'Task',
      'description': descriptions[id] ?? 'Detailed task description from API.',
      'priority': const {
        'tt-1': 'high',
        'tt-2': 'medium',
        'tt-3': 'medium',
        'tt-4': 'medium',
        'tt-5': 'low',
        'tt-6': 'high',
      }[id] ?? 'medium',
      'assignedTo': 'You',
      'site': 'Project Alpha • Mumbai Metro',
      'dueAt': DateTime.now()
          .copyWith(hour: 18, minute: 0, second: 0)
          .toIso8601String(),
    };
  }

  // ignore: unused_element
  Dio get _client => _dio;
}
