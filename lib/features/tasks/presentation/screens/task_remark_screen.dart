// File: lib/features/tasks/presentation/screens/task_remark_screen.dart
// Purpose: Pixel-matched Remarks screen from page34_img01.jpeg.
//          Title + description (read-only) + remark text area + multi-image upload
//          (image_picker.pickMultiImage) + Task Status (Partial / Fully Completed)
//          + Submit. On success the screen pops back to Task v/s Achievements.
// Used by: routes/app_router.dart at RouteNames.taskRemark.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../data/task_models.dart';
import '../../providers/task_providers.dart';

class TaskRemarkScreen extends ConsumerStatefulWidget {
  const TaskRemarkScreen({super.key, required this.task});
  final TaskAchievement task;

  @override
  ConsumerState<TaskRemarkScreen> createState() => _TaskRemarkScreenState();
}

class _TaskRemarkScreenState extends ConsumerState<TaskRemarkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _remarkCtrl = TextEditingController();
  final _picker = ImagePicker();

  final List<XFile> _images = [];
  TaskCompletion? _status;
  bool _statusDropdownOpen = false;
  bool _submitting = false;
  String? _statusError;

  @override
  void dispose() {
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _addImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
  }

  Future<void> _submit() async {
    setState(() {
      _statusError = _status == null ? 'Please select task status' : null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_status == null) return;

    setState(() => _submitting = true);
    final ok = await ref.read(taskRepositoryProvider).submitRemark(
          id: widget.task.id,
          remark: _remarkCtrl.text.trim(),
          completion: _status!,
          // Each XFile.path stands in for `image_b64`. Real backend integration
          // will base64Encode(await File(p).readAsBytes()) at this site.
          imagesB64: _images.map((x) => x.path).toList(growable: false),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submit failed. Please try again.')),
      );
      return;
    }
    // Refresh the list so the new status shows on the table behind us.
    ref.invalidate(taskListProvider);
    await SuccessDialog.show(
      context,
      title: 'Remark Submitted',
      message: 'Your remark has been successfully submitted.',
    );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Remarks', style: AppTextStyles.appBarTitle),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.h),
                _label('Task Title'),
                SizedBox(height: 8.h),
                _readOnly(widget.task.title, bold: true),
                SizedBox(height: 16.h),
                _label('Task Description'),
                SizedBox(height: 8.h),
                _readOnly(_descriptionFor(widget.task.id),
                    multiline: true),
                SizedBox(height: 16.h),
                _label('Remarks'),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _remarkCtrl,
                  minLines: 4,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.inputText,
                  decoration: const InputDecoration(
                    hintText: 'Enter your remark here…',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Remark is required' : null,
                ),
                SizedBox(height: 16.h),
                _label('Upload Image'),
                SizedBox(height: 2.h),
                Text('You can upload multiple images',
                    style: AppTextStyles.caption),
                SizedBox(height: 8.h),
                _imageStrip(),
                SizedBox(height: 16.h),
                _label('Task Status'),
                SizedBox(height: 8.h),
                _statusSelector(),
                if (_statusError != null) ...[
                  SizedBox(height: 6.h),
                  Text(_statusError!, style: AppTextStyles.errorText),
                ],
                SizedBox(height: 24.h),
                PrimaryButton(
                  label: 'Submit',
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // The task description lives behind taskDetailProvider; rather than spin a
  // second async wait here, we just match on the same id set the mock returns.
  // Once the backend is real, swap this to `ref.watch(taskDetailProvider(id))`.
  String _descriptionFor(String id) {
    const map = <String, String>{
      't-1': 'Inspect the site area for safety compliance including '
          'equipment, signage, and worker adherence to safety protocols.',
      't-2': 'Verify attendance records against floor headcount and flag '
          'any discrepancies for the contractor.',
      't-3': 'Spot-check material batches for spec compliance, document '
          'serial numbers and run a sample QC.',
      't-4': 'Walk the active work zones and confirm achievements against '
          'today\'s planned milestones.',
      't-5': 'Capture and upload progress photos from each active zone.',
      't-6': 'Compile today\'s manpower + materials + progress into the '
          'daily report and submit before EOD.',
    };
    return map[id] ?? 'Task description not available.';
  }

  Widget _label(String text) =>
      Text(text, style: AppTextStyles.sectionHeader);

  Widget _readOnly(String text, {bool bold = false, bool multiline = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      constraints: BoxConstraints(minHeight: multiline ? 110.h : 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _imageStrip() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: SizedBox(
        height: 96.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _images.length + 1,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            if (i == _images.length) {
              return _addPhotoTile();
            }
            return _imagePreview(_images[i], i);
          },
        ),
      ),
    );
  }

  Widget _addPhotoTile() {
    return InkWell(
      onTap: _addImages,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 96.h,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary, size: 28.sp),
            SizedBox(height: 4.h),
            Text('Add Photo',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview(XFile file, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            width: 96.h,
            height: 96.h,
            child: Image.file(
              File(file.path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.primarySoft,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image_outlined,
                    color: AppColors.primaryDark, size: 28.sp),
              ),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () => setState(() => _images.removeAt(index)),
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(Icons.close_rounded,
                  color: AppColors.textPrimary, size: 14.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusSelector() {
    return Column(
      children: [
        InkWell(
          onTap: () =>
              setState(() => _statusDropdownOpen = !_statusDropdownOpen),
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: _statusError != null
                    ? AppColors.error
                    : AppColors.primary,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _status?.label ?? 'Select task status',
                    style: _status == null
                        ? AppTextStyles.inputHint
                        : AppTextStyles.inputText,
                  ),
                ),
                Icon(
                  _statusDropdownOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
        if (_statusDropdownOpen) ...[
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _statusRadio(TaskCompletion.partial),
                const Divider(height: 1, color: AppColors.divider),
                _statusRadio(TaskCompletion.full),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusRadio(TaskCompletion value) {
    final selected = _status == value;
    return InkWell(
      onTap: () => setState(() {
        _status = value;
        _statusDropdownOpen = false;
        _statusError = null;
      }),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  width: 1.4,
                ),
              ),
              child: selected
                  ? Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Text(value.label, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
