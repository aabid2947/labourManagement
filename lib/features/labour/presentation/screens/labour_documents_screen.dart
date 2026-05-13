// File: lib/features/labour/presentation/screens/labour_documents_screen.dart
// Purpose: Labour Documents viewer — NOT in the PDF; designed by us with the project palette.
//          Lists Aadhaar + PAN + any other uploaded documents for a labour record.
// Used by: routes/app_router.dart at RouteNames.labourDocuments.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/section_card.dart';
import '../../data/labour_models.dart';
import '../../providers/labour_providers.dart';

class LabourDocumentsScreen extends ConsumerWidget {
  const LabourDocumentsScreen({super.key, required this.labour});
  final Labour labour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(labourDocumentsProvider(labour.id));

    return AppScaffold(
      title: 'Documents',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _labourHeader(),
          SizedBox(height: 14.h),
          Text('Uploaded Documents',
              style: AppTextStyles.sectionHeader),
          SizedBox(height: 8.h),
          Expanded(
            child: docsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Failed to load: $e', style: AppTextStyles.body),
              ),
              data: (docs) => docs.isEmpty
                  ? Center(
                      child: Text('No documents uploaded yet.',
                          style: AppTextStyles.body),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: docs.length,
                      separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (_, i) => _docRow(docs[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labourHeader() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: AppColors.avatarBg,
            child: Icon(Icons.person,
                color: AppColors.textSecondary, size: 28.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labour.name, style: AppTextStyles.bodyBold),
                SizedBox(height: 2.h),
                Text('${labour.skill}  •  ${labour.contractorName}',
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _docRow(LabourDocument doc) {
    return SectionCard(
      onTap: () {
        // TODO(api): open the resolved URL once the backend returns signed/public URLs.
      },
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              doc.type.toLowerCase() == 'aadhaar'
                  ? Icons.fingerprint
                  : Icons.badge_outlined,
              color: AppColors.primaryDark,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.type, style: AppTextStyles.bodyBold),
                SizedBox(height: 2.h),
                Text('Uploaded ${Formatters.date(doc.uploadedAt)}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 22.sp),
        ],
      ),
    );
  }
}
