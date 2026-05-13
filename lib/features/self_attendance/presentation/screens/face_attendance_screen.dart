// File: lib/features/self_attendance/presentation/screens/face_attendance_screen.dart
// Purpose: Pixel-matched Face Attendance from page14_img01.jpeg.
//          Front camera preview with yellow oval brackets, "Face Detected" card,
//          AWS Rekognition compare-faces stub, then navigate to success.
// Used by: routes/app_router.dart at RouteNames.selfAttendanceScan.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/text_styles.dart';
import '../../../../routes/route_names.dart';
import '../../data/attendance_models.dart';
import '../../providers/self_attendance_providers.dart';

class FaceAttendanceScreen extends ConsumerStatefulWidget {
  const FaceAttendanceScreen({super.key, required this.status});
  final AttendanceStatus status;

  @override
  ConsumerState<FaceAttendanceScreen> createState() =>
      _FaceAttendanceScreenState();
}

class _FaceAttendanceScreenState extends ConsumerState<FaceAttendanceScreen> {
  CameraController? _camera;
  bool _capturing = false;
  FaceMatchResult? _result;
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
    } catch (e) {
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
      _result = null;
    });
    try {
      final shot = await _camera!.takePicture();
      // image_b64 would be base64Encode(await File(shot.path).readAsBytes()).
      // We just pass the path stub here so we don't bloat memory until the real
      // endpoint lands.
      final imageRef = shot.path;
      final repo = ref.read(selfAttendanceRepositoryProvider);
      final match = await repo.compareFaces(
        imageB64: imageRef,
        userId: 'self',
      );
      if (!mounted) return;
      setState(() => _result = match);

      if (!match.match) {
        setState(() {
          _error = 'Face not matched. Try again.';
          _capturing = false;
        });
        return;
      }

      // Persist the IN/OUT punch.
      final markedAt = await repo.markAttendance(
        status: widget.status,
        siteId: 'alpha', // TODO(api): pull selected siteId from selectedSiteProvider once wired.
        faceConfidence: match.confidence,
      );

      // A successful IN punch unlocks the OUT pill for the rest of today
      // (Bug fix pass 4). The flag is persisted, keyed by date — see
      // InMarkedTodayController.
      if (widget.status == AttendanceStatus.inStatus) {
        await ref.read(inMarkedTodayProvider.notifier).markIn();
      }

      if (!mounted) return;
      context.go(
        RouteNames.selfAttendanceSuccess,
        extra: MarkAttendanceResult(
          status: widget.status,
          markedAt: markedAt,
          siteName: 'Project Alpha',
          siteSubtitle: 'Mumbai Metro',
        ),
      );
    } catch (e) {
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
            // Live camera preview clipped into the oval bracket region.
            ClipPath(
              clipper: _OvalClipper(),
              child: ColoredBox(
                color: const Color(0xFF2A2A2A),
                child: _camera?.value.isInitialized == true
                    ? CameraPreview(_camera!)
                    : const SizedBox.expand(),
              ),
            ),
            // Yellow bracket overlay.
            CustomPaint(
              painter: _OvalBracketPainter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detectionCard() {
    final r = _result;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          _detectionRow(
            ok: r?.match == true,
            title: r?.match == true ? 'Face Detected' : 'Detecting face…',
            subtitle: r?.match == true
                ? '${r!.displayName ?? '—'} (${r.userCode ?? '—'})  •  '
                    '${(r.confidence * 100).toStringAsFixed(0)}% match'
                : 'Align your face within the oval brackets',
            icon: Icons.check_circle_rounded,
            okColor: const Color(0xFF2E7D32),
          ),
          // ────────────────────────────────────────────────────────────
          // Commented per client (PDF page 15). Re-enable if requested.
          // The "Within Site Range" sub-section + location range block.
          // ────────────────────────────────────────────────────────────
          // Divider(
          //   color: const Color(0xFFEAECEF),
          //   height: 22.h,
          //   thickness: 1,
          // ),
          // _detectionRow(
          //   ok: true,
          //   title: 'Within Site Range',
          //   subtitle: 'Project Alpha • 3.2m from location',
          //   icon: Icons.location_on_rounded,
          //   okColor: AppColors.textPrimary,
          // ),
        ],
      ),
    );
  }

  Widget _detectionRow({
    required bool ok,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color okColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: ok
                ? okColor.withValues(alpha: 0.12)
                : const Color(0xFFEAECEF),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon,
              color: ok ? okColor : const Color(0xFF6B7280), size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyBold),
              SizedBox(height: 2.h),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
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
    // Top arc (≈ -130° → -50°)
    canvas.drawArc(rect, -2.27, 1.35, false, paint);
    // Bottom arc (≈ 50° → 130°)
    canvas.drawArc(rect, 0.88, 1.35, false, paint);
    // Left / right small arcs to give bracket feel.
    canvas.drawArc(rect, 2.7, 0.7, false, paint);
    canvas.drawArc(rect, -0.6, 0.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
