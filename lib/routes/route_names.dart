// File: lib/routes/route_names.dart
// Purpose: String constants for every named route. Single source of truth for navigation.
// Used by: routes/app_router.dart and any caller of context.go / context.push.

class RouteNames {
  static const String splash = '/';
  static const String themePreview = '/_dev/theme-preview';

  // Auth (Prompts 3 + 4)
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String contactAdmin = '/contact-admin';
  static const String createMpin = '/mpin/create';
  static const String confirmMpin = '/mpin/confirm';
  static const String mpinLogin = '/mpin/login';

  // Dashboard (Prompt 5)
  static const String dashboard = '/dashboard';

  // Self attendance (Prompt 6)
  static const String selfAttendance = '/self-attendance';
  static const String selfAttendanceScan = '/self-attendance/scan';
  static const String selfAttendanceSuccess = '/self-attendance/success';
  static const String viewAttendance = '/self-attendance/view';

  // Labour (Prompts 7-9)
  static const String labourList = '/labour';
  static const String labourInduction = '/labour/induction';
  static const String labourEdit = '/labour/edit';
  static const String labourDocuments = '/labour/documents';
  static const String labourIn = '/labour/in';
  static const String labourInScan = '/labour/in/scan';
  static const String labourOut = '/labour/out';
  static const String labourOutScan = '/labour/out/scan';

  // Tasks (Prompts 10 + 12)
  static const String taskVsAchievements = '/tasks/achievements';
  static const String taskDetail = '/tasks/detail';
  static const String taskRemark = '/tasks/remark';
  static const String todaysTask = '/tasks/today';
  static const String todaysTaskDetail = '/tasks/today/detail';

  // Expense (Prompt 11)
  static const String myExpense = '/expense';
  static const String addExpense = '/expense/add';

  // Profile (Bug fix pass 5)
  static const String profile = '/profile';
}
