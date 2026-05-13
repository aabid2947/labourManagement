// File: lib/features/labour/presentation/screens/labour_scan_args.dart
// Purpose: GoRoute `extra` payload passed from Labour In / Out lists into the face scan.
// Used by: labour_in_screen.dart, labour_out_screen.dart (Prompt 9), labour_face_scan_screen.dart.

import '../../data/labour_attendance_models.dart';

class LabourScanArgs {
  const LabourScanArgs({required this.item, required this.mode});
  final LabourAttendanceItem item;
  final LabourAttendanceMode mode;
}
