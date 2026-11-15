import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/services/app_data_store.dart';
import '../../../../core/services/export_service.dart';
import '../../../../data/models/attendance_model.dart';
import '../../../../data/models/student_model.dart';

/// شاشة كشف الحضور اليومي
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedCircleId;

  // حالات الحضور لكل طالب
  final Map<String, AttendanceStatus> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    final circles = AppDataStore.instance.getVisibleCircles();
    if (circles.isNotEmpty) {
      _selectedCircleId = circles.first.id;
      _initializeAttendance();
    }
  }

  void _initializeAttendance() {
    _attendanceMap.clear();
    if (_selectedCircleId != null) {
      final students = AppDataStore.instance.getStudentsByCircle(_selectedCircleId!);
      for (final s in students) {
        _attendanceMap[s.id] = AttendanceStatus.present;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.attendanceSheet),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: 'تصدير سجل الحضور إلى Excel',
            onPressed: () async {
              final records = AppDataStore.instance.attendanceRecords;
              await ExportService.instance.exportAttendanceToExcel(records);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تصدير سجل الحضور إلى ملف Excel بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: Color(AppColors.primaryGreen),
                  ),
                );
              }
            },
          ),
          if (_selectedCircleId != null)
            TextButton.icon(
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                AppStrings.saveAttendance,
                style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              onPressed: _saveAttendance,
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppDataStore.instance,
        builder: (context, _) {
          return Column(
            children: [
              _buildSelectionHeader(),
              if (_selectedCircleId != null)
                Expanded(child: _buildAttendanceList())
              else
                Expanded(child: _buildSelectCirclePrompt()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectionHeader() {
    final circles = AppDataStore.instance.getVisibleCircles();

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCircleId,
            decoration: const InputDecoration(
              labelText: 'اختر الحلقة',
              prefixIcon: Icon(Icons.groups),
              isDense: true,
            ),
            items: circles.map((c) {
              return DropdownMenuItem(
                value: c.id,
                child: Text('${c.name} (${c.circleCode})', style: const TextStyle(fontFamily: 'Cairo')),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCircleId = value;
                _initializeAttendance();
              });
            },
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(AppColors.grey100),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(AppColors.grey300)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(AppColors.primaryGreen), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),

          if (_selectedCircleId != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _markAllPresent,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text(AppStrings.markAllPresent, style: TextStyle(fontFamily: 'Cairo')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    final students = AppDataStore.instance.getStudentsByCircle(_selectedCircleId!);

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('لا يوجد طلاب مسجلون في هذه الحلقة', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildAttendanceSummary(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildStudentAttendanceCard(students[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSummary() {
    int present = _attendanceMap.values.where((s) => s == AttendanceStatus.present).length;
    int absent = _attendanceMap.values.where((s) => s == AttendanceStatus.absent).length;
    int late = _attendanceMap.values.where((s) => s == AttendanceStatus.late).length;
    int excused = _attendanceMap.values.where((s) => s == AttendanceStatus.excusedAbsent).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(AppColors.grey100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('حاضر', present, const Color(AppColors.present)),
          _buildSummaryItem('غائب', absent, const Color(AppColors.absent)),
          _buildSummaryItem('متأخر', late, const Color(AppColors.late)),
          _buildSummaryItem('بعذر', excused, const Color(AppColors.excusedAbsent)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentAttendanceCard(StudentModel student) {
    final status = _attendanceMap[student.id] ?? AttendanceStatus.present;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(AppColors.primaryGreenSoft).withAlpha(60),
              child: Text(
                student.fullName[0],
                style: const TextStyle(
                  color: Color(AppColors.primaryGreenDark),
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    student.studentNumber,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            _buildAttendanceButtons(student.id, status),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceButtons(String studentId, AttendanceStatus currentStatus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusButton(studentId, AttendanceStatus.present, Icons.check, const Color(AppColors.present), currentStatus),
        const SizedBox(width: 4),
        _buildStatusButton(studentId, AttendanceStatus.absent, Icons.close, const Color(AppColors.absent), currentStatus),
        const SizedBox(width: 4),
        _buildStatusButton(studentId, AttendanceStatus.late, Icons.access_time, const Color(AppColors.late), currentStatus),
        const SizedBox(width: 4),
        _buildStatusButton(studentId, AttendanceStatus.excusedAbsent, Icons.info_outline, const Color(AppColors.excusedAbsent), currentStatus),
      ],
    );
  }

  Widget _buildStatusButton(
    String studentId,
    AttendanceStatus status,
    IconData icon,
    Color color,
    AttendanceStatus currentStatus,
  ) {
    final isSelected = currentStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() => _attendanceMap[studentId] = status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }

  Widget _buildSelectCirclePrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 14),
          const Text('اختر الحلقة لبدء تسجيل الحضور', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return '${days[date.weekday % 7]}، ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('ar', 'SA'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _markAllPresent() {
    setState(() {
      final keys = _attendanceMap.keys.toList();
      for (final key in keys) {
        _attendanceMap[key] = AttendanceStatus.present;
      }
    });
  }

  Future<void> _saveAttendance() async {
    final store = AppDataStore.instance;
    final circle = store.circles.firstWhere((c) => c.id == _selectedCircleId);
    final students = store.getStudentsByCircle(_selectedCircleId!);

    final records = <AttendanceModel>[];
    for (final s in students) {
      final status = _attendanceMap[s.id] ?? AttendanceStatus.present;
      records.add(
        AttendanceModel(
          id: 'att_${s.id}_${_selectedDate.millisecondsSinceEpoch}',
          studentId: s.id,
          studentName: s.fullName,
          circleId: circle.id,
          circleName: circle.name,
          date: _selectedDate,
          dayName: 'اليوم',
          status: status,
          teacherId: circle.teacherId,
          teacherName: circle.teacherName,
          createdAt: DateTime.now(),
        ),
      );
    }

    store.recordAttendance(records);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ كشف الحضور بنجاح وتحديث إحصائيات لوحة التحكم',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Color(AppColors.success),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
