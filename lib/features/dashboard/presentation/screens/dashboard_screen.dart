// File: lib/features/dashboard/presentation/screens/dashboard_screen.dart
// Purpose: Pixel-matched Dashboard from page10_img01.jpeg.
// Used by: routes/app_router.dart at RouteNames.dashboard.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../features/auth/providers/auth_providers.dart';
import '../../../../features/auth/providers/mpin_providers.dart';
import '../../../../routes/route_names.dart';
import '../../providers/dashboard_providers.dart';
import '../widgets/management_tile.dart';
import '../widgets/metric_card.dart';
import '../widgets/todays_task_tile.dart';

/// Placeholder until the backend exposes the signed-in user payload.
const String _kPlaceholderUserName = 'Divya';
const String _kPlaceholderUserRole = 'Site Engineer';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _bottomIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Pre-warm the location request so the permission prompt fires once on first entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentLocationProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _greetingRow(),
                    SizedBox(height: 14.h),
                    TodaysTaskTile(
                      onTap: () => context.push(RouteNames.todaysTask),
                    ),
                    SizedBox(height: 14.h),
                    _locationPill(),
                    SizedBox(height: 14.h),
                    _metricGrid(),
                    SizedBox(height: 18.h),
                    Text('MANAGEMENT ACTIONS',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        )),
                    SizedBox(height: 10.h),
                    _managementRow(),
                    SizedBox(height: 12.h),
                    _carouselDots(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ───────────────────────────────────────────────────── top bar
  Widget _topBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          // Tappable profile avatar opens the side drawer (Bug fix pass 3 —
          // replaces the old `Icons.menu` hamburger).
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: const UserAvatar(radius: 18),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_kPlaceholderUserName, style: AppTextStyles.bodyBold),
              Text('Just now', style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          // Static icons — not wired in Prompt 5 per the brief.
          _staticIcon(Icons.star_border_rounded),
          SizedBox(width: 14.w),
          _staticIcon(Icons.share_outlined),
          SizedBox(width: 14.w),
          _staticBellIcon(),
        ],
      ),
    );
  }

  Widget _staticIcon(IconData icon) =>
      Icon(icon, size: 22.sp, color: AppColors.textPrimary);

  Widget _staticBellIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications_none_rounded,
            size: 24.sp, color: AppColors.textPrimary),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────── greeting + change site
  Widget _greetingRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Good Morning, $_kPlaceholderUserName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.screenTitle,
          ),
        ),
        SizedBox(width: 8.w),
        _changeSitePill(),
      ],
    );
  }

  Widget _changeSitePill() {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: _pickSite,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_horiz_rounded,
                size: 18.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text('CHANGE SITE',
                style: AppTextStyles.bodyBold.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.primaryDark,
                  letterSpacing: 0.6,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSite() async {
    final sitesAsync = ref.read(sitesProvider);
    final sites = sitesAsync.value;
    if (sites == null) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 8.h),
              Text('Change Site', style: AppTextStyles.sectionHeader),
              SizedBox(height: 8.h),
              for (final s in sites)
                ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: AppColors.primaryDark),
                  title: Text(s.name, style: AppTextStyles.body),
                  onTap: () => Navigator.of(context).pop(s.id),
                ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      final picked = sites.firstWhere((s) => s.id == selected);
      ref.read(selectedSiteProvider.notifier).select(picked);
    }
  }

  // ───────────────────────────────────────────────────── location pill
  Widget _locationPill() {
    final site = ref.watch(selectedSiteProvider);
    final sitesAsync = ref.watch(sitesProvider);
    final locationAsync = ref.watch(currentLocationProvider);

    // Auto-select the first site once the list arrives.
    sitesAsync.whenData((list) {
      if (site == null && list.isNotEmpty) {
        Future.microtask(
            () => ref.read(selectedSiteProvider.notifier).select(list.first));
      }
    });

    final projectName = site?.name ?? 'Project Alpha';
    final rawLoc = locationAsync.value;
    final locationLabel = rawLoc == null ? null : truncateLocation(rawLoc);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_outlined,
              size: 16.sp, color: AppColors.primaryDark),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              locationLabel == null
                  ? projectName
                  : '$projectName  •  $locationLabel',
              style: AppTextStyles.bodyBold.copyWith(fontSize: 13.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────── 2x2 metric grid
  Widget _metricGrid() {
    final summaryAsync = ref.watch(summaryProvider);
    final expenseAsync = ref.watch(myExpenseProvider);

    final summary = summaryAsync.value;
    final expense = expenseAsync.value;

    final attendancePct = summary == null || summary.attendanceTotal == 0
        ? 0.0
        : summary.attendancePresent / summary.attendanceTotal;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.45,
      children: [
        MetricCard(
          icon: Icons.people_alt_outlined,
          iconBg: AppColors.primarySoft,
          iconColor: AppColors.primaryDark,
          // Bug fix pass 3 — client asked for the user's photo in this slot.
          // Falls back to a soft-yellow person glyph until the backend ships
          // a profile photo URL.
          iconWidget: const UserAvatar(radius: 18),
          value: summary == null ? '—' : '${summary.totalLabour}',
          label: 'Total Labour Strength',
          onTap: () => context.push(RouteNames.labourList),
        ),
        MetricCard(
          icon: Icons.calendar_month_outlined,
          iconBg: const Color(0xFFE3EBFB),
          iconColor: AppColors.info,
          valueColor: AppColors.info,
          value: summary == null
              ? '—'
              : '${summary.attendancePresent}/${summary.attendanceTotal}',
          label: 'Today Attendance',
          progress: attendancePct,
          progressColor: AppColors.info,
          // Bug fix pass 4 — client redirected this tile to Labour In.
          onTap: () => context.push(RouteNames.labourIn),
        ),
        MetricCard(
          icon: Icons.account_balance_wallet_outlined,
          iconBg: const Color(0xFFEFEFEF),
          iconColor: AppColors.textPrimary,
          subtitle:
              expense == null ? '' : 'Adv :- ${Formatters.currency(expense.advance)}',
          value: expense == null ? '—' : Formatters.currency(expense.total),
          label: 'My Expense',
          onTap: () => context.push(RouteNames.myExpense),
        ),
        MetricCard(
          icon: Icons.insights_outlined,
          iconBg: const Color(0xFFFDE7E7),
          iconColor: AppColors.error,
          value: summary == null
              ? '—'
              : '${summary.taskAchieved}/${summary.taskTarget}',
          label: 'Task Vs Achievements',
          onTap: () => context.push(RouteNames.taskVsAchievements),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────── management actions row
  Widget _managementRow() {
    return Row(
      children: [
        Expanded(
          child: ManagementTile(
            icon: Icons.person_pin_circle_outlined,
            label: 'Self\nAttendance',
            selected: true, // matches the highlighted yellow tile in page10
            onTap: () => context.push(RouteNames.selfAttendance),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ManagementTile(
            icon: Icons.event_available_outlined,
            label: 'Labour\nIn',
            onTap: () => context.push(RouteNames.labourIn),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ManagementTile(
            icon: Icons.logout_outlined,
            label: 'Labour\nOut',
            onTap: () => context.push(RouteNames.labourOut),
          ),
        ),
      ],
    );
  }

  Widget _carouselDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i == 0;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: active ? 18.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ───────────────────────────────────────────────────── bottom nav
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_outlined, 'Home', () {
              setState(() => _bottomIndex = 0);
            }),
            _navItem(1, Icons.assignment_ind_outlined, 'Self Attendance', () {
              setState(() => _bottomIndex = 1);
              context.push(RouteNames.selfAttendance);
            }),
            _navItem(2, Icons.account_balance_wallet_outlined, 'My Expense', () {
              setState(() => _bottomIndex = 2);
              context.push(RouteNames.myExpense);
            }),
            _navItem(3, Icons.person_outline, 'Profile', () {
              setState(() => _bottomIndex = 3);
              context.push(RouteNames.profile);
            }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, VoidCallback onTap) {
    final active = _bottomIndex == index;
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(height: 2.h),
              Text(label, style: AppTextStyles.caption.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────── side drawer
  /// Drawer per bug-report pages 19–20: profile header + 5 menu items + Logout.
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _drawerHeader(),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                children: [
                  _drawerItem(
                    icon: Icons.person_outline_rounded,
                    label: 'My Profile',
                    onTap: () => _navigateFromDrawer(context, null),
                  ),
                  _drawerItem(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Change Site',
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickSite();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => _navigateFromDrawer(context, null),
                  ),
                  _drawerItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () => _navigateFromDrawer(context, null),
                  ),
                  _drawerItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About',
                    onTap: () => _navigateFromDrawer(context, null),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _logoutTile(),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _drawerHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Row(
        children: [
          const UserAvatar(radius: 28),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_kPlaceholderUserName,
                    style: AppTextStyles.sectionHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(_kPlaceholderUserRole,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22.sp),
      title: Text(label, style: AppTextStyles.body),
      onTap: onTap,
      dense: true,
    );
  }

  Widget _logoutTile() {
    return ListTile(
      leading: Icon(Icons.logout_rounded, color: AppColors.error, size: 22.sp),
      title: Text(
        'Logout',
        style:
            AppTextStyles.bodyBold.copyWith(color: AppColors.error),
      ),
      onTap: _onLogout,
    );
  }

  void _navigateFromDrawer(BuildContext context, String? route) {
    Navigator.of(context).pop();
    if (route != null) context.push(route);
  }

  /// Logout flow: confirm whether to forget the MPIN as well, clear the auth
  /// token, then route to /login (or /mpin-login if MPIN is kept).
  Future<void> _onLogout() async {
    final navigator = Navigator.of(context);
    final keepMpin = !(await ConfirmDialog.show(
      context,
      title: 'Logout',
      message: 'Also forget your MPIN? Choosing No keeps quick MPIN sign-in.',
      yesLabel: 'Forget MPIN',
      noLabel: 'Keep MPIN',
    ));
    if (!mounted) return;

    await ref.read(authRepositoryProvider).logout();
    if (!keepMpin) {
      await ref.read(authStorageProvider).clearMpin();
    }
    if (!mounted) return;
    navigator.pop(); // close the drawer
    context.go(keepMpin ? RouteNames.mpinLogin : RouteNames.login);
  }
}
