import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../constants/app_enums.dart';
import '../services/app_data_store.dart';

class AppBottomNav extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = AppDataStore.instance.currentUser;
    final isTeacher = user?.role == UserRole.teacher;
    final isStudent = user?.role == UserRole.student;
    final isParent = user?.role == UserRole.parent;

    if (isStudent) {
      return NavigationBar(
        selectedIndex: selectedIndex.clamp(0, 4),
        onDestinationSelected: (index) {
          onIndexChanged(index);
          switch (index) {
            case 0:
              context.go(AppRoutes.dashboard);
              break;
            case 1:
              context.go(AppRoutes.memorization);
              break;
            case 2:
              context.go(AppRoutes.islamicTexts);
              break;
            case 3:
              context.go(AppRoutes.achievements);
              break;
            case 4:
              context.go(AppRoutes.notifications);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(AppColors.primaryGreen)),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(AppColors.primaryGreen)),
            label: 'المصحف',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_sharp),
            selectedIcon: Icon(Icons.menu_book, color: Color(AppColors.primaryGreen)),
            label: 'المتون',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Color(AppColors.primaryGreen)),
            label: 'أوسمتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign, color: Color(AppColors.primaryGreen)),
            label: 'الإعلانات',
          ),
        ],
      );
    }

    if (isParent) {
      return NavigationBar(
        selectedIndex: selectedIndex.clamp(0, 4),
        onDestinationSelected: (index) {
          onIndexChanged(index);
          switch (index) {
            case 0:
              context.go(AppRoutes.dashboard);
              break;
            case 1:
              context.go(AppRoutes.students);
              break;
            case 2:
              context.go(AppRoutes.memorization);
              break;
            case 3:
              context.go(AppRoutes.achievements);
              break;
            case 4:
              context.go(AppRoutes.notifications);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(AppColors.primaryGreen)),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Color(AppColors.primaryGreen)),
            label: 'الأبناء',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(AppColors.primaryGreen)),
            label: 'الحفظ',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Color(AppColors.primaryGreen)),
            label: 'المتفوقون',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign, color: Color(AppColors.primaryGreen)),
            label: 'الإعلانات',
          ),
        ],
      );
    }

    if (isTeacher) {
      return NavigationBar(
        selectedIndex: selectedIndex.clamp(0, 4),
        onDestinationSelected: (index) {
          onIndexChanged(index);
          switch (index) {
            case 0:
              context.go(AppRoutes.teacherDashboard);
              break;
            case 1:
              context.go(AppRoutes.circles);
              break;
            case 2:
              context.go(AppRoutes.attendance);
              break;
            case 3:
              context.go(AppRoutes.students);
              break;
            case 4:
              context.go(AppRoutes.memorization);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(AppColors.primaryGreen)),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: Color(AppColors.primaryGreen)),
            label: 'حلقاتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note, color: Color(AppColors.primaryGreen)),
            label: 'الحضور',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Color(AppColors.primaryGreen)),
            label: 'طلابي',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(AppColors.primaryGreen)),
            label: 'الحفظ',
          ),
        ],
      );
    }

    // المدير العام
    return NavigationBar(
      selectedIndex: selectedIndex.clamp(0, 4),
      onDestinationSelected: (index) {
        onIndexChanged(index);
        switch (index) {
          case 0:
            context.go(AppRoutes.dashboard);
            break;
          case 1:
            context.go(AppRoutes.circles);
            break;
          case 2:
            context.go(AppRoutes.attendance);
            break;
          case 3:
            context.go(AppRoutes.students);
            break;
          case 4:
            context.go(AppRoutes.settings);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: Color(AppColors.primaryGreen)),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups, color: Color(AppColors.primaryGreen)),
          label: 'الحلقات',
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_note_outlined),
          selectedIcon: Icon(Icons.edit_note, color: Color(AppColors.primaryGreen)),
          label: 'الحضور',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people, color: Color(AppColors.primaryGreen)),
          label: 'الطلاب',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: Color(AppColors.primaryGreen)),
          label: 'الإعدادات',
        ),
      ],
    );
  }
}
