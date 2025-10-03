import 'package:flutter/material.dart';
import 'database.dart';
import 'course_provider.dart';
import 'screens.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(ChangeNotifierProvider(
    create: (_) => CourseProvider(db: db)..loadCoursesFromDb(),
    child: const CourseTrackerApp(),
  ));
}

class CourseTrackerApp extends StatelessWidget {
  const CourseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const CourseListScreen(),
    );
  }
}
