/// ثوابت مسارات التنقل
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String adminLogin = '/admin-login';
  static const String forgotPassword = '/forgot-password';

  // Dashboard
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/dashboard/admin';
  static const String teacherDashboard = '/dashboard/teacher';
  static const String studentDashboard = '/dashboard/student';
  static const String parentDashboard = '/dashboard/parent';

  // Islamic Texts & Achievements
  static const String islamicTexts = '/texts';
  static const String achievements = '/achievements';

  // Circles
  static const String circles = '/circles';
  static const String circleDetail = '/circles/:circleId';
  static const String addCircle = '/circles/add';
  static const String editCircle = '/circles/:circleId/edit';
  static const String circleStudents = '/circles/:circleId/students';
  static const String circleStats = '/circles/:circleId/stats';

  // Students
  static const String students = '/students';
  static const String studentDetail = '/students/:studentId';
  static const String addStudent = '/students/add';
  static const String editStudent = '/students/:studentId/edit';

  // Attendance
  static const String attendance = '/attendance';
  static const String attendanceSheet = '/attendance/:circleId/:date';
  static const String attendanceReports = '/attendance/reports';

  // Memorization & Revision
  static const String memorization = '/memorization';
  static const String addMemorization = '/memorization/add';
  static const String revision = '/revision';
  static const String addRevision = '/revision/add';
  static const String studentProgress = '/memorization/:studentId/progress';

  // Exams
  static const String exams = '/exams';
  static const String examDetail = '/exams/:examId';
  static const String addExam = '/exams/add';
  static const String enterGrades = '/exams/:examId/grades';

  // Fees
  static const String fees = '/fees';
  static const String studentFees = '/fees/:studentId';
  static const String addPayment = '/fees/add-payment';
  static const String feeReceipt = '/fees/:paymentId/receipt';

  // Reports
  static const String reports = '/reports';
  static const String reportDetail = '/reports/:reportId';
  static const String createReport = '/reports/create';
  static const String editReport = '/reports/:reportId/edit';
  static const String reportPreview = '/reports/:reportId/preview';

  // Users
  static const String users = '/users';
  static const String userDetail = '/users/:userId';
  static const String addUser = '/users/add';
  static const String editUser = '/users/:userId/edit';

  // Notifications
  static const String notifications = '/notifications';

  // Settings
  static const String settings = '/settings';
  static const String auditLogs = '/settings/audit-logs';
  static const String backup = '/settings/backup';

  // Search
  static const String search = '/search';

  // Profile
  static const String profile = '/profile';
}
