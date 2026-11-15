class IslamicTextModel {
  final String id;
  final String name;         // اسم المتن
  final String description;  // وصف مختصر
  final int totalLines;      // عدد الأبيات/السطور
  final String level;        // المستوى: مبتدئ، متوسط، متقدم
  final bool isActive;
  final DateTime createdAt;

  const IslamicTextModel({
    required this.id,
    required this.name,
    required this.description,
    required this.totalLines,
    required this.level,
    this.isActive = true,
    required this.createdAt,
  });

  static List<IslamicTextModel> defaultTexts() {
    final now = DateTime.now();
    return [
      IslamicTextModel(id: 'txt_1', name: 'تحفة الأطفال', description: 'متن في أحكام التجويد', totalLines: 60, level: 'مبتدئ', createdAt: now),
      IslamicTextModel(id: 'txt_2', name: 'المقدمة الجزرية', description: 'متن في أحكام التجويد للمتوسطين', totalLines: 109, level: 'متوسط', createdAt: now),
      IslamicTextModel(id: 'txt_3', name: 'الأربعون النووية', description: 'أربعون حديثاً في أصول الإسلام', totalLines: 42, level: 'متوسط', createdAt: now),
      IslamicTextModel(id: 'txt_4', name: 'الأصول الثلاثة', description: 'أصول العقيدة الإسلامية', totalLines: 50, level: 'مبتدئ', createdAt: now),
      IslamicTextModel(id: 'txt_5', name: 'الرحبية', description: 'متن في الفرائض والمواريث', totalLines: 170, level: 'متقدم', createdAt: now),
    ];
  }
}

class IslamicTextProgressModel {
  final String id;
  final String studentId;
  final String studentName;
  final String textId;
  final String textName;
  final int memorizedLines;   // عدد الأبيات المحفوظة
  final int totalLines;
  final String notes;
  final DateTime lastSession;
  final DateTime createdAt;

  const IslamicTextProgressModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.textId,
    required this.textName,
    required this.memorizedLines,
    required this.totalLines,
    this.notes = '',
    required this.lastSession,
    required this.createdAt,
  });

  double get progressPercent => totalLines > 0 ? (memorizedLines / totalLines) * 100 : 0;
  bool get isCompleted => memorizedLines >= totalLines;

  IslamicTextProgressModel copyWith({
    int? memorizedLines,
    String? notes,
    DateTime? lastSession,
  }) {
    return IslamicTextProgressModel(
      id: id,
      studentId: studentId,
      studentName: studentName,
      textId: textId,
      textName: textName,
      memorizedLines: memorizedLines ?? this.memorizedLines,
      totalLines: totalLines,
      notes: notes ?? this.notes,
      lastSession: lastSession ?? this.lastSession,
      createdAt: createdAt,
    );
  }
}
