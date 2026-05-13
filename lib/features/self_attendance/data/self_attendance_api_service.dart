// File: lib/features/self_attendance/data/self_attendance_api_service.dart
// Purpose: Network + AWS Rekognition stubs for self-attendance.
// Used by: self_attendance_repository.dart and face_attendance_service.dart.

import 'package:dio/dio.dart';

import '../../../core/config/aws_config.dart';
import '../../../core/network/dio_client.dart';

class SelfAttendanceApiService {
  SelfAttendanceApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): POST {AWS_REKOGNITION_ENDPOINT}/compare-faces —
  //   request: {image_b64, userId}, response: {match: bool, confidence: number, name?, code?}
  Future<Map<String, dynamic>> compareFaces({
    required String imageB64,
    required String userId,
  }) async {
    // AwsConfig values are empty stubs (Prompt 1). Backend dev fills before integration.
    if (AwsConfig.isConfigured) {
      // Real implementation (uncomment + verify request signature when keys arrive):
      // final res = await _dio.post(
      //   '${AwsConfig.rekognitionEndpoint}/compare-faces',
      //   data: {'image_b64': imageB64, 'userId': userId},
      // );
      // return res.data as Map<String, dynamic>;
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return {
      'match': true,
      'confidence': 0.98,
      'name': 'Rakesh Kumar',
      'code': 'SE-102',
    };
  }

  // TODO(api): POST /attendance/self — request: {status: 'in'|'out', siteId, faceConfidence,
  //   location: {lat, lng}}, response: {success: bool, markedAt: iso8601}
  Future<Map<String, dynamic>> markAttendance({
    required String status,
    required String siteId,
    required double faceConfidence,
    double? lat,
    double? lng,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return {
      'success': true,
      'markedAt': DateTime.now().toIso8601String(),
    };
    // Real: return (await _dio.post('/attendance/self', data: {...})).data as Map<String, dynamic>;
  }

  // TODO(api): GET /attendance/me?from=&to= —
  //   response: [{date, inTime, outTime, status}]
  Future<List<Map<String, dynamic>>> fetchMyAttendance({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    // Deterministic mock — backend dev replaces.
    final entries = <Map<String, dynamic>>[];
    var d = DateTime(from.year, from.month, from.day);
    final last = DateTime(to.year, to.month, to.day);
    while (!d.isAfter(last)) {
      final dow = d.weekday;
      if (dow != DateTime.sunday) {
        entries.add({
          'date': d.toIso8601String(),
          'inTime': '08:1${d.day % 9} AM',
          'outTime': dow == DateTime.saturday ? '01:30 PM' : '05:45 PM',
          'status': dow == DateTime.saturday ? 'Half-day' : 'Present',
        });
      }
      d = d.add(const Duration(days: 1));
    }
    return entries;
  }

  // ignore: unused_element
  Dio get _client => _dio;
}
