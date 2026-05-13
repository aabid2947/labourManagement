// File: lib/features/labour/data/labour_attendance_api_service.dart
// Purpose: Network + AWS Rekognition stubs for Labour In / Out attendance.
// Used by: features/labour/data/labour_attendance_repository.dart.

import 'package:dio/dio.dart';

import '../../../core/config/aws_config.dart';
import '../../../core/network/dio_client.dart';
import 'labour_attendance_models.dart';

class LabourAttendanceApiService {
  LabourAttendanceApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): GET /labour/in-list?contractorId= — response:
  //   {items: [{id, name, skill, marked, markedTime?}], total: int}
  // TODO(api): GET /labour/out-list?contractorId= — same shape.
  Future<Map<String, dynamic>> fetchAttendanceList({
    required String contractorId,
    required LabourAttendanceMode mode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    // Deterministic mock — backend dev replaces with real GET on `mode.listPath`.
    final items = _mockItems(contractorId, mode);
    final markedCount = items.where((j) => j['marked'] == true).length;
    return {'items': items, 'total': items.length, 'marked': markedCount};
    // Real:
    // final res = await _dio.get('${mode.listPath}', queryParameters: {'contractorId': contractorId});
    // return res.data as Map<String, dynamic>;
  }

  // TODO(api): POST {AWS_REKOGNITION_ENDPOINT}/match-labour —
  //   request: {image_b64, labourId}, response: {match: bool, confidence: number, name?, code?}
  Future<Map<String, dynamic>> matchLabourFace({
    required String imageB64,
    required String labourId,
  }) async {
    if (AwsConfig.isConfigured) {
      // Real implementation (uncomment + verify request signature when keys arrive):
      // final res = await _dio.post(
      //   '${AwsConfig.rekognitionEndpoint}/match-labour',
      //   data: {'image_b64': imageB64, 'labourId': labourId},
      // );
      // return res.data as Map<String, dynamic>;
    }
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return {
      'match': true,
      'confidence': 0.97,
      'name': 'Labour',
      'code': 'L-${labourId.hashCode.abs() % 1000}',
    };
  }

  // TODO(api): POST /attendance/labour/in  — request:
  //   {labourId, timestamp, location: {lat, lng}}, response: {success, markedAt}
  // TODO(api): POST /attendance/labour/out — same shape.
  Future<Map<String, dynamic>> postLabourAttendance({
    required String labourId,
    required LabourAttendanceMode mode,
    double? lat,
    double? lng,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return {
      'success': true,
      'markedAt': DateTime.now().toIso8601String(),
    };
    // Real:
    // final res = await _dio.post(mode.apiPath, data: {
    //   'labourId': labourId,
    //   'timestamp': DateTime.now().toIso8601String(),
    //   'location': lat == null ? null : {'lat': lat, 'lng': lng},
    // });
    // return res.data as Map<String, dynamic>;
  }

  // Deterministic mock dataset so Labour In / Out renders the same labour set
  // referenced by Prompt 7. Marked / unmarked is rotated by id so the UI shows
  // both states.
  List<Map<String, dynamic>> _mockItems(
    String contractorId,
    LabourAttendanceMode mode,
  ) {
    const all = <Map<String, String>>[
      {'id': 'lab-1', 'name': 'Ramesh Kumar', 'skill': 'Skilled Worker'},
      {'id': 'lab-2', 'name': 'Suresh Yadav', 'skill': 'Helper'},
      {'id': 'lab-3', 'name': 'Ajay Singh', 'skill': 'Mason'},
      {'id': 'lab-4', 'name': 'Mahesh Chauhan', 'skill': 'Bar Bender'},
      {'id': 'lab-5', 'name': 'Vijay Verma', 'skill': 'Carpenter'},
      {'id': 'lab-6', 'name': 'Manoj Gupta', 'skill': 'Helper'},
      {'id': 'lab-7', 'name': 'Deepak Patel', 'skill': 'Mason'},
      {'id': 'lab-8', 'name': 'Rohit Sharma', 'skill': 'Helper'},
      {'id': 'lab-9', 'name': 'Karan Mehta', 'skill': 'Welder'},
      {'id': 'lab-10', 'name': 'Anil Joshi', 'skill': 'Plumber'},
      {'id': 'lab-11', 'name': 'Sunil Rao', 'skill': 'Painter'},
      {'id': 'lab-12', 'name': 'Pankaj Iyer', 'skill': 'Helper'},
    ];

    // Mark ~5/12 to mirror the screenshot's "Attendance Marked: 5 out of 12"
    // (page22) and "Out Marked: 5 out of 12 Labour" (page26).
    const markedIdsIn = {
      'lab-1', 'lab-4', 'lab-6', 'lab-9', 'lab-11', // also checked in (for out)
    };
    const markedIdsOut = {'lab-1', 'lab-4', 'lab-6'};

    int idx = 0;
    return all.map((m) {
      idx++;
      final id = m['id']!;
      // Every row already has an IN time in the Out flow — the screenshot shows
      // IN: 08:xx for every row, with OUT filled only on the marked rows.
      final inTime = '08:0${idx % 9 + 1} AM'.replaceFirst('08:00', '08:09');
      String? outTime;
      bool marked;
      String? markedTime;

      if (mode == LabourAttendanceMode.inMode) {
        marked = markedIdsIn.contains(id);
        markedTime = marked ? inTime : null;
      } else {
        marked = markedIdsOut.contains(id);
        outTime = marked ? '06:0${idx % 9} PM'.replaceFirst('06:00', '06:09') : null;
        markedTime = outTime;
      }

      return {
        'id': id,
        'name': m['name'],
        'skill': m['skill'],
        'marked': marked,
        'markedTime': markedTime,
        'inTime': inTime,
        'outTime': outTime,
      };
    }).toList(growable: false);
  }

  // ignore: unused_element
  Dio get _client => _dio;
}
