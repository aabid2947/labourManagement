// File: lib/features/self_attendance/data/self_attendance_repository.dart
// Purpose: Domain wrapper for SelfAttendanceApiService — typed models for the UI.
// Used by: features/self_attendance/providers/self_attendance_providers.dart.

import 'attendance_models.dart';
import 'self_attendance_api_service.dart';

class SelfAttendanceRepository {
  SelfAttendanceRepository({SelfAttendanceApiService? api})
      : _api = api ?? SelfAttendanceApiService();
  final SelfAttendanceApiService _api;

  Future<FaceMatchResult> compareFaces({
    required String imageB64,
    required String userId,
  }) async {
    final j = await _api.compareFaces(imageB64: imageB64, userId: userId);
    return FaceMatchResult(
      match: j['match'] as bool,
      confidence: (j['confidence'] as num).toDouble(),
      displayName: j['name'] as String?,
      userCode: j['code'] as String?,
    );
  }

  Future<DateTime> markAttendance({
    required AttendanceStatus status,
    required String siteId,
    required double faceConfidence,
    double? lat,
    double? lng,
  }) async {
    final j = await _api.markAttendance(
      status: status.apiValue,
      siteId: siteId,
      faceConfidence: faceConfidence,
      lat: lat,
      lng: lng,
    );
    return DateTime.parse(j['markedAt'] as String);
  }

  Future<List<AttendanceEntry>> fetchMyAttendance({
    required DateTime from,
    required DateTime to,
  }) async {
    final list = await _api.fetchMyAttendance(from: from, to: to);
    return list.map(AttendanceEntry.fromJson).toList(growable: false);
  }
}
