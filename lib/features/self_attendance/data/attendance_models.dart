// File: lib/features/self_attendance/data/attendance_models.dart
// Purpose: Typed models for self-attendance — Status enum, FaceMatch, AttendanceEntry.
// Used by: self_attendance_api_service.dart, providers, screens.

import 'package:flutter/foundation.dart';

enum AttendanceStatus { inStatus, outStatus }

extension AttendanceStatusX on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.inStatus => 'IN',
        AttendanceStatus.outStatus => 'OUT',
      };
  String get apiValue => switch (this) {
        AttendanceStatus.inStatus => 'in',
        AttendanceStatus.outStatus => 'out',
      };
}

@immutable
class FaceMatchResult {
  const FaceMatchResult({
    required this.match,
    required this.confidence,
    this.displayName,
    this.userCode,
  });
  final bool match;
  final double confidence; // 0..1
  final String? displayName;
  final String? userCode;
}

@immutable
class AttendanceEntry {
  const AttendanceEntry({
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.status,
  });
  final DateTime date;
  final String? inTime;
  final String? outTime;
  final String status; // 'Present' | 'Absent' | 'Half-day' etc. (server-defined)

  factory AttendanceEntry.fromJson(Map<String, dynamic> j) => AttendanceEntry(
        date: DateTime.parse(j['date'] as String),
        inTime: j['inTime'] as String?,
        outTime: j['outTime'] as String?,
        status: j['status'] as String,
      );
}

@immutable
class MarkAttendanceResult {
  const MarkAttendanceResult({
    required this.status,
    required this.markedAt,
    required this.siteName,
    required this.siteSubtitle,
  });
  final AttendanceStatus status;
  final DateTime markedAt;
  final String siteName;
  final String siteSubtitle;
}
