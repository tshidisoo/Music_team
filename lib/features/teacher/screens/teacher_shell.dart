import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_strings.dart';

class TeacherShell extends StatelessWidget {
  final Widget child;

  const TeacherShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.teacherStudents)) return 1;
    if (location.startsWith(AppRoutes.teacherProjects)) return 2;
    if (location.startsWith(AppRoutes.teacherSubmissions)) return 3;
    return 0; // Dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.teacherDashboard);
            case 1:
              context.go(AppRoutes.teacherStudents);
            case 2:
              context.go(AppRoutes.teacherProjects);
            case 3:
              context.go(AppRoutes.teacherSubmissions);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: AppStrings.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: AppStrings.students,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: AppStrings.projects,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review_rounded),
            label: AppStrings.submissions,
          ),
        ],
      ),
    );
  }
}
