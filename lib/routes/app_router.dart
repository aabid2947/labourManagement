// File: lib/routes/app_router.dart
// Purpose: GoRouter configuration — every named route in the app lives here.
// Used by: lib/app/app.dart.

import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/confirm_mpin_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/mpin_login_screen.dart';
import '../features/auth/presentation/screens/set_mpin_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/expense/presentation/screens/add_expense_screen.dart';
import '../features/expense/presentation/screens/my_expense_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/labour/data/labour_models.dart';
import '../features/labour/presentation/screens/labour_documents_screen.dart';
import '../features/labour/presentation/screens/labour_face_scan_screen.dart';
import '../features/labour/presentation/screens/labour_in_screen.dart';
import '../features/labour/presentation/screens/labour_list_screen.dart';
import '../features/labour/presentation/screens/labour_out_screen.dart';
import '../features/labour/presentation/screens/labour_scan_args.dart';
import '../features/labour/presentation/screens/new_labour_induction_screen.dart';
import '../features/self_attendance/data/attendance_models.dart';
import '../features/tasks/data/task_models.dart';
import '../features/tasks/data/todays_task_models.dart';
import '../features/tasks/presentation/screens/task_detail_screen.dart';
import '../features/tasks/presentation/screens/task_remark_screen.dart';
import '../features/tasks/presentation/screens/task_vs_achievements_screen.dart';
import '../features/tasks/presentation/screens/todays_task_detail_screen.dart';
import '../features/tasks/presentation/screens/todays_task_screen.dart';
import '../features/self_attendance/presentation/screens/attendance_success_screen.dart';
import '../features/self_attendance/presentation/screens/face_attendance_screen.dart';
import '../features/self_attendance/presentation/screens/self_attendance_screen.dart';
import '../features/self_attendance/presentation/screens/view_attendance_screen.dart';
import 'route_names.dart';
import 'splash_screen.dart';
import 'theme_preview_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.themePreview,
        builder: (_, _) => const ThemePreviewScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.createMpin,
        builder: (_, _) => const SetMpinScreen(),
      ),
      GoRoute(
        path: RouteNames.confirmMpin,
        builder: (_, _) => const ConfirmMpinScreen(),
      ),
      GoRoute(
        path: RouteNames.mpinLogin,
        builder: (_, _) => const MpinLoginScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (_, _) => const DashboardScreen(),
      ),
      // ─── stubs for Prompts 7-12 — replaced one-by-one as each prompt lands ────
      // Prompt 6 — Self Attendance flow
      GoRoute(
        path: RouteNames.selfAttendance,
        builder: (_, _) => const SelfAttendanceScreen(),
      ),
      GoRoute(
        path: RouteNames.selfAttendanceScan,
        builder: (_, state) => FaceAttendanceScreen(
          status: (state.extra as AttendanceStatus?) ??
              AttendanceStatus.inStatus,
        ),
      ),
      GoRoute(
        path: RouteNames.selfAttendanceSuccess,
        builder: (_, state) => AttendanceSuccessScreen(
          result: state.extra as MarkAttendanceResult,
        ),
      ),
      GoRoute(
        path: RouteNames.viewAttendance,
        builder: (_, _) => const ViewAttendanceScreen(),
      ),
      // Prompt 7 — Total Labour Strength + New Labour Induction
      GoRoute(
        path: RouteNames.labourList,
        builder: (_, _) => const LabourListScreen(),
      ),
      GoRoute(
        path: RouteNames.labourInduction,
        builder: (_, _) => const NewLabourInductionScreen(),
      ),
      GoRoute(
        path: RouteNames.labourEdit,
        builder: (_, state) =>
            NewLabourInductionScreen(existing: state.extra as Labour),
      ),
      GoRoute(
        path: RouteNames.labourDocuments,
        builder: (_, state) =>
            LabourDocumentsScreen(labour: state.extra as Labour),
      ),
      // Prompt 8 — Labour In flow
      GoRoute(
        path: RouteNames.labourIn,
        builder: (_, _) => const LabourInScreen(),
      ),
      GoRoute(
        path: RouteNames.labourInScan,
        builder: (_, state) =>
            LabourFaceScanScreen(args: state.extra as LabourScanArgs),
      ),
      // Prompt 9 — Labour Out flow (reuses LabourFaceScanScreen with outMode)
      GoRoute(
        path: RouteNames.labourOut,
        builder: (_, _) => const LabourOutScreen(),
      ),
      GoRoute(
        path: RouteNames.labourOutScan,
        builder: (_, state) =>
            LabourFaceScanScreen(args: state.extra as LabourScanArgs),
      ),
      // Prompt 10 — Task v/s Achievements + Detail + Remark
      GoRoute(
        path: RouteNames.taskVsAchievements,
        builder: (_, _) => const TaskVsAchievementsScreen(),
      ),
      GoRoute(
        path: RouteNames.taskDetail,
        builder: (_, state) =>
            TaskDetailScreen(task: state.extra as TaskAchievement),
      ),
      GoRoute(
        path: RouteNames.taskRemark,
        builder: (_, state) =>
            TaskRemarkScreen(task: state.extra as TaskAchievement),
      ),
      // Prompt 11 — My Expense + Add Expense
      GoRoute(
        path: RouteNames.myExpense,
        builder: (_, _) => const MyExpenseScreen(),
      ),
      GoRoute(
        path: RouteNames.addExpense,
        builder: (_, _) => const AddExpenseScreen(),
      ),
      // Bug fix pass 5 — Profile
      GoRoute(
        path: RouteNames.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      // Prompt 12 — Today's Task + Detail (designed by us)
      GoRoute(
        path: RouteNames.todaysTask,
        builder: (_, _) => const TodaysTaskScreen(),
      ),
      GoRoute(
        path: RouteNames.todaysTaskDetail,
        builder: (_, state) =>
            TodaysTaskDetailScreen(task: state.extra as TodayTask),
      ),
    ],
  );
}
