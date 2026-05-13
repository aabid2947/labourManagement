// File: lib/features/labour/data/labour_attendance_models.dart
// Purpose: Typed models for Labour In / Labour Out attendance rows + face-match result.
// Used by: labour_attendance_api, labour_attendance_repository, providers, screens.

import 'package:flutter/foundation.dart';

import '../../self_attendance/data/attendance_models.dart' show FaceMatchResult;
export '../../self_attendance/data/attendance_models.dart' show FaceMatchResult;

enum LabourAttendanceMode { inMode, outMode }

extension LabourAttendanceModeX on LabourAttendanceMode {
  String get apiPath => switch (this) {
        LabourAttendanceMode.inMode => '/attendance/labour/in',
        LabourAttendanceMode.outMode => '/attendance/labour/out',
      };
  String get listPath => switch (this) {
        LabourAttendanceMode.inMode => '/labour/in-list',
        LabourAttendanceMode.outMode => '/labour/out-list',
      };
}

@immutable
class LabourAttendanceItem {
  const LabourAttendanceItem({
    required this.id,
    required this.name,
    required this.skill,
    required this.marked,
    this.markedTime,
    this.inTime,
    this.outTime,
  });

  final String id;
  final String name;
  final String skill;
  final bool marked;
  /// Convenience: server-formatted time of the marked event for this mode ('08:15 AM').
  /// In `inMode` it equals [inTime]; in `outMode` it equals [outTime].
  final String? markedTime;
  /// Used on the Labour Out list to show the labour's check-in time alongside the
  /// pending OUT slot. May also be present on Labour In rows for parity.
  final String? inTime;
  /// Out-time stamp once the labour has been marked OUT.
  final String? outTime;

  factory LabourAttendanceItem.fromJson(Map<String, dynamic> j) =>
      LabourAttendanceItem(
        id: j['id'] as String,
        name: j['name'] as String,
        skill: j['skill'] as String,
        marked: (j['marked'] as bool?) ?? false,
        markedTime: j['markedTime'] as String?,
        inTime: j['inTime'] as String?,
        outTime: j['outTime'] as String?,
      );
}

@immutable
class LabourAttendanceSummary {
  const LabourAttendanceSummary({
    required this.items,
    required this.markedCount,
    required this.total,
  });
  final List<LabourAttendanceItem> items;
  final int markedCount;
  final int total;
}

// Re-export `FaceMatchResult` so Prompts 8/9 don't have to reach into the
// self_attendance feature directly. The result shape is identical to the
// self-attendance scan since it's the same AWS Rekognition contract.
typedef LabourFaceMatch = FaceMatchResult;
