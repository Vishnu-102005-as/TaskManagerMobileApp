import 'package:go_router/go_router.dart';
import 'package:taskmanagermobileapp/screens/dash_page.dart';
import 'package:taskmanagermobileapp/screens/home_page.dart';
import 'package:taskmanagermobileapp/screens/notes_page.dart';
import 'package:taskmanagermobileapp/screens/streak_page.dart';

import 'screens/add_task_page.dart';
import 'screens/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/tasks',
          name: 'tasks',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/streaks',
          name: 'streaks',
          builder: (context, state) => const StreakPage(),
        ),
        GoRoute(
          path: '/notes',
          name: 'notes',
          builder: (context, state) => const NotesPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/add-task',
      name: 'addTask',
      builder: (context, state) => const AddTaskPage(),
    ),
  ],
);
