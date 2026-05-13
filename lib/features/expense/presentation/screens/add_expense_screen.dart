// File: lib/features/expense/presentation/screens/add_expense_screen.dart
// Purpose: Pixel-matched Add Expense (Book Expense / New Claim) from page38_img01.jpeg.
//          Supports multiple expense sections via "Add Another Expense" and submits
//          all of them in a single POST.
// Used by: routes/app_router.dart at RouteNames.addExpense.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../../../routes/route_names.dart';
import '../../data/expense_models.dart';
import '../../providers/expense_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<ExpenseDraft> _drafts = [
    ExpenseDraft(id: 'd-${DateTime.now().microsecondsSinceEpoch}'),
  ];
  bool _newClaimTab = true;
  bool _submitting = false;

  void _addAnother() {
    setState(() {
      _drafts.add(
        ExpenseDraft(id: 'd-${DateTime.now().microsecondsSinceEpoch}'),
      );
    });
  }

  void _removeAt(int index) {
    if (_drafts.length == 1) return; // never delete the last one
    setState(() => _drafts.removeAt(index));
  }

  void _updateAt(int index, ExpenseDraft Function(ExpenseDraft) edit) {
    setState(() => _drafts[index] = edit(_drafts[index]));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Ensure each draft has a category + amount + date.
    for (final d in _drafts) {
      if (d.category == null || d.amount == null || d.date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill all required fields.')),
        );
        return;
      }
    }
    setState(() => _submitting = true);
    final ok =
        await ref.read(expenseRepositoryProvider).createMany(_drafts);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submit failed. Please try again.')),
      );
      return;
    }
    // Refresh Pending tab + summary so the new rows show up.
    ref.invalidate(expenseByStatusProvider(ExpenseStatus.pending));
    ref.invalidate(expenseSummaryProvider);
    ref.read(selectedExpenseTabProvider.notifier).select(ExpenseStatus.pending);

    await SuccessDialog.show(
      context,
      title: 'Claim Submitted',
      message: 'Your expense claim has been submitted.',
    );
    if (!mounted) return;
    context.go(RouteNames.myExpense);
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
        title: Text('Book Expense', style: AppTextStyles.appBarTitle),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Icon(Icons.notifications_none_rounded,
                color: AppColors.textPrimary, size: 22.sp),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sitePill(),
                SizedBox(height: 14.h),
                _tabs(),
                SizedBox(height: 14.h),
                for (var i = 0; i < _drafts.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: _ExpenseSection(
                      index: i,
                      draft: _drafts[i],
                      canRemove: _drafts.length > 1,
                      onUpdate: (edit) => _updateAt(i, edit),
                      onRemove: () => _removeAt(i),
                    ),
                  ),
                _addAnotherButton(),
                SizedBox(height: 14.h),
                PrimaryButton(
                  label: 'SUBMIT CLAIM',
                  icon: Icons.send_rounded,
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

  Widget _sitePill() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'ALPHA • MUMBAI METRO',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white70, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    Widget tab(String label, bool active, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: active ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: active
                  ? const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.bodyBold.copyWith(
                  color: active ? AppColors.primaryDark : AppColors.textSecondary,
                  letterSpacing: 0.6,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          tab('NEW CLAIM', _newClaimTab,
              () => setState(() => _newClaimTab = true)),
          tab('HISTORY', !_newClaimTab,
              () => setState(() => _newClaimTab = false)),
        ],
      ),
    );
  }

  Widget _addAnotherButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: _addAnother,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.4),
              ),
              child: Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 16.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              'ADD ANOTHER EXPENSE',
              style: AppTextStyles.bodyBold
                  .copyWith(letterSpacing: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseSection extends StatefulWidget {
  const _ExpenseSection({
    required this.index,
    required this.draft,
    required this.canRemove,
    required this.onUpdate,
    required this.onRemove,
  });

  final int index;
  final ExpenseDraft draft;
  final bool canRemove;
  final void Function(ExpenseDraft Function(ExpenseDraft)) onUpdate;
  final VoidCallback onRemove;

  @override
  State<_ExpenseSection> createState() => _ExpenseSectionState();
}

class _ExpenseSectionState extends State<_ExpenseSection> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _picker = ImagePicker();
  XFile? _attachment;

  @override
  void initState() {
    super.initState();
    if (widget.draft.amount != null) {
      _amountCtrl.text = widget.draft.amount.toString();
    }
    if (widget.draft.notes != null) _notesCtrl.text = widget.draft.notes!;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final shot = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (shot != null) {
      setState(() => _attachment = shot);
      widget.onUpdate((d) => d.copyWith(attachmentLocalPath: shot.path));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.draft.date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) {
      widget.onUpdate((d) => d.copyWith(date: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.index > 0 || widget.canRemove)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense #${widget.index + 1}',
                  style: AppTextStyles.bodyBold,
                ),
                if (widget.canRemove)
                  InkWell(
                    onTap: widget.onRemove,
                    borderRadius: BorderRadius.circular(6.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 20.sp),
                    ),
                  ),
              ],
            ),
          SizedBox(height: 8.h),
          _label('EXPENSE CATEGORY', required: true),
          SizedBox(height: 8.h),
          _categoryDropdown(),
          SizedBox(height: 14.h),
          _label('AMOUNT', required: true),
          SizedBox(height: 8.h),
          _amountField(),
          SizedBox(height: 14.h),
          _label('DESCRIPTION / REMARKS'),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _notesCtrl,
            minLines: 3,
            maxLines: 4,
            onChanged: (v) =>
                widget.onUpdate((d) => d.copyWith(notes: v.trim())),
            decoration: const InputDecoration(
              hintText: 'Enter purpose of expense…',
            ),
          ),
          SizedBox(height: 14.h),
          _label('DATE', required: true),
          SizedBox(height: 8.h),
          _dateField(),
          SizedBox(height: 14.h),
          _label('SUPPORTING DOCUMENT'),
          SizedBox(height: 8.h),
          _supportingDoc(),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTextStyles.inputLabel,
        children: [
          if (required)
            const TextSpan(
                text: ' *', style: TextStyle(color: AppColors.error)),
        ],
      ),
    );
  }

  Widget _categoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: widget.draft.category,
      isExpanded: true,
      icon: Icon(Icons.keyboard_double_arrow_down_rounded,
          color: AppColors.textSecondary, size: 22.sp),
      style: AppTextStyles.inputText,
      decoration: const InputDecoration(hintText: 'Select category'),
      items: kExpenseCategories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(growable: false),
      onChanged: (v) {
        widget.onUpdate((d) => d.copyWith(category: v));
      },
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _amountField() {
    return TextFormField(
      controller: _amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        hintText: '0.00',
        prefixText: '₹  ',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        final n = num.tryParse(v.trim());
        if (n == null || n <= 0) return 'Enter a valid amount';
        return null;
      },
      onChanged: (v) =>
          widget.onUpdate((d) => d.copyWith(amount: num.tryParse(v.trim()))),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.draft.date == null
                    ? 'Select date'
                    : Formatters.date(widget.draft.date!),
                style: widget.draft.date == null
                    ? AppTextStyles.inputHint
                    : AppTextStyles.inputText,
              ),
            ),
            Icon(Icons.calendar_today_outlined,
                color: AppColors.textSecondary, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Widget _supportingDoc() {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: _pickReceipt,
      child: DottedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 14.w),
          child: Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.photo_camera_outlined,
                    color: AppColors.textOnPrimary, size: 22.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                _attachment == null ? 'Upload Receipt' : 'Receipt attached',
                style: AppTextStyles.bodyBold,
              ),
              SizedBox(height: 2.h),
              Text(
                'MAX 5MB • PDF, JPG, PNG',
                style: AppTextStyles.caption,
              ),
              if (_attachment != null) ...[
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: SizedBox(
                    height: 72.h,
                    child: Image.file(
                      File(_attachment!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed border container used by the SUPPORTING DOCUMENT slot.
class DottedBox extends StatelessWidget {
  const DottedBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final radius = Radius.circular(12.r);
    final rect =
        RRect.fromRectAndRadius(Offset.zero & size, radius);
    final path = Path()..addRRect(rect);

    // Walk the path with a dash pattern.
    const dashLen = 6.0;
    const gapLen = 4.0;
    for (final m in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < m.length) {
        final next = (distance + dashLen).clamp(0.0, m.length);
        canvas.drawPath(m.extractPath(distance, next), paint);
        distance = next + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
