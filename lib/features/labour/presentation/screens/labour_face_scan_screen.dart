// File: lib/features/labour/presentation/screens/labour_face_scan_screen.dart
// Purpose: Labour In / Out face scan from page24_img01.jpeg (and page28 for Out).
//          The "Within Site Range" block visible in the screenshot is intentionally
//          NOT rendered here — per brief (PDF page 25 / 29), it is removed (deleted,
//          not commented out — that distinction is on purpose vs Prompt 6).
// Used by: routes/app_router.dart at RouteNames.labourInScan + RouteNames.labourOutScan.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../../../routes/route_names.dart';
import '../../data/labour_attendance_models.dart';
import '../../providers/labour_attendance_providers.dart';
import 'labour_scan_args.dart';

class LabourFaceScanScreen extends ConsumerStatefulWidget {
  const LabourFaceScanScreen({super.key, required this.args});
  final LabourScanArgs args;

  @override
  ConsumerState<LabourFaceScanScreen> createState() =>
      _LabourFaceScanScreenState();
}

class _LabourFaceScanScreenState extends ConsumerState<LabourFaceScanScreen> {
  CameraController? _camera;
  bool _capturing = false;
  LabourFaceMatch? _match;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _camera = controller);
    } catch (_) {
      if (mounted) setState(() => _error = 'Camera unavailable.');
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_capturing || _camera == null || !_camera!.value.isInitialized) return;
    setState(() {
      _capturing = true;
      _match = null;
      _error = null;
    });
    try {
      final shot = await _camera!.takePicture();
      final repo = ref.read(labourAttendanceRepositoryProvider);
      final match = await repo.matchFace(
        imageB64: shot.path,
        labourId: widget.args.item.id,
      );
      if (!mounted) return;
      setState(() => _match = match);
      if (!match.match) {
        setState(() {
          _error = 'Face not matched. Please retry.';
          _capturing = false;
        });
        return;
      }
      await repo.markAttendance(
        labourId: widget.args.item.id,
        mode: widget.args.mode,
      );
      if (!mounted) return;
      await SuccessDialog.show(
        context,
        title: 'Attendance Marked',
        message: AppStrings.attendanceSuccess,
      );
      if (!mounted) return;
      // Refresh list so the row flips to a green "marked" pill.
      ref.invalidate(labourAttendanceListProvider(widget.args.mode));
      context.go(
        widget.args.mode == LabourAttendanceMode.inMode
            ? RouteNames.labourIn
            : RouteNames.labourOut,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Capture failed. Please try again.';
        _capturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(child: _previewArea()),
            _detectionCard(),
            SizedBox(height: 12.h),
            _captureButton(),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Text(
                _error ?? 'Please look at the camera',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: _error == null ? Colors.white70 : Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      child: Row(
        children: [
          Material(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(10.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(10.r),
              onTap: () => context.pop(),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Face Attendance',
                style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _previewArea() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _OvalClipper(),
              child: ColoredBox(
                color: const Color(0xFF2A2A2A),
                child: _camera?.value.isInitialized == true
                    ? CameraPreview(_camera!)
                    : const SizedBox.expand(),
              ),
            ),
            CustomPaint(painter: _OvalBracketPainter()),
          ],
        ),
      ),
    );
  }

  // Per brief (PDF page 25): the "Within Site Range" sub-section visible in the
  // screenshot is intentionally NOT rendered here. This differs from the Self
  // Attendance face screen (Prompt 6) where the same block is commented out
  // instead of deleted.
  Widget _detectionCard() {
    final r = _match;
    final fallbackName =
        '${widget.args.item.name} (${widget.args.item.skill})';
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: r?.match == true
                  ? AppColors.success.withValues(alpha: 0.12)
                  : const Color(0xFFEAECEF),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.check_circle_rounded,
                color: r?.match == true
                    ? AppColors.success
                    : const Color(0xFF6B7280),
                size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r?.match == true ? 'Face Detected' : 'Detecting face…',
                  style: AppTextStyles.bodyBold,
                ),
                SizedBox(height: 2.h),
                Text(
                  r?.match == true
                      ? '${r!.displayName ?? widget.args.item.name} '
                          '${r.userCode != null ? '(${r.userCode})' : ''}  •  '
                          '${(r.confidence * 100).toStringAsFixed(0)}% match'
                      : 'Align $fallbackName within the oval brackets',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _captureButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 56.h,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F1F1F),
            disabledBackgroundColor: const Color(0xFF1F1F1F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed: _capturing ? null : _capture,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: _capturing
                    ? const CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Color(0xFFFFB300),
                      )
                    : Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                _capturing ? 'Capturing…' : 'Capture',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.86,
      height: size.height * 0.92,
    );
    return Path()..addOval(rect);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _OvalBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.86,
      height: size.height * 0.92,
    );
    canvas.drawArc(rect, -2.27, 1.35, false, paint);
    canvas.drawArc(rect, 0.88, 1.35, false, paint);
    canvas.drawArc(rect, 2.7, 0.7, false, paint);
    canvas.drawArc(rect, -0.6, 0.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
