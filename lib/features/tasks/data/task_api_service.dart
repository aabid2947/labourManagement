// File: lib/features/tasks/data/task_api_service.dart
// Purpose: Network stubs for Task v/s Achievements + detail + remark submission.
// Used by: features/tasks/data/task_repository.dart.

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class TaskApiService {
  TaskApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): GET /tasks?from=&to= —
  //   response: [{id, title, assignedDate, dueDate, agingDays, status}]
  Future<List<Map<String, dynamic>>> fetchTasks({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    // Deterministic mock — backend dev replaces with real query.
    final base = DateTime(from.year, from.month, from.day);
    String d(int offset) =>
        base.add(Duration(days: offset)).toIso8601String();
    return [
      {
        'id': 't-1',
        'title': 'Site Safety Inspection',
        'assignedDate': d(0),
        'dueDate': d(2),
        'agingDays': 2,
        'status': 'Task Pending',
      },
      {
        'id': 't-2',
        'title': 'Labour Attendance Verification',
        'assignedDate': d(0),
        'dueDate': d(1),
        'agingDays': 1,
        'status': 'Partial Completed',
      },
      {
        'id': 't-3',
        'title': 'Material Quality Check',
        'assignedDate': d(0),
        'dueDate': d(0),
        'agingDays': 0,
        'status': 'Task Pending',
      },
      {
        'id': 't-4',
        'title': 'Work Progress Review',
        'assignedDate': d(0),
        'dueDate': d(0),
        'agingDays': 0,
        'status': 'Partial Completed',
      },
      {
        'id': 't-5',
        'title': 'Site Photo Update',
        'assignedDate': d(0),
        'dueDate': d(1),
        'agingDays': 1,
        'status': 'Task Pending',
      },
      {
        'id': 't-6',
        'title': 'Daily Report Submission',
        'assignedDate': d(0),
        'dueDate': d(3),
        'agingDays': 3,
        'status': 'Task Pending',
      },
    ];
    // Real:
    // final res = await _dio.get('/tasks', queryParameters: {
    //   'from': from.toIso8601String(),
    //   'to': to.toIso8601String(),
    // });
    // return (res.data as List).cast<Map<String, dynamic>>();
  }

  // TODO(api): GET /tasks/{id} — response: {id, title, description, ...}
  Future<Map<String, dynamic>> fetchTask({required String id}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    const descriptions = <String, String>{
      't-1': 'Inspect the site area for safety compliance including '
          'equipment, signage, and worker adherence to safety protocols.',
      't-2': 'Verify attendance records against floor headcount and flag '
          'any discrepancies for the contractor.',
      't-3': 'Spot-check material batches for spec compliance, document '
          'serial numbers and run a sample QC.',
      't-4': 'Walk the active work zones and confirm achievements against '
          'today\'s planned milestones.',
      't-5': 'Capture and upload progress photos from each active zone.',
      't-6': 'Compile today\'s manpower + materials + progress into the '
          'daily report and submit before EOD.',
    };
    return {
      'id': id,
      'title': _titleFor(id),
      'description':
          descriptions[id] ?? 'Detailed task description coming from API.',
    };
  }

  // TODO(api): POST /tasks/{id}/remark —
  //   request: {remark, completion: 'partial'|'full', images: [b64...]},
  //   response: {success: bool}
  Future<bool> submitRemark({
    required String id,
    required String remark,
    required String completion,
    required List<String> imagesB64,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return true;
    // Real:
    // final res = await _dio.post('/tasks/$id/remark', data: {
    //   'remark': remark,
    //   'completion': completion,
    //   'images': imagesB64,
    // });
    // return (res.data as Map<String, dynamic>)['success'] == true;
  }

  String _titleFor(String id) {
    return const {
      't-1': 'Site Safety Inspection',
      't-2': 'Labour Attendance Verification',
      't-3': 'Material Quality Check',
      't-4': 'Work Progress Review',
      't-5': 'Site Photo Update',
      't-6': 'Daily Report Submission',
    }[id] ?? 'Task';
  }

  // ignore: unused_element
  Dio get _client => _dio;
}
