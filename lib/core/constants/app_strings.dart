/// ثوابت النصوص العربية للتطبيق
class AppStrings {
  AppStrings._();

  // ===== معلومات التطبيق =====
  static const String appName = 'إدارة حلقات مسجد الريان';
  static const String appNameShort = 'مسجد الريان';
  static const String institutionName = 'حلقات مسجد الريان لتعليم القرآن الكريم والعلوم الشرعية';
  static const String academicYear = '2026–2027';
  static const String location = 'تريم - دمون';
  static const String version = '1.0.0';

  // ===== تسجيل الدخول =====
  static const String login = 'تسجيل الدخول';
  static const String logout = 'تسجيل الخروج';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String loginButton = 'دخول';
  static const String loginWelcome = 'مرحباً بكم في نظام إدارة حلقات مسجد الريان';
  static const String loginSubtitle = 'يرجى تسجيل الدخول للمتابعة';

  // ===== القائمة الجانبية =====
  static const String dashboard = 'لوحة التحكم';
  static const String circles = 'الحلقات';
  static const String students = 'الطلاب';
  static const String attendance = 'الحضور والغياب';
  static const String memorizationAndRevision = 'الحفظ والمراجعة';
  static const String exams = 'الاختبارات والدرجات';
  static const String fees = 'الرسوم المالية';
  static const String reports = 'التقارير';
  static const String users = 'إدارة المستخدمين';
  static const String notifications = 'الإشعارات';
  static const String settings = 'الإعدادات';
  static const String auditLogs = 'سجل العمليات';

  // ===== لوحة التحكم =====
  static const String totalStudents = 'إجمالي الطلاب';
  static const String totalCircles = 'إجمالي الحلقات';
  static const String totalTeachers = 'إجمالي المدرسين';
  static const String presentToday = 'الحاضرون اليوم';
  static const String absentToday = 'الغائبون اليوم';
  static const String attendanceRate = 'نسبة الحضور';
  static const String newStudents = 'طلاب جدد';
  static const String suspendedStudents = 'طلاب متوقفون';
  static const String totalFeesDue = 'إجمالي الرسوم المستحقة';
  static const String totalFeesCollected = 'إجمالي الرسوم المحصلة';
  static const String pendingReports = 'تقارير تنتظر الاعتماد';
  static const String recentActivities = 'آخر العمليات';

  // ===== الحلقات =====
  static const String circle = 'حلقة';
  static const String circleName = 'اسم الحلقة';
  static const String teacher = 'المدرس';
  static const String supervisor = 'المشرف';
  static const String level = 'المستوى';
  static const String stage = 'المرحلة';
  static const String studyDays = 'أيام الدراسة';
  static const String startTime = 'وقت البداية';
  static const String endTime = 'وقت النهاية';
  static const String circleLocation = 'الموقع';
  static const String circleStatus = 'حالة الحلقة';
  static const String active = 'نشطة';
  static const String inactive = 'متوقفة';
  static const String notes = 'ملاحظات';
  static const String addCircle = 'إضافة حلقة';
  static const String editCircle = 'تعديل الحلقة';
  static const String deleteCircle = 'حذف الحلقة';
  static const String circleStudents = 'طلاب الحلقة';
  static const String circleStats = 'إحصائيات الحلقة';

  // ===== الطلاب =====
  static const String student = 'طالب';
  static const String studentNumber = 'رقم الطالب';
  static const String fullName = 'الاسم الكامل';
  static const String birthDate = 'تاريخ الميلاد';
  static const String enrollmentDate = 'تاريخ التسجيل';
  static const String studentStatus = 'حالة الطالب';
  static const String statusActive = 'نشط';
  static const String statusSuspended = 'متوقف';
  static const String statusTransferred = 'منقول';
  static const String statusGraduated = 'متخرج';
  static const String address = 'العنوان';
  static const String adminNotes = 'ملاحظات إدارية';
  static const String educationalNotes = 'ملاحظات تعليمية';
  static const String addStudent = 'إضافة طالب';
  static const String editStudent = 'تعديل بيانات الطالب';
  static const String studentFile = 'ملف الطالب';
  static const String personalInfo = 'البيانات الشخصية';
  static const String guardianInfo = 'بيانات ولي الأمر';
  static const String attendanceRecord = 'سجل الحضور';
  static const String memorizationRecord = 'سجل الحفظ';
  static const String revisionRecord = 'سجل المراجعة';
  static const String examRecord = 'الاختبارات';
  static const String gradesRecord = 'الدرجات';
  static const String feesRecord = 'الرسوم';
  static const String monthlyReports = 'التقارير الشهرية';

  // ===== ولي الأمر =====
  static const String guardian = 'ولي الأمر';
  static const String guardianName = 'اسم ولي الأمر';
  static const String relationship = 'صلة القرابة';
  static const String phoneNumber = 'رقم الهاتف';
  static const String additionalPhone = 'رقم إضافي';
  static const String callGuardian = 'اتصال هاتفي';
  static const String whatsappGuardian = 'واتساب';

  // ===== الحضور =====
  static const String attendanceSheet = 'كشف الحضور';
  static const String date = 'التاريخ';
  static const String day = 'اليوم';
  static const String present = 'حاضر';
  static const String absent = 'غائب';
  static const String late = 'متأخر';
  static const String excusedAbsent = 'غياب بعذر';
  static const String markAllPresent = 'تحديد الجميع حاضرين';
  static const String saveAttendance = 'حفظ الحضور';

  // ===== الحفظ والمراجعة =====
  static const String memorization = 'الحفظ';
  static const String revision = 'المراجعة';
  static const String surah = 'السورة';
  static const String fromAyah = 'من آية';
  static const String toAyah = 'إلى آية';
  static const String memorizationAmount = 'مقدار الحفظ';
  static const String memorizationQuality = 'جودة الحفظ';
  static const String excellent = 'ممتاز';
  static const String veryGood = 'جيد جداً';
  static const String good = 'جيد';
  static const String needsImprovement = 'يحتاج إلى تحسين';

  // ===== الاختبارات =====
  static const String exam = 'اختبار';
  static const String examName = 'اسم الاختبار';
  static const String subject = 'المادة';
  static const String fullMark = 'الدرجة الكاملة';
  static const String questionCount = 'عدد الأسئلة';
  static const String addExam = 'إنشاء اختبار';
  static const String enterGrades = 'إدخال الدرجات';

  // ===== الرسوم =====
  static const String fee = 'رسوم';
  static const String month = 'الشهر';
  static const String year = 'السنة';
  static const String amountDue = 'المبلغ المطلوب';
  static const String amountPaid = 'المبلغ المدفوع';
  static const String amountRemaining = 'المبلغ المتبقي';
  static const String paymentDate = 'تاريخ الدفع';
  static const String paymentMethod = 'طريقة الدفع';
  static const String receiver = 'اسم المستلم';
  static const String feePaid = 'مدفوع';
  static const String feePartial = 'مدفوع جزئياً';
  static const String feeUnpaid = 'غير مدفوع';
  static const String feeExempt = 'معفى';
  static const String receipt = 'إيصال دفع';

  // ===== الأدوار =====
  static const String roleAdmin = 'مدير عام';
  static const String roleViceAdmin = 'نائب المدير';
  static const String roleSupervisor = 'مشرف';
  static const String roleTeacher = 'مدرس';

  // ===== العمليات =====
  static const String add = 'إضافة';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String search = 'بحث';
  static const String filter = 'تصفية';
  static const String export = 'تصدير';
  static const String print = 'طباعة';
  static const String share = 'مشاركة';
  static const String preview = 'معاينة';
  static const String close = 'إغلاق';
  static const String back = 'رجوع';
  static const String next = 'التالي';
  static const String previous = 'السابق';
  static const String yes = 'نعم';
  static const String no = 'لا';
  static const String ok = 'موافق';

  // ===== الرسائل =====
  static const String deleteConfirmTitle = 'تأكيد الحذف';
  static const String deleteConfirmMessage = 'هل أنت متأكد من رغبتك في الحذف؟ لا يمكن التراجع عن هذا الإجراء.';
  static const String savedSuccessfully = 'تم الحفظ بنجاح';
  static const String deletedSuccessfully = 'تم الحذف بنجاح';
  static const String updatedSuccessfully = 'تم التحديث بنجاح';
  static const String addedSuccessfully = 'تمت الإضافة بنجاح';
  static const String errorOccurred = 'حدث خطأ، يرجى المحاولة مرة أخرى';
  static const String noData = 'لا توجد بيانات';
  static const String loading = 'جارٍ التحميل...';
  static const String noInternet = 'لا يوجد اتصال بالإنترنت';
  static const String syncPending = 'بيانات في انتظار المزامنة';
  static const String syncSuccess = 'تمت المزامنة بنجاح';
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String duplicateAttendance = 'تم تسجيل الحضور مسبقاً لهذا الطالب في هذا التاريخ';
  static const String logoutConfirm = 'هل تريد تسجيل الخروج؟';
  static const String unauthorized = 'ليس لديك صلاحية للوصول إلى هذه الصفحة';
}
