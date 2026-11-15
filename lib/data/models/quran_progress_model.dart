// نموذج تقدم الطالب في القرآن الكريم
class QuranProgressModel {
  final String studentId;
  // آخر موضع وصل إليه الطالب
  final int lastSurahNumber;      // رقم السورة
  final String lastSurahName;     // اسم السورة
  final int lastAyahNumber;       // رقم الآية
  final int totalMemorizedPages;  // إجمالي الصفحات المحفوظة (من 604)
  // الأجزاء المحفوظة (1-30)
  final Map<int, double> juzProgress; // juz number → progress (0.0-1.0)
  // الهدف الأسبوعي (بالصفحات)
  final int weeklyTargetPages;
  // الهدف الشهري (بالصفحات)
  final int monthlyTargetPages;
  final DateTime updatedAt;

  const QuranProgressModel({
    required this.studentId,
    this.lastSurahNumber = 1,
    this.lastSurahName = 'الفاتحة',
    this.lastAyahNumber = 1,
    this.totalMemorizedPages = 0,
    this.juzProgress = const {},
    this.weeklyTargetPages = 2,
    this.monthlyTargetPages = 8,
    required this.updatedAt,
  });

  double get overallProgress => totalMemorizedPages / 604.0;

  QuranProgressModel copyWith({
    int? lastSurahNumber,
    String? lastSurahName,
    int? lastAyahNumber,
    int? totalMemorizedPages,
    Map<int, double>? juzProgress,
    int? weeklyTargetPages,
    int? monthlyTargetPages,
    DateTime? updatedAt,
  }) {
    return QuranProgressModel(
      studentId: studentId,
      lastSurahNumber: lastSurahNumber ?? this.lastSurahNumber,
      lastSurahName: lastSurahName ?? this.lastSurahName,
      lastAyahNumber: lastAyahNumber ?? this.lastAyahNumber,
      totalMemorizedPages: totalMemorizedPages ?? this.totalMemorizedPages,
      juzProgress: juzProgress ?? this.juzProgress,
      weeklyTargetPages: weeklyTargetPages ?? this.weeklyTargetPages,
      monthlyTargetPages: monthlyTargetPages ?? this.monthlyTargetPages,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// بيانات السور للعرض
class SurahInfo {
  final int number;
  final String name;
  final int ayahCount;
  final int juzNumber;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.ayahCount,
    required this.juzNumber,
  });

  static const List<SurahInfo> allSurahs = [
    SurahInfo(number: 1, name: 'الفاتحة', ayahCount: 7, juzNumber: 1),
    SurahInfo(number: 2, name: 'البقرة', ayahCount: 286, juzNumber: 1),
    SurahInfo(number: 3, name: 'آل عمران', ayahCount: 200, juzNumber: 3),
    SurahInfo(number: 4, name: 'النساء', ayahCount: 176, juzNumber: 4),
    SurahInfo(number: 5, name: 'المائدة', ayahCount: 120, juzNumber: 6),
    SurahInfo(number: 6, name: 'الأنعام', ayahCount: 165, juzNumber: 7),
    SurahInfo(number: 7, name: 'الأعراف', ayahCount: 206, juzNumber: 8),
    SurahInfo(number: 8, name: 'الأنفال', ayahCount: 75, juzNumber: 9),
    SurahInfo(number: 9, name: 'التوبة', ayahCount: 129, juzNumber: 10),
    SurahInfo(number: 10, name: 'يونس', ayahCount: 109, juzNumber: 11),
    SurahInfo(number: 11, name: 'هود', ayahCount: 123, juzNumber: 11),
    SurahInfo(number: 12, name: 'يوسف', ayahCount: 111, juzNumber: 12),
    SurahInfo(number: 13, name: 'الرعد', ayahCount: 43, juzNumber: 13),
    SurahInfo(number: 14, name: 'إبراهيم', ayahCount: 52, juzNumber: 13),
    SurahInfo(number: 15, name: 'الحجر', ayahCount: 99, juzNumber: 14),
    SurahInfo(number: 16, name: 'النحل', ayahCount: 128, juzNumber: 14),
    SurahInfo(number: 17, name: 'الإسراء', ayahCount: 111, juzNumber: 15),
    SurahInfo(number: 18, name: 'الكهف', ayahCount: 110, juzNumber: 15),
    SurahInfo(number: 19, name: 'مريم', ayahCount: 98, juzNumber: 16),
    SurahInfo(number: 20, name: 'طه', ayahCount: 135, juzNumber: 16),
    SurahInfo(number: 21, name: 'الأنبياء', ayahCount: 112, juzNumber: 17),
    SurahInfo(number: 22, name: 'الحج', ayahCount: 78, juzNumber: 17),
    SurahInfo(number: 23, name: 'المؤمنون', ayahCount: 118, juzNumber: 18),
    SurahInfo(number: 24, name: 'النور', ayahCount: 64, juzNumber: 18),
    SurahInfo(number: 25, name: 'الفرقان', ayahCount: 77, juzNumber: 18),
    SurahInfo(number: 26, name: 'الشعراء', ayahCount: 227, juzNumber: 19),
    SurahInfo(number: 27, name: 'النمل', ayahCount: 93, juzNumber: 19),
    SurahInfo(number: 28, name: 'القصص', ayahCount: 88, juzNumber: 20),
    SurahInfo(number: 29, name: 'العنكبوت', ayahCount: 69, juzNumber: 20),
    SurahInfo(number: 30, name: 'الروم', ayahCount: 60, juzNumber: 21),
    SurahInfo(number: 31, name: 'لقمان', ayahCount: 34, juzNumber: 21),
    SurahInfo(number: 32, name: 'السجدة', ayahCount: 30, juzNumber: 21),
    SurahInfo(number: 33, name: 'الأحزاب', ayahCount: 73, juzNumber: 21),
    SurahInfo(number: 34, name: 'سبأ', ayahCount: 54, juzNumber: 22),
    SurahInfo(number: 35, name: 'فاطر', ayahCount: 45, juzNumber: 22),
    SurahInfo(number: 36, name: 'يس', ayahCount: 83, juzNumber: 22),
    SurahInfo(number: 37, name: 'الصافات', ayahCount: 182, juzNumber: 23),
    SurahInfo(number: 38, name: 'ص', ayahCount: 88, juzNumber: 23),
    SurahInfo(number: 39, name: 'الزمر', ayahCount: 75, juzNumber: 23),
    SurahInfo(number: 40, name: 'غافر', ayahCount: 85, juzNumber: 24),
    SurahInfo(number: 41, name: 'فصلت', ayahCount: 54, juzNumber: 24),
    SurahInfo(number: 42, name: 'الشورى', ayahCount: 53, juzNumber: 25),
    SurahInfo(number: 43, name: 'الزخرف', ayahCount: 89, juzNumber: 25),
    SurahInfo(number: 44, name: 'الدخان', ayahCount: 59, juzNumber: 25),
    SurahInfo(number: 45, name: 'الجاثية', ayahCount: 37, juzNumber: 25),
    SurahInfo(number: 46, name: 'الأحقاف', ayahCount: 35, juzNumber: 26),
    SurahInfo(number: 47, name: 'محمد', ayahCount: 38, juzNumber: 26),
    SurahInfo(number: 48, name: 'الفتح', ayahCount: 29, juzNumber: 26),
    SurahInfo(number: 49, name: 'الحجرات', ayahCount: 18, juzNumber: 26),
    SurahInfo(number: 50, name: 'ق', ayahCount: 45, juzNumber: 26),
    SurahInfo(number: 51, name: 'الذاريات', ayahCount: 60, juzNumber: 26),
    SurahInfo(number: 52, name: 'الطور', ayahCount: 49, juzNumber: 27),
    SurahInfo(number: 53, name: 'النجم', ayahCount: 62, juzNumber: 27),
    SurahInfo(number: 54, name: 'القمر', ayahCount: 55, juzNumber: 27),
    SurahInfo(number: 55, name: 'الرحمن', ayahCount: 78, juzNumber: 27),
    SurahInfo(number: 56, name: 'الواقعة', ayahCount: 96, juzNumber: 27),
    SurahInfo(number: 57, name: 'الحديد', ayahCount: 29, juzNumber: 27),
    SurahInfo(number: 58, name: 'المجادلة', ayahCount: 22, juzNumber: 28),
    SurahInfo(number: 59, name: 'الحشر', ayahCount: 24, juzNumber: 28),
    SurahInfo(number: 60, name: 'الممتحنة', ayahCount: 13, juzNumber: 28),
    SurahInfo(number: 61, name: 'الصف', ayahCount: 14, juzNumber: 28),
    SurahInfo(number: 62, name: 'الجمعة', ayahCount: 11, juzNumber: 28),
    SurahInfo(number: 63, name: 'المنافقون', ayahCount: 11, juzNumber: 28),
    SurahInfo(number: 64, name: 'التغابن', ayahCount: 18, juzNumber: 28),
    SurahInfo(number: 65, name: 'الطلاق', ayahCount: 12, juzNumber: 28),
    SurahInfo(number: 66, name: 'التحريم', ayahCount: 12, juzNumber: 28),
    SurahInfo(number: 67, name: 'الملك', ayahCount: 30, juzNumber: 29),
    SurahInfo(number: 68, name: 'القلم', ayahCount: 52, juzNumber: 29),
    SurahInfo(number: 69, name: 'الحاقة', ayahCount: 52, juzNumber: 29),
    SurahInfo(number: 70, name: 'المعارج', ayahCount: 44, juzNumber: 29),
    SurahInfo(number: 71, name: 'نوح', ayahCount: 28, juzNumber: 29),
    SurahInfo(number: 72, name: 'الجن', ayahCount: 28, juzNumber: 29),
    SurahInfo(number: 73, name: 'المزمل', ayahCount: 20, juzNumber: 29),
    SurahInfo(number: 74, name: 'المدثر', ayahCount: 56, juzNumber: 29),
    SurahInfo(number: 75, name: 'القيامة', ayahCount: 40, juzNumber: 29),
    SurahInfo(number: 76, name: 'الإنسان', ayahCount: 31, juzNumber: 29),
    SurahInfo(number: 77, name: 'المرسلات', ayahCount: 50, juzNumber: 29),
    SurahInfo(number: 78, name: 'النبأ', ayahCount: 40, juzNumber: 30),
    SurahInfo(number: 79, name: 'النازعات', ayahCount: 46, juzNumber: 30),
    SurahInfo(number: 80, name: 'عبس', ayahCount: 42, juzNumber: 30),
    SurahInfo(number: 81, name: 'التكوير', ayahCount: 29, juzNumber: 30),
    SurahInfo(number: 82, name: 'الانفطار', ayahCount: 19, juzNumber: 30),
    SurahInfo(number: 83, name: 'المطففين', ayahCount: 36, juzNumber: 30),
    SurahInfo(number: 84, name: 'الانشقاق', ayahCount: 25, juzNumber: 30),
    SurahInfo(number: 85, name: 'البروج', ayahCount: 22, juzNumber: 30),
    SurahInfo(number: 86, name: 'الطارق', ayahCount: 17, juzNumber: 30),
    SurahInfo(number: 87, name: 'الأعلى', ayahCount: 19, juzNumber: 30),
    SurahInfo(number: 88, name: 'الغاشية', ayahCount: 26, juzNumber: 30),
    SurahInfo(number: 89, name: 'الفجر', ayahCount: 30, juzNumber: 30),
    SurahInfo(number: 90, name: 'البلد', ayahCount: 20, juzNumber: 30),
    SurahInfo(number: 91, name: 'الشمس', ayahCount: 15, juzNumber: 30),
    SurahInfo(number: 92, name: 'الليل', ayahCount: 21, juzNumber: 30),
    SurahInfo(number: 93, name: 'الضحى', ayahCount: 11, juzNumber: 30),
    SurahInfo(number: 94, name: 'الشرح', ayahCount: 8, juzNumber: 30),
    SurahInfo(number: 95, name: 'التين', ayahCount: 8, juzNumber: 30),
    SurahInfo(number: 96, name: 'العلق', ayahCount: 19, juzNumber: 30),
    SurahInfo(number: 97, name: 'القدر', ayahCount: 5, juzNumber: 30),
    SurahInfo(number: 98, name: 'البينة', ayahCount: 8, juzNumber: 30),
    SurahInfo(number: 99, name: 'الزلزلة', ayahCount: 8, juzNumber: 30),
    SurahInfo(number: 100, name: 'العاديات', ayahCount: 11, juzNumber: 30),
    SurahInfo(number: 101, name: 'القارعة', ayahCount: 11, juzNumber: 30),
    SurahInfo(number: 102, name: 'التكاثر', ayahCount: 8, juzNumber: 30),
    SurahInfo(number: 103, name: 'العصر', ayahCount: 3, juzNumber: 30),
    SurahInfo(number: 104, name: 'الهمزة', ayahCount: 9, juzNumber: 30),
    SurahInfo(number: 105, name: 'الفيل', ayahCount: 5, juzNumber: 30),
    SurahInfo(number: 106, name: 'قريش', ayahCount: 4, juzNumber: 30),
    SurahInfo(number: 107, name: 'الماعون', ayahCount: 7, juzNumber: 30),
    SurahInfo(number: 108, name: 'الكوثر', ayahCount: 3, juzNumber: 30),
    SurahInfo(number: 109, name: 'الكافرون', ayahCount: 6, juzNumber: 30),
    SurahInfo(number: 110, name: 'النصر', ayahCount: 3, juzNumber: 30),
    SurahInfo(number: 111, name: 'المسد', ayahCount: 5, juzNumber: 30),
    SurahInfo(number: 112, name: 'الإخلاص', ayahCount: 4, juzNumber: 30),
    SurahInfo(number: 113, name: 'الفلق', ayahCount: 5, juzNumber: 30),
    SurahInfo(number: 114, name: 'الناس', ayahCount: 6, juzNumber: 30),
  ];
}
