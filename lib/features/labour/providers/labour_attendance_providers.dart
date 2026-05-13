// File: lib/features/labour/providers/labour_attendance_providers.dart
// Purpose: Riverpod providers for Labour In / Out lists, face match, mark attendance.
// Used by: labour_in_screen.dart, labour_out_screen.dart, labour_face_scan_screen.dart.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/labour_attendance_models.dart';
import '../data/labour_attendance_repository.dart';
import 'labour_providers.dart';

final labourAttendanceRepositoryProvider =
    Provider<LabourAttendanceRepository>((_) => LabourAttendanceRepository());

/// (contractorId, mode) keyed list — autoDispose so it refreshes after a punch.
final labourAttendanceListProvider = FutureProvider.autoDispose
    .family<LabourAttendanceSummary, LabourAttendanceMode>((ref, mode) {
  final contractor = ref.watch(selectedContractorProvider);
  if (contractor == null) {
    return Future.value(const LabourAttendanceSummary(
        items: [], markedCount: 0, total: 0));
  }
  return ref
      .watch(labourAttendanceRepositoryProvider)
      .fetchList(contractorId: contractor.id, mode: mode);
});
