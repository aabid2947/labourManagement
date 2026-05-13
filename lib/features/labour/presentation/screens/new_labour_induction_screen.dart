// File: lib/features/labour/presentation/screens/new_labour_induction_screen.dart
// Purpose: Pixel-matched labour form from page20_img01.jpeg.
//          Heading is "New Labour Induction" (the screenshot says "New Labour" — the
//          brief on PDF page 21 explicitly demands the heading change). Same form is
//          reused for Edit mode with heading "Edit Labour" and fields pre-filled.
// Used by: routes/app_router.dart at RouteNames.labourInduction + RouteNames.labourEdit.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../data/labour_models.dart';
import '../../providers/labour_providers.dart';

class NewLabourInductionScreen extends ConsumerStatefulWidget {
  const NewLabourInductionScreen({super.key, this.existing});

  /// When non-null the screen renders in EDIT mode with fields pre-filled and the
  /// heading swapped to "Edit Labour".
  final Labour? existing;

  bool get isEdit => existing != null;

  @override
  ConsumerState<NewLabourInductionScreen> createState() =>
      _NewLabourInductionScreenState();
}

class _NewLabourInductionScreenState
    extends ConsumerState<NewLabourInductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  Contractor? _contractor;
  String? _skill;
  DateTime? _dob;
  String? _dobError;
  XFile? _facePhoto;
  String? _faceError;
  XFile? _panCard;
  XFile? _aadhaar;
  String? _aadhaarError;
  bool _saving = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _skill = e.skill;
      _dob = e.dob;
      // Contractor is set after contractors load (see build()).
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool _isAdult(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age -= 1;
    }
    return age >= 18;
  }

  Future<void> _captureFace() async {
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (shot != null) {
      setState(() {
        _facePhoto = shot;
        _faceError = null;
      });
    }
  }

  Future<void> _pickDocument({required bool isAadhaar}) async {
    final shot = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (shot != null) {
      setState(() {
        if (isAadhaar) {
          _aadhaar = shot;
          _aadhaarError = null;
        } else {
          _panCard = shot;
        }
      });
    }
  }

  Future<void> _save() async {
    // Custom DOB + Aadhaar validation (Form's auto-validation handles name/skill/contractor).
    setState(() {
      _dobError = _dob == null
          ? 'Date of birth is required'
          : (_isAdult(_dob!) ? null : 'Age Should Not Less Than 18');
      _aadhaarError =
          (_aadhaar == null && !widget.isEdit) ? 'Aadhaar Card is mandatory' : null;
      // Face Recognition is marked required on the form; an edit can keep the
      // existing enrolled face (faceEnrolledId on the labour) and skip recapture.
      _faceError = (_facePhoto == null && !widget.isEdit)
          ? 'Face capture is required'
          : null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_dobError != null || _aadhaarError != null || _faceError != null) {
      return;
    }
    if (_contractor == null) return;

    setState(() => _saving = true);
    final repo = ref.read(labourRepositoryProvider);
    try {
      String labourId;
      if (widget.isEdit) {
        await repo.updateLabour(
          id: widget.existing!.id,
          contractorId: _contractor!.id,
          name: _nameCtrl.text.trim(),
          skill: _skill!,
          dob: _dob!,
        );
        labourId = widget.existing!.id;
      } else {
        labourId = await repo.createLabour(
          contractorId: _contractor!.id,
          name: _nameCtrl.text.trim(),
          skill: _skill!,
          dob: _dob!,
          panCardLocalPath: _panCard?.path,
          aadhaarLocalPath: _aadhaar?.path,
        );
      }

      // Enroll the face if a photo was captured. Used later by Prompts 8/9 for matching.
      if (_facePhoto != null) {
        // image_b64 left as the local path until the backend integration replaces
        // it with base64Encode(await File(_facePhoto!.path).readAsBytes()).
        await repo.enrollFace(labourId: labourId, imageB64: _facePhoto!.path);
      }

      // Refresh the list.
      ref.invalidate(labourListProvider);
      ref.invalidate(labourCountProvider);

      if (!mounted) return;
      await SuccessDialog.show(
        context,
        title: widget.isEdit ? 'Labour Updated' : 'Labour Added',
        message: widget.isEdit
            ? 'Labour record has been updated.'
            : 'New labour has been inducted.',
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractorsAsync = ref.watch(contractorsProvider);

    // In edit mode, hydrate the contractor selector once contractors load.
    contractorsAsync.whenData((list) {
      if (_contractor == null) {
        if (widget.isEdit) {
          final match = list.where((c) => c.id == widget.existing!.contractorId);
          if (match.isNotEmpty) {
            Future.microtask(() {
              if (mounted) setState(() => _contractor = match.first);
            });
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.isEdit ? 'Edit Labour' : 'New Labour Induction',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                contractorsAsync.when(
                  loading: () => const LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.divider),
                  error: (e, _) => Text('Failed to load contractors: $e',
                      style: AppTextStyles.body),
                  data: (contractors) => AppDropdown<Contractor>(
                    label: 'Contractor Name',
                    hint: 'Select Contractor',
                    required: true,
                    value: _contractor,
                    items: contractors,
                    itemLabel: (c) => c.name,
                    onChanged: (c) => setState(() => _contractor = c),
                    validator: (v) =>
                        v == null ? 'Contractor is required' : null,
                  ),
                ),
                SizedBox(height: 22.h),
                Text('Labour Details', style: AppTextStyles.screenTitle.copyWith(fontSize: 18.sp)),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Labour Name',
                        hint: 'Enter labour name',
                        required: true,
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.required(v, field: 'Labour name'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'Skill',
                        hint: 'Select Skill',
                        required: true,
                        value: _skill,
                        items: kSkillOptions,
                        itemLabel: (s) => s,
                        onChanged: (s) => setState(() => _skill = s),
                        validator: (v) => v == null ? 'Skill is required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _dobField(),
                SizedBox(height: 22.h),
                _faceRecognitionRow(),
                SizedBox(height: 22.h),
                Text('Documents', style: AppTextStyles.screenTitle.copyWith(fontSize: 18.sp)),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _uploadField(
                        label: 'Pan Card',
                        required: false,
                        file: _panCard,
                        onTap: () => _pickDocument(isAadhaar: false),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _uploadField(
                        label: 'Aadhaar Card',
                        required: true,
                        file: _aadhaar,
                        errorText: _aadhaarError,
                        onTap: () => _pickDocument(isAadhaar: true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: () => context.pop(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: PrimaryButton(
                        label: widget.isEdit ? 'Update' : 'Save',
                        loading: _saving,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'SELECT DOB',
            style: AppTextStyles.inputLabel,
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _dob ?? DateTime(now.year - 22, now.month, now.day),
              firstDate: DateTime(1950),
              lastDate: now,
            );
            if (picked != null) {
              setState(() {
                _dob = picked;
                _dobError =
                    _isAdult(picked) ? null : 'Age Should Not Less Than 18';
              });
            }
          },
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: _dobError != null
                    ? AppColors.error
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dob == null
                        ? 'Select Date of Birth'
                        : Formatters.date(_dob!),
                    style: _dob == null
                        ? AppTextStyles.inputHint
                        : AppTextStyles.inputText,
                  ),
                ),
                Icon(Icons.calendar_today_outlined,
                    size: 18.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (_dobError != null) ...[
          SizedBox(height: 6.h),
          Text(_dobError!, style: AppTextStyles.errorText),
        ],
      ],
    );
  }

  Widget _faceRecognitionRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'FACE RECOGNITION',
            style: AppTextStyles.inputLabel,
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // Avatar tile (left)
            Container(
              width: 112.w,
              height: 112.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: _facePhoto == null
                  ? Icon(Icons.person,
                      size: 56.sp, color: AppColors.textSecondary)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        _facePhoto!.path,
                        width: 112.w,
                        height: 112.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person_pin,
                          size: 56.sp,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            // Capture Image button (right)
            Expanded(
              child: InkWell(
                onTap: _captureFace,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 112.w,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          color: AppColors.primaryDark, size: 26.sp),
                      SizedBox(width: 10.w),
                      Text(
                        _facePhoto == null ? 'Capture Image' : 'Retake',
                        style: AppTextStyles.bodyBold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_faceError != null) ...[
          SizedBox(height: 6.h),
          Text(_faceError!, style: AppTextStyles.errorText),
        ],
      ],
    );
  }

  Widget _uploadField({
    required String label,
    required bool required,
    required XFile? file,
    String? errorText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.inputLabel,
            children: [
              if (required)
                const TextSpan(
                    text: ' *', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: onTap,
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color:
                    errorText != null ? AppColors.error : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  file == null
                      ? Icons.cloud_upload_outlined
                      : Icons.check_circle_outline_rounded,
                  size: 20.sp,
                  color: file == null
                      ? AppColors.textSecondary
                      : AppColors.success,
                ),
                SizedBox(width: 8.w),
                Text(
                  file == null ? 'Upload' : 'Uploaded',
                  style: AppTextStyles.bodyBold,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 6.h),
          Text(errorText, style: AppTextStyles.errorText),
        ],
      ],
    );
  }
}
