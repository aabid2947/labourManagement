// File: lib/features/self_attendance/providers/self_attendance_providers.dart
// Purpose: Riverpod providers for the self-attendance feature.
// Used by: self_attendance / face_attendance / view_attendance / success screens.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../data/attendance_models.dart';
import '../data/self_attendance_repository.dart';

final selfAttendanceRepositoryProvider =
    Provider<SelfAttendanceRepository>((_) => SelfAttendanceRepository());

/// Selected IN / OUT toggle on the Self Attendance entry screen.
class AttendanceStatusController extends Notifier<AttendanceStatus> {
  @override
  AttendanceStatus build() => AttendanceStatus.inStatus;
  void set(AttendanceStatus s) => state = s;
}

final attendanceStatusProvider =
    NotifierProvider<AttendanceStatusController, AttendanceStatus>(
        AttendanceStatusController.new);

/// View-Attendance filter range — defaults to current month.
class AttendanceRange {
  const AttendanceRange(this.from, this.to);
  final DateTime from;
  final DateTime to;

  AttendanceRange copyWith({DateTime? from, DateTime? to}) =>
      AttendanceRange(from ?? this.from, to ?? this.to);
}

class AttendanceRangeController extends Notifier<AttendanceRange> {
  @override
  AttendanceRange build() {
    final now = DateTime.now();
    return AttendanceRange(DateTime(now.year, now.month, 1), now);
  }

  void setFrom(DateTime d) => state = state.copyWith(from: d);
  void setTo(DateTime d) => state = state.copyWith(to: d);
}

final attendanceRangeProvider =
    NotifierProvider<AttendanceRangeController, AttendanceRange>(
        AttendanceRangeController.new);

final myAttendanceProvider =
    FutureProvider.autoDispose<List<AttendanceEntry>>((ref) {
  final r = ref.watch(attendanceRangeProvider);
  return ref
      .watch(selfAttendanceRepositoryProvider)
      .fetchMyAttendance(from: r.from, to: r.to);
});

/// Tracks whether the user has already marked their IN attendance for the
/// current calendar day. Persisted to flutter_secure_storage under a key
/// that includes today's date (`self_attendance_in:yyyy-MM-dd`) so the flag
/// auto-resets at midnight — yesterday's key simply won't be read tomorrow.
/// The OUT pill on Self Attendance stays disabled while this is false.
class InMarkedTodayController extends AsyncNotifier<bool> {
  static String _todayKey() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return 'self_attendance_in:${n.year}-$m-$d';
  }

  @override
  Future<bool> build() async {
    final stored = await SecureStorage().read(_todayKey());
    return stored == '1';
  }

  Future<void> markIn() async {
    await SecureStorage().write(_todayKey(), '1');
    state = const AsyncValue.data(true);
  }

  /// Test-only helper; production code shouldn't need this.
  Future<void> reset() async {
    await SecureStorage().delete(_todayKey());
    state = const AsyncValue.data(false);
  }
}

final inMarkedTodayProvider =
    AsyncNotifierProvider<InMarkedTodayController, bool>(
        InMarkedTodayController.new);
