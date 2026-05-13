// File: lib/features/labour/data/labour_attendance_repository.dart
// Purpose: Domain wrapper for LabourAttendanceApiService — typed list + face match + mark.
// Used by: features/labour/providers/labour_attendance_providers.dart.

import 'labour_attendance_api_service.dart';
import 'labour_attendance_models.dart';

class LabourAttendanceRepository {
  LabourAttendanceRepository({LabourAttendanceApiService? api})
      : _api = api ?? LabourAttendanceApiService();
  final LabourAttendanceApiService _api;

  Future<LabourAttendanceSummary> fetchList({
    required String contractorId,
    required LabourAttendanceMode mode,
  }) async {
    final j = await _api.fetchAttendanceList(
        contractorId: contractorId, mode: mode);
    final raw = (j['items'] as List).cast<Map<String, dynamic>>();
    final items = raw.map(LabourAttendanceItem.fromJson).toList(growable: false);
    return LabourAttendanceSummary(
      items: items,
      markedCount: (j['marked'] as int?) ?? items.where((e) => e.marked).length,
      total: (j['total'] as int?) ?? items.length,
    );
  }

  Future<LabourFaceMatch> matchFace({
    required String imageB64,
    required String labourId,
  }) async {
    final j =
        await _api.matchLabourFace(imageB64: imageB64, labourId: labourId);
    return LabourFaceMatch(
      match: j['match'] as bool,
      confidence: (j['confidence'] as num).toDouble(),
      displayName: j['name'] as String?,
      userCode: j['code'] as String?,
    );
  }

  Future<DateTime> markAttendance({
    required String labourId,
    required LabourAttendanceMode mode,
    double? lat,
    double? lng,
  }) async {
    final j = await _api.postLabourAttendance(
      labourId: labourId,
      mode: mode,
      lat: lat,
      lng: lng,
    );
    return DateTime.parse(j['markedAt'] as String);
  }
}
