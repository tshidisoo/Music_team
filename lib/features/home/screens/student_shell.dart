import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_strings.dart';

class StudentShell extends StatelessWidget {
  final Widget child;

  const StudentShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.studentLessons)) return 1;
    if (location.startsWith(AppRoutes.studentPractice)) return 2;
    if (location.startsWith(AppRoutes.studentProjects)) return 3;
    if (location.startsWith(AppRoutes.studentProfile)) return 4;
    return 0; // Home
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
              context.go(AppRoutes.studentHome);
            case 1:
              context.go(AppRoutes.studentLessons);
            case 2:
              context.go(AppRoutes.studentPractice);
            case 3:
              context.go(AppRoutes.studentProjects);
            case 4:
              context.go(AppRoutes.studentProfile);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book_rounded),
            label: AppStrings.lessons,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.piano_outlined),
            activeIcon: Icon(Icons.piano),
            label: AppStrings.practice,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: AppStrings.projects,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}
